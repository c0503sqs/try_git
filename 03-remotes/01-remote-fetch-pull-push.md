# remote、fetch、pull、push

## 能学到什么

- remote 是什么，怎么查看和修改
- `fetch` 和 `pull` 的区别
- 推送被拒时怎么处理
- `--force-with-lease`、`--prune` 这些常用参数

## remote 是什么

remote 是本地仓库里保存的一个**远端地址的别名**。`origin` 只是约定俗成的默认名字，不是关键字。

```bash
git remote -v
```

```text
origin	../remote-origin.git (fetch)
origin	../remote-origin.git (push)
```

同一个 remote 可以有独立的 fetch 和 push 地址（比如从公开仓库拉、往自己的 fork 推）。

## 管理 remote

```bash
git remote add origin https://github.com/user/repo.git
git remote rename origin upstream
git remote remove origin
git remote set-url origin git@github.com:user/repo.git
git remote show origin
```

`git remote show origin` 会显示远端 HEAD 分支、追踪关系和推送策略：

```text
* remote origin
  Fetch URL: ../remote-origin.git
  Push  URL: ../remote-origin.git
  HEAD branch: main
  Remote branch:
    main tracked
  Local branch configured for 'git pull':
    main merges with remote main
  Local ref configured for 'git push':
    main pushes to main (up to date)
```

不克隆也能查看远端有什么：

```bash
git ls-remote origin
```

```text
bcf6ece...	HEAD
bcf6ece...	refs/heads/main
bcf6ece...	refs/tags/v1.0.0
```

## fetch：只下载，不动工作区

```bash
git fetch
```

```text
From ../remote-origin
   bcf6ece..9190fb4  main       -> origin/main
```

它把远端的新提交下载到本地，更新 `origin/main` 这个**远程追踪引用**，但**不修改你的工作区、不移动你的分支**。

fetch 之后：

```bash
git status -sb
```

```text
## main...origin/main [behind 1]
```

你知道自己落后一个提交，但代码还没变。这时可以：

```bash
git log HEAD..origin/main --oneline    # 看看别人改了什么
git merge origin/main                  # 或者 git rebase origin/main
```

**先 fetch 再决定怎么合并**，是最安全的工作方式。

## pull：fetch + 合并

```bash
git pull
```

```text
Updating bcf6ece..9190fb4
Fast-forward
 fruits.txt | 1 +
 1 file changed, 1 insertion(+)
```

等价于：

```bash
git fetch
git merge origin/main
```

如果配置了 `pull.rebase true`，则等价于 `git fetch` + `git rebase origin/main`。

常用的显式写法：

```bash
git pull --ff-only        # 只允许快进，否则报错
git pull --rebase         # 拉取后用 rebase 而不是 merge
git pull --no-rebase      # 强制用 merge
```

## push：把本地提交发到远端

```bash
git push -u origin main
```

```text
To ../remote-origin.git
 * [new branch]      main -> main
branch 'main' set up to track 'origin/main'.
```

`-u`（`--set-upstream`）把本地 `main` 和 `origin/main` 关联起来。之后直接 `git push` / `git pull` 就知道该找谁。

推送本地分支到远端同名分支：

```bash
git push origin feature/login
```

推送到不同名字：

```bash
git push origin local-name:remote-name
```

## 推送被拒

```text
! [rejected]        main -> main (fetch first)
error: failed to push some refs to 'origin'
hint: Updates were rejected because the remote contains work that you do
hint: not have locally. This is usually caused by another repository pushing
hint: to the same ref. You may want to first integrate the remote changes
hint: (e.g., 'git pull ...') before pushing again.
```

原因：远端有你没有的提交，直接推会覆盖别人的工作。处理：

```bash
git pull --rebase     # 把你的提交放到远端最新提交之后
git push
```

不要用 `git push --force` 绕过，除非你确认这个分支只有你在用。

## 常用参数

| 命令 | 作用 |
| --- | --- |
| `git fetch --prune` | 清理远端已删除分支对应的本地追踪引用 |
| `git push --force-with-lease` | 强制推送，但远端有新提交时拒绝 |
| `git push --tags` | 推送所有 tag（默认不推） |
| `git push origin --delete feature` | 删除远端分支 |
| `git push origin :feature` | 同上，旧写法 |
| `git fetch --all` | 拉取所有 remote |
| `git push --dry-run` | 预演，不真正推送 |

## 删除远端分支

```bash
git push origin --delete feature/login
```

```text
To ../remote-origin.git
 - [deleted]         feature/login
```

本地对应的追踪引用不会立刻消失，执行 `git fetch --prune` 或 `git remote prune origin` 清理。

## 注意事项

1. **`fetch` 不会改变你的代码**。看到 `behind 1` 不处理也没关系，但 merge/rebase 之前要先 fetch。
2. **`pull` 可能产生合并提交**。团队用 rebase 流程时，配 `git config pull.rebase true`。
3. **`--force` 会覆盖远端历史**。优先用 `--force-with-lease`，它在远端有新提交时保护你。
4. **推送的是提交，不是工作区**。没 commit 的改动不会被推上去。
5. **tag 默认不推送**。发版后忘了 `git push origin v1.0.0`，远端就没有这个版本。
6. **`origin` 不是必须叫 origin**。多远端时（fork + upstream）命名清楚，见 [fork 与 upstream](04-fork-and-upstream.md)。
7. **大文件推不上去**多半超过 GitHub 的 100 MB 单文件限制，用 Git LFS，见 [LFS](../06-advanced/04-lfs.md)。

## 练习

1. 在 `.sandbox/` 里创建一个裸仓库作为远端，给本地仓库添加 remote 并 `push -u`。
2. 用另一个目录 clone 这个裸仓库，提交一次并 push；回到原仓库 `git fetch`，用 `git status -sb` 看到 `behind 1`。
3. 分别用 `git pull --ff-only` 和 `git pull --rebase` 拉取，比较 `git log --graph` 的结果。
4. 用 `git push --dry-run` 预演一次推送，确认它没有真的改变远端。

---

上一篇：[reflog：后悔药](../02-branching/06-reflog.md) · 下一篇：[追踪分支](02-tracking-branch.md)
