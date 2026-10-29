# fork 与 upstream

## 能学到什么

- fork 和 clone 的区别
- 给自己的 fork 配 `origin`，给原仓库配 `upstream`
- 把上游的新提交同步到自己的分支
- 用 `gh` 简化 fork 和同步

## fork 和 clone

| | fork | clone |
| --- | --- | --- |
| 发生在哪 | GitHub 服务端 | 本地 |
| 结果 | 你账号下多一个仓库副本 | 本地多一份代码 |
| 目的 | 参与别人的项目 | 获取代码 |
| 权限 | 你对 fork 有写权限 | 取决于原仓库 |

参与开源项目的典型路径：

```text
原项目 owner/repo
        │  fork（GitHub 网页或 gh）
        ▼
你的账号 you/repo
        │  clone
        ▼
本地 ~/repo
        │  push 分支
        ▼
you/repo 的分支 → 向 owner/repo 发 Pull Request
```

## 标准配置：origin + upstream

```bash
gh repo fork owner/repo --clone
# 或手动：
git clone https://github.com/you/repo.git
cd repo
git remote add upstream https://github.com/owner/repo.git
```

```bash
git remote -v
```

```text
origin	https://github.com/you/repo.git (fetch)
origin	https://github.com/you/repo.git (push)
upstream	https://github.com/owner/repo.git (fetch)
upstream	https://github.com/owner/repo.git (push)
```

| 名字 | 指向 | 你有写权限吗 |
| --- | --- | --- |
| `origin` | 你的 fork | 有 |
| `upstream` | 原项目 | 通常没有 |

拉取和推送的方向：

```bash
git fetch upstream          # 从原项目拿最新代码
git push origin feature     # 推到你自己的 fork
```

## 同步上游

```bash
git switch main
git fetch upstream
git merge upstream/main     # 或 git rebase upstream/main
git push origin main
```

用 rebase 保持线性：

```bash
git fetch upstream
git rebase upstream/main
git push --force-with-lease origin main
```

> 只对自己的 fork 分支 force push。你的 fork 的 main 通常只有你在用，但如果有别人 clone 了它，要提前说。

## 用 gh 简化

```bash
gh repo fork owner/repo --clone          # fork 并克隆
gh repo fork owner/repo --remote          # 在当前仓库添加 fork 远端
gh repo sync                              # 把上游同步到 fork
gh repo sync --branch main                # 只同步某个分支
```

`gh repo sync` 是服务端操作，不需要本地先 fetch，很省事。

## 开发流程

```bash
# 1. 同步主分支
git switch main
git fetch upstream
git merge --ff-only upstream/main

# 2. 开功能分支
git switch -c fix/typo

# 3. 提交并推送到 fork
git push -u origin fix/typo

# 4. 用 gh 向上游发 PR
gh pr create --repo owner/repo --base main --head you:fix/typo
```

第 4 步的 `--repo` 指向**上游仓库**，`--head` 写成 `你的用户名:分支名`。在 fork 的 PR 页面点「Compare & pull request」也可以。

## 保持 PR 分支最新

上游有新的提交、你的 PR 落后时，GitHub 会提示「This branch is out-of-date」。两种处理：

```bash
# 方式一：把上游合并进来（产生合并提交）
git fetch upstream
git merge upstream/main
git push origin fix/typo

# 方式二：变基到上游最新（历史干净，需要 force push）
git fetch upstream
git rebase upstream/main
git push --force-with-lease origin fix/typo
```

维护者通常接受两种，按项目 CONTRIBUTING 里的要求选。

## 删除 fork 后重建

fork 关系是永久的，删除 fork 不会断开和上游的关系。重新 fork 时 GitHub 可能提示「already forked」，去 Settings 里删除旧 fork 或直接新建。

## 注意事项

1. **`origin` 和 `upstream` 是约定，不是语法**。但团队和教程都这么用，别改成别的名字。
2. **不要在 `upstream/main` 上直接提交**。你没有写权限，推不上去。
3. **同步上游前先提交或 stash**。`merge` / `rebase` 遇到未提交改动会拒绝执行。
4. **rebase 后推 fork 要 force-with-lease**。普通 push 会因历史不同被拒绝。
5. **PR 合并后可以删除 fork 里的功能分支**。上游已经接收，保留只会让分支列表变乱。
6. **fork 的 main 也要定期同步**，否则新分支总是基于旧代码。

## 练习

1. 用 `gh repo fork <某个公开仓库> --clone` 创建一个 fork（或手动 clone 后 `git remote add upstream`）。
2. 用 `git remote -v` 确认 origin 和 upstream 的地址。
3. `git fetch upstream` 后，用 `git log HEAD..upstream/main --oneline` 查看上游有多少新提交。
4. 同步后创建一条本地分支，推到 origin，用 `gh pr create --repo` 向上游发一个（可关闭的）PR。

---

上一篇：[tag 与版本号](03-tag.md) · 下一篇：[Pull Request 流程](05-pull-request-flow.md)
