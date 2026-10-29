# branch 与 switch

## 能学到什么

- 理解分支本质上只是一个「指向提交的指针」
- 创建、切换、重命名、删除分支
- `-vv` 看清每个分支领先/落后远端多少
- 知道 detached HEAD 是什么，以及怎么安全退出

## 分支是什么

分支不是文件夹的副本，也不是一份代码拷贝。它只是一个**指向某个提交的指针**，存在 `.git/refs/heads/` 里，内容就是一行哈希。

```text
                    main
                     │
  ●────●────●────●───●
                     ▲
                     │
                  feature
```

创建分支 = 新写一个指针；切换分支 = 把 `HEAD` 指到另一个指针上，然后更新工作区文件。所以分支的创建和删除几乎是瞬时的。

`HEAD` 是一个特殊的指针，指向「当前所在的分支」：

```text
HEAD → refs/heads/main → a8636f3
```

## 查看分支

```bash
git branch
```

```text
* main
```

`*` 表示当前分支。

```bash
git branch -vv
```

```text
* main a8636f3 feat: 添加 date
```

`-vv` 会额外显示每个分支指向的提交，以及它追踪的远端分支和领先/落后数量。多人协作时这是最快了解全局的方式。

其他查看方式：

```bash
git branch -a        # 本地 + 远端
git branch -r        # 只看远端
git branch --show-current   # 只输出当前分支名，适合脚本
```

## 创建与切换

```bash
git switch -c feature        # 创建并切换
git switch main              # 切回 main
git switch -                 # 回到上一个分支（类似 cd -）
```

`-c` 是 `--create`。想基于某个提交创建：

```bash
git switch -c hotfix a8636f3
```

旧写法（git 2.23 之前，现在仍可用）：

```bash
git checkout -b feature
git checkout main
```

`checkout` 同时负责切分支和还原文件，容易混淆；2.23 之后拆成了 `switch`（切分支）和 `restore`（还原文件）。**新代码建议只用 `switch` 和 `restore`。**

## 重命名与删除

```bash
git branch -m old-name new-name   # 重命名
git branch -m new-name            # 重命名当前分支
git branch -d feature             # 删除已合并的分支
git branch -D feature             # 强制删除（未合并也删）
```

`-d` 会检查这个分支是否已经合并进当前分支；没合并时拒绝删除，防止丢提交。`-D` 跳过检查，**只在确认不需要时才用**。删错了用 [reflog](06-reflog.md) 可以找回。

## detached HEAD

直接切到一个提交（而不是分支名）时，`HEAD` 不再指向任何分支，叫 detached HEAD：

```bash
git switch --detach HEAD~1
```

```text
HEAD is now at f183ba8 feat: 添加水果清单
```

这时可以看代码、做实验、提交，但**新提交不在任何分支上**。一旦切走，那些提交就只能靠 reflog 找回。

```bash
git switch -        # 回到上一个分支
```

```text
Previous HEAD position was f183ba8 feat: 添加水果清单
Switched to branch 'main'
```

想保留 detached 状态下做的提交：

```bash
git switch -c experiment    # 在当前提交上建一个新分支
```

## 分支的常见工作模式

| 模式 | 分支名示例 | 用途 |
| --- | --- | --- |
| 功能分支 | `feature/login` | 一个功能一条分支 |
| 修复分支 | `fix/export-crash` | 一个 bug 一条分支 |
| 发布分支 | `release/1.4` | 准备发版 |
| 环境分支 | `main`、`develop` | 长期存在的主线 |

命名用 `/` 分隔层级，`git branch` 会按字母序排列，`feature/` 开头的分支会聚在一起。

## 注意事项

1. **切换分支前先处理未提交的改动**。改动会跟着你走；如果目标分支上同一文件有冲突，git 会拒绝切换。要么提交，要么 [stash](04-stash.md)。
2. **删除分支只删指针，不删提交**。提交对象还在，直到垃圾回收（默认 90 天后）才可能被清理，期间都能用 reflog 找回。
3. **`git branch -d` 的判断依据是「是否合并进当前分支」**，不是「是否合并进 main」。在 feature 分支上删另一个分支时要留意。
4. **远端分支不能直接 `git branch -d`**。本地删除用 `git push origin --delete <branch>`；同时要清理本地的追踪引用 `git fetch --prune`。
5. **detached HEAD 不一定是错误**。看历史版本、做临时实验、CI 里 checkout 某个 commit 都会进入这个状态，知道怎么退出就行。

## 练习

1. 在沙箱里创建 `feature/a`，切过去提交一次，再切回 `main`，用 `git log --oneline --graph --all` 观察两条线的位置。
2. 用 `git branch -vv` 查看分支指向，确认 `feature/a` 比 `main` 多一个提交。
3. 用 `git switch --detach HEAD~1` 进入 detached HEAD，再用 `git switch -` 回来。
4. 在 `feature/a` 上提交后不合并，尝试 `git branch -d feature/a`，看 git 如何拒绝；再用 `-D` 删除。

---

上一篇：[.gitignore](../01-basics/05-gitignore.md) · 下一篇：[merge 与冲突解决](02-merge-and-conflict.md)
