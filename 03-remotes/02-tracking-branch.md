# 追踪分支

## 能学到什么

- 理解本地分支、远程分支、追踪关系三者的区别
- 用 `-vv` 和 `status -sb` 看领先/落后
- 手动建立、修改、解除追踪关系
- 清理远端已删除的分支

## 三种「分支」

| 名字 | 例子 | 存在哪 | 谁能改 |
| --- | --- | --- | --- |
| 本地分支 | `main` | `.git/refs/heads/main` | 你 |
| 远程追踪分支 | `origin/main` | `.git/refs/remotes/origin/main` | 只能由 `fetch` 更新 |
| 追踪关系 | `main` → `origin/main` | `.git/config` | 你 |

`origin/main` **不是你直接提交的分支**，它是「上次 fetch 时远端 main 的样子」。所以它可能过时，`git fetch` 才会刷新。

追踪关系是一条配置：

```ini
[branch "main"]
    remote = origin
    merge = refs/heads/main
```

意思是：本地 `main` 默认从 `origin` 的 `main` 拉取、往那里推送。

## 查看追踪关系

```bash
git branch -vv
```

```text
* main bcf6ece [origin/main] feat: 添加 date
```

方括号里就是追踪目标。如果显示 `[origin/main: ahead 2, behind 1]`，说明本地比远端多 2 个提交、少 1 个提交。

```bash
git status -sb
```

```text
## main...origin/main [behind 1]
```

| 状态 | 含义 |
| --- | --- |
| `ahead N` | 本地有 N 个提交没推 |
| `behind N` | 远端有 N 个提交没拉 |
| `ahead N, behind M` | 双方都有新提交，历史已分叉 |
| 没有方括号 | 两边一致，或没有追踪关系 |

## 建立追踪关系

### 推送时建立

```bash
git push -u origin main
```

```text
branch 'main' set up to track 'origin/main'.
```

### 切换时自动建立

如果远端已有同名分支：

```bash
git switch feature/login
# 自动创建本地分支并追踪 origin/feature/login
```

### 手动设置

```bash
git branch --set-upstream-to=origin/main main
# 简写
git branch -u origin/main
```

### 指定不同的名字

```bash
git branch --track feature origin/feature/login
```

## 解除追踪

```bash
git branch --unset-upstream
```

之后 `git push` / `git pull` 不再默认找这个远端分支，需要显式写 `git push origin HEAD`。

## 拉取和推送的默认行为

建立了追踪关系后：

```bash
git pull        # = git fetch origin + 合并 origin/main
git push        # = git push origin main
```

没建立时，git 会提示：

```text
fatal: The current branch feature has no upstream branch.
To push the current branch and set the remote as upstream, use

    git push --set-upstream origin feature
```

## 清理已删除的远端分支

别人删了远端分支，你本地的 `origin/xxx` 还在：

```bash
git fetch --prune
```

```text
 - [deleted]         (none)     -> origin/feature/login
```

也可以只清理某个 remote：

```bash
git remote prune origin
```

本地分支不会被自动删除，需要你手动 `git branch -d feature/login`。

## `origin/HEAD` 是什么

`origin/HEAD` 指向远端仓库的默认分支：

```bash
git branch -r
```

```text
  origin/HEAD -> origin/main
  origin/main
```

它决定了 `git clone` 之后自动切到哪个分支。远端默认分支改名后，本地用 `git remote set-head origin -a` 刷新。

## 注意事项

1. **`origin/main` 只在你 `fetch` 时更新**。`git log origin/main` 看到的是上次 fetch 的快照，不是实时状态。
2. **`ahead` / `behind` 基于上次 fetch**。想确认最新差距，先 `git fetch`。
3. **分叉后不能直接 push**。`ahead 2, behind 1` 时先 `pull --rebase` 或 merge，再推。
4. **删除本地分支不影响远端**，删除远端分支也不影响本地。两边要分别删。
5. **`git push -u` 只需第一次**。之后 `git push` 就够。
6. **多远端时追踪关系容易混**。fork 场景下本地 `main` 通常追踪 `upstream/main` 还是 `origin/main`，要按团队流程统一。

## 练习

1. 在沙箱里 `git push -u origin main`，用 `git branch -vv` 和 `git status -sb` 确认追踪关系。
2. 在克隆目录里提交并推送，回到原仓库 `git fetch`，用 `git status -sb` 观察 `behind 1`。
3. 用 `git branch --unset-upstream` 解除追踪，再 `git push`，看 git 的提示。
4. 在裸仓库里删除一个分支，回到本地 `git fetch --prune`，确认 `origin/xxx` 消失。

---

上一篇：[remote、fetch、pull、push](01-remote-fetch-pull-push.md) · 下一篇：[tag 与版本号](03-tag.md)
