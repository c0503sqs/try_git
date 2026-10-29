# gh release

## 能学到什么

- 用 `gh` 创建带说明和附件的 Release
- 区分 tag、Release、draft、prerelease
- 下载和更新已发布的 Release
- 知道 Release 和 tag 的删除关系

## Release 是什么

Release = **tag** + **发布说明** + **附件**。tag 只是提交的指针，Release 是 GitHub 在它之上加的一层展示。

```text
git tag v1.2.0
        │
        ▼
GitHub Release v1.2.0
  ├── 标题
  ├── 发布说明（Markdown）
  ├── 附件（zip、二进制、校验和）
  └── Latest / Pre-release 标记
```

## 创建

```bash
gh release create v1.2.0 \
  --title "v1.2.0" \
  --notes "## 新增

- 支持按标签过滤

## 修复

- CSV 中文乱码"
```

如果 tag 还不存在，`gh release create v1.2.0` 会基于当前默认分支创建它。想先确认 tag 已存在：

```bash
gh release create v1.2.0 --verify-tag
```

常用参数（来自 `gh release create --help`）：

| 参数 | 作用 |
| --- | --- |
| `-t, --title` | 标题 |
| `-n, --notes` | 发布说明 |
| `-F, --notes-file` | 从文件读，`-` 表示 stdin |
| `--generate-notes` | 让 GitHub 自动根据提交和 PR 生成说明 |
| `--notes-from-tag` | 用 tag 的附注作为说明 |
| `-d, --draft` | 草稿，只有自己能看见 |
| `-p, --prerelease` | 标记为预发布 |
| `--latest` | 标记为 Latest；`--latest=false` 取消 |
| `--target <branch>` | tag 不存在时基于哪个分支创建 |
| `--verify-tag` | tag 不存在就报错 |

自动生成说明：

```bash
gh release create v1.2.0 --generate-notes
```

GitHub 会按 PR 标签和提交分类，比手写省事，但通常还需要补一段面向用户的概述。

## 附带文件

```bash
gh release create v1.2.0 ./dist/app-darwin-arm64.zip ./dist/app-linux-x64.tar.gz
```

也可以先建 Release，再上传：

```bash
gh release create v1.2.0 --title "v1.2.0" --notes "..."
gh release upload v1.2.0 ./dist/*.zip
```

`--clobber` 可以覆盖同名附件：

```bash
gh release upload v1.2.0 ./dist/app.zip --clobber
```

## 查看

```bash
gh release list
gh release list --limit 20
gh release view v1.2.0
gh release view v1.2.0 --web
gh release view v1.2.0 --json tagName,isDraft,isPrerelease,assets
```

`gh release list` 的输出：

```text
TITLE   TYPE         TAG NAME  PUBLISHED
v1.2.0  Latest       v1.2.0    about 1 hour ago
v1.1.0  Pre-release  v1.1.0    about 1 day ago
```

## 下载

```bash
gh release download v1.2.0
gh release download v1.2.0 --pattern "*.zip"
gh release download v1.2.0 --dir ./downloads
gh release download --archive=zip       # 下载源码归档
```

不带 tag 时默认下载 Latest。

## 编辑与删除

```bash
gh release edit v1.2.0 --title "v1.2.0 正式版"
gh release edit v1.2.0 --notes-file CHANGELOG.md
gh release edit v1.2.0 --draft=false
gh release delete v1.2.0
gh release delete v1.2.0 --cleanup-tag    # 连 tag 一起删
```

**删除 Release 不会删除 tag**，除非加 `--cleanup-tag`。反过来，删除 tag 后 Release 也会消失。

## 典型发版流程

```bash
# 1. 确认主分支最新
git switch main && git pull

# 2. 打附注 tag
git tag -a v1.2.0 -m "release 1.2.0"

# 3. 推送 tag
git push origin v1.2.0

# 4. 创建 Release
gh release create v1.2.0 \
  --title "v1.2.0" \
  --generate-notes \
  --verify-tag

# 5. 上传构建产物
gh release upload v1.2.0 ./dist/*.zip
```

## 注意事项

1. **草稿 Release 不会出现在公开页面**，适合先写好再发布。`--draft=false` 或网页上点 Publish。
2. **`--generate-notes` 依赖规范的 PR 标题和标签**。提交信息混乱时生成结果也很混乱。
3. **Release 的 tag 最好已经推送**。用 `--verify-tag` 防止在错误的分支上创建。
4. **覆盖附件要用 `--clobber`**，否则同名上传会失败。
5. **删除 Release 前想清楚 tag 要不要留**。`--cleanup-tag` 会一起删，已有人拉取的 tag 不会自动消失。
6. **Latest 只有一个**。发布旧版本时用 `--latest=false`，避免把旧版本标成最新。
7. **Release 是公开的**。附件里的配置文件、日志不要包含密钥。

## 练习

1. 在测试仓库里打一个附注 tag 并推送，用 `gh release create` 创建 Release。
2. 上传一个附件，用 `gh release view --json assets` 确认。
3. 创建一个 draft Release，确认它不会出现在 `gh release list` 的公开列表中，再发布。
4. 用 `gh release download --pattern` 下载附件到指定目录。

---

上一篇：[gh run 与 workflow](04-run-and-workflow.md) · 下一篇：[gh gist](06-gist.md)
