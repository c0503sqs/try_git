# gh api：万能逃生口

## 能学到什么

- 用 `gh api` 调用任何 REST / GraphQL 接口
- 分清 `-f` 和 `-F`
- 用 `--jq`、`--paginate` 处理返回结果
- 知道占位符 `{owner}`、`{repo}` 的用法

## 为什么需要它

`gh` 的子命令只覆盖常用操作。任何没有封装的功能，都可以直接调 GitHub API：

```bash
gh api <endpoint>
```

`gh api` 会自动带上当前登录的 token，省去手动设 `Authorization` 头。

## 基本用法

```bash
gh api user
gh api repos/{owner}/{repo}
gh api repos/{owner}/{repo}/issues
gh api repos/{owner}/{repo}/issues/42
```

占位符 `{owner}`、`{repo}`、`{branch}` 会自动替换成当前目录对应仓库的值。不在仓库目录时，用 `-R owner/repo` 指定，或直接写全路径。

## 方法与参数

GET 是默认。带参数时自动变 POST：

```bash
# POST：创建 issue
gh api repos/{owner}/{repo}/issues \
  -f title="标题" \
  -f body="正文"

# 显式指定方法
gh api --method PATCH repos/{owner}/{repo}/issues/42 -f state=closed
gh api -X DELETE repos/{owner}/{repo}/issues/42
```

`-f` 和 `-F` 的区别：

| 参数 | 类型转换 |
| --- | --- |
| `-f, --raw-field key=value` | 一律按字符串发送 |
| `-F, --field key=value` | `true`/`false`/`null`/数字会转成 JSON 类型；`@file` 读文件；`-` 读 stdin |

需要发数字或布尔值时用 `-F`：

```bash
gh api repos/{owner}/{repo}/pulls/123 \
  -X PATCH -F draft=false -f title="新标题"
```

## 读取结果

```bash
gh api user --jq '.login'
```

`--jq` 是内置的 jq 表达式，不用额外装 `jq`。

```bash
gh api repos/{owner}/{repo}/issues \
  --jq '.[] | "\(.number) \(.title)"'
```

其他输出控制：

| 参数 | 作用 |
| --- | --- |
| `--jq <expr>` | 过滤 JSON |
| `--template <tpl>` | Go template 输出 |
| `--paginate` | 自动翻页，合并所有结果 |
| `--slurp` | 把多页结果合成一个数组 |
| `--cache <duration>` | 缓存响应 |
| `-i, --include` | 输出响应头 |
| `--silent` | 不输出响应体 |

翻页：

```bash
gh api repos/{owner}/{repo}/issues --paginate --jq '.[].number'
gh api --paginate --slurp repos/{owner}/{repo}/issues --jq 'length'
```

## GraphQL

```bash
gh api graphql -f query='
  query($owner: String!, $repo: String!) {
    repository(owner: $owner, name: $repo) {
      issues(first: 5, states: OPEN) {
        nodes { number title }
      }
    }
  }
' -F owner=cli -F repo=cli
```

GraphQL 适合一次取多个关联对象、避免多次 REST 请求。`-F` 用来传变量。

## 常见任务

```bash
# 当前登录用户
gh api user --jq '.login'

# 仓库的 star 数
gh api repos/{owner}/{repo} --jq '.stargazers_count'

# 列出开放的 PR（需要 jq 过滤状态）
gh api repos/{owner}/{repo}/pulls --jq '.[] | select(.state=="open") | .number'

# 关闭 issue
gh api -X PATCH repos/{owner}/{repo}/issues/42 -f state=closed

# 给 PR 加标签
gh api repos/{owner}/{repo}/issues/123/labels -f 'labels[]=bug'

# 查看速率限制
gh api rate_limit --jq '.rate'
```

## 权限与错误

| 错误 | 含义 | 处理 |
| --- | --- | --- |
| `HTTP 401` | token 无效或过期 | `gh auth login` |
| `HTTP 403` | 无权限 / 被限流 / 需要 SSO | 看响应头、补 scope、组织授权 |
| `HTTP 404` | 资源不存在，或私有仓库无权访问 | 确认路径和权限 |
| `HTTP 422` | 参数校验失败 | 看返回的 `message` 和 `errors` |

查看完整错误：

```bash
gh api repos/{owner}/{repo}/issues/999 2>&1
```

## 预览接口

某些接口需要 `Accept` 头：

```bash
gh api --preview corsair repos/{owner}/{repo}/...
```

参数名见 GitHub 文档。

## 注意事项

1. **`-f` 会把所有值当字符串**。需要布尔或数字时用 `-F`，否则 API 可能报类型错误。
2. **带参数自动变 POST**。想用 GET 加查询参数，写 `--method GET`。
3. **分页默认只返回一页**。列表类接口要 `--paginate`。
4. **`--jq` 只处理 JSON**。接口返回非 JSON 时会报错，先去掉 `--jq` 看原始响应。
5. **REST 路径区分大小写**，仓库名和用户名按实际拼写。
6. **API 有速率限制**。未认证 60 次/小时，认证后 5000 次/小时；批量脚本加缓存或 `--cache`。
7. **写操作会真实修改仓库**。先用 `--method GET` 或 `--dry-run`（如果支持）确认路径。

## 练习

1. 用 `gh api user --jq '.login'` 打印当前账号。
2. 用 `gh api repos/{owner}/{repo} --jq '.stargazers_count'` 查一个公开仓库的 star 数。
3. 用 `--paginate` 列出一个仓库的所有开放 issue 编号。
4. 用 `-X PATCH` 修改一个测试 issue 的标题，再用 GET 确认。

---

上一篇：[gh gist](06-gist.md) · 下一篇：[alias 与扩展](08-alias-and-extension.md)
