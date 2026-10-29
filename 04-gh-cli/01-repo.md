# gh repo

## 能学到什么

- 用 `gh` 创建、克隆、查看、编辑仓库
- 从本地已有仓库一键建远端并推送
- fork 与同步
- 哪些操作需要额外权限

## 前置检查

```bash
gh auth status
```

没登录先看 [gh 登录与权限](../00-setup/02-gh-auth.md)。

## 创建仓库

交互式：

```bash
gh repo create
```

非交互：

```bash
gh repo create my-project --public --clone
gh repo create my-org/my-project --public
```

从**本地已有仓库**创建远端并推送：

```bash
cd my-project
gh repo create my-project --private --source=. --remote=origin --push
```

参数说明（来自 `gh repo create --help`）：

| 参数 | 作用 |
| --- | --- |
| `--public` / `--private` / `--internal` | 可见性，三选一 |
| `--source <path>` | 用本地目录作为源 |
| `--remote <name>` | 远端名，默认 `origin` |
| `--push` | 创建后推送本地提交 |
| `--clone` | 创建后克隆到本地 |
| `--add-readme` | 自动加 README |
| `--gitignore <模板>` | 例如 `Node`、`Python` |
| `--license <协议>` | 例如 `mit`、`apache-2.0` |
| `-d, --description` | 仓库描述 |

> `--push` 会把你的提交发布到远端。如果仓库是 public，等于立刻公开代码。执行前确认目录里没有密钥和隐私文件。

## 克隆与浏览

```bash
gh repo clone owner/repo
gh repo clone owner/repo my-dir
gh repo view
gh repo view owner/repo
gh repo view --web
```

`gh repo view` 不带参数时读取当前目录对应的仓库。

结构化输出（适合脚本）：

```bash
gh repo view --json name,description,defaultBranchRef,visibility
```

```json
{"defaultBranchRef":{"name":"main"},"description":"","name":"repo","visibility":"PUBLIC"}
```

## 列出仓库

```bash
gh repo list
gh repo list owner --limit 50
gh repo list --json name,visibility,updatedAt --jq '.[] | "\(.name) \(.visibility)"'
```

默认只列当前账号的仓库；`gh repo list <org>` 列组织的。

## 编辑

```bash
gh repo edit --description "Git 学习项目"
gh repo edit --visibility private
gh repo edit --default-branch main
gh repo edit --add-topic git,github,cli
gh repo edit --remove-topic old-topic
gh repo edit --enable-issues
gh repo edit --enable-wiki=false
```

修改可见性、默认分支这类操作影响所有协作者，执行前确认。

## fork 与同步

```bash
gh repo fork owner/repo --clone
gh repo fork owner/repo --remote
gh repo sync
gh repo sync --branch main
```

`gh repo sync` 在服务端把上游的提交同步到你的 fork，不需要本地 fetch。细节见 [fork 与 upstream](../03-remotes/04-fork-and-upstream.md)。

## 删除与改名

```bash
gh repo delete owner/repo --yes
gh repo rename new-name
gh repo archive owner/repo
```

删除是不可逆的。`gh` 会要求输入仓库名确认；`--yes` 跳过提示，**不要在脚本里随手加**。

需要的 token scope：

| 操作 | scope |
| --- | --- |
| 读公开仓库 | 无 |
| 读写仓库 | `repo` |
| 删除仓库 | `delete_repo`（默认不给） |
| 组织内创建 | `read:org` + 组织权限 |

补 scope：

```bash
gh auth refresh -s delete_repo
```

## 打开网页

```bash
gh browse                 # 当前仓库首页
gh browse src/main.ts     # 某个文件
gh browse 42              # issue/PR 编号
gh browse --settings      # 仓库设置页
```

## 注意事项

1. **`--source=.` 要求当前目录已经是 git 仓库**。不是的话先 `git init` 并提交。
2. **`--push` 不会推送所有分支和 tag**，默认只推当前分支。需要全推时手动 `git push --all` 和 `git push --tags`。
3. **`gh repo delete` 需要 `delete_repo` scope**，默认 token 没有。报错 `HTTP 403` 时先 refresh。
4. **`gh repo edit --visibility` 改成 public 会暴露历史**。公开前的提交、已删除文件仍在历史里。
5. **fork 后不要忘了配 upstream**，否则无法同步原项目。
6. **`gh repo view` 在非仓库目录会报错**，可以用 `-R owner/repo` 指定仓库。

## 练习

1. 在一个测试目录里 `git init`、提交一次，用 `gh repo create <名字> --private --source=. --push` 建远端。
2. 用 `gh repo view --json name,visibility` 确认仓库信息。
3. 用 `gh repo edit --add-topic test,learning` 给仓库加标签，再在网页上确认。
4. 用 `gh repo clone` 把仓库克隆到另一个目录，比较和直接 `git clone` 的差别。

---

上一篇：[Pull Request 流程](../03-remotes/05-pull-request-flow.md) · 下一篇：[gh issue](02-issue.md)
