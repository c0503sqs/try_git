# gh gist

## 能学到什么

- 用 `gh` 创建、查看、编辑、删除 gist
- 区分 public 和 secret
- 从标准输入创建 gist
- 知道 gist 的本质和风险

## gist 是什么

gist 是 GitHub 提供的**轻量代码片段仓库**，每个 gist 本身就是一个 git 仓库，可以有多文件、有版本历史、能 clone。

用途：分享片段、贴日志、存配置示例、做简单的文档草稿。

## 创建

```bash
gh gist create hello.py
gh gist create --public hello.py
gh gist create -d "Python 示例" hello.py
gh gist create a.py b.py c.py
```

参数（来自 `gh gist create --help`）：

| 参数 | 作用 |
| --- | --- |
| `-p, --public` | 公开；不加则默认 secret |
| `-d, --desc` | 描述 |
| `-f, --filename` | 从 stdin 读取时指定文件名 |
| `-w, --web` | 创建后打开浏览器 |

从标准输入创建：

```bash
echo 'print("hello")' | gh gist create -f hello.py
gh run view 123 --log-failed | gh gist create -f ci-failure.log -d "CI 失败日志"
```

多个文件会成为一个 gist 的多个文件。

## public 和 secret

| 类型 | 出现在列表 | 能被搜索 | 知道 URL 的人 |
| --- | --- | --- | --- |
| public | 是 | 是 | 能看 |
| secret | 否 | 否 | **能看** |

**secret 只是「不公开列出」，不是「私密」**。任何拿到链接的人都能访问。不要用它存放 token、密码、内部地址。

## 查看

```bash
gh gist list
gh gist list --limit 20
gh gist list --public
gh gist view <id>
gh gist view <id> --web
gh gist view <id> -f hello.py
```

id 是 URL 最后那段，例如 `https://gist.github.com/user/abc123` 里的 `abc123`。

## 编辑

```bash
gh gist edit <id>
gh gist edit <id> hello.py
gh gist edit <id> --add new-file.md
gh gist edit <id> -f hello.py      # 用 stdin 替换内容
```

编辑会生成新的版本，历史可以在网页的 Revisions 里看。

## 删除

```bash
gh gist delete <id>
```

不可恢复，且不会二次确认时，先确认 id。

## 克隆 gist

gist 就是 git 仓库：

```bash
gh gist clone <id>
git clone https://gist.github.com/<id>.git
```

可以像普通仓库一样提交、推送、看历史。

## 在脚本里用

`gh gist create` 输出新 gist 的 URL：

```bash
url=$(echo "log content" | gh gist create -f build.log -d "build log")
echo "$url"
```

适合把 CI 日志、诊断信息快速转成可分享链接。

## 注意事项

1. **secret gist 不是私有的**。链接泄漏等于内容泄漏。
2. **gist 没有权限管理**。不能只让某几个人看；需要访问控制就用私有仓库。
3. **gist 默认 secret**，但很多人误以为它安全。分享前想清楚内容。
4. **gist 有版本历史**，删除了内容也留在 Revisions 里；彻底删除要删整个 gist。
5. **匿名 gist 已不能创建**，必须登录。
6. **gist 也消耗 API 配额**，批量脚本注意频率。

## 练习

1. 创建一个 secret gist，确认它不出现在 `gh gist list --public` 里。
2. 用 `echo` 管道创建 gist，指定文件名和描述。
3. 用 `gh gist view -f` 查看某个文件，再 `gh gist clone` 到本地。
4. 编辑一个文件，观察网页上的 Revisions 记录。

---

上一篇：[gh release](05-release.md) · 下一篇：[gh api：万能逃生口](07-api.md)
