# reflog：后悔药

## 能学到什么

- 用 reflog 找回 reset、rebase、删除分支丢掉的提交
- 读懂 `HEAD@{n}` 的含义
- 知道 reflog 的保留期限
- 知道 reflog 救不了什么

## reflog 记录什么

只要 `HEAD` 移动，git 就记一条：提交、切换分支、reset、rebase、merge、cherry-pick。它记录的是**你本地这个仓库发生过什么**，不随推送共享。

```bash
git reflog
```

沙箱里的真实输出：

```text
f2d2729 HEAD@{0}: rebase (start): checkout main
a4eea09 HEAD@{1}: checkout: moving from main to feature
f2d2729 HEAD@{2}: reset: moving to HEAD
f2d2729 HEAD@{3}: commit: feat: 把 cherry 改成 cherry-tart
7b85d58 HEAD@{4}: checkout: moving from feature to main
a4eea09 HEAD@{5}: commit: feat: 把 cherry 改成 cherry-pie
7b85d58 HEAD@{6}: checkout: moving from feature to feature
7b85d58 HEAD@{7}: commit: feat: 添加 date
```

读法：

| 部分 | 含义 |
| --- | --- |
| `f2d2729` | 当时 `HEAD` 指向的提交 |
| `HEAD@{0}` | 最近一次移动；数字越大越早 |
| `rebase (start): checkout main` | 发生了什么操作 |

`HEAD@{0}` 是现在，`HEAD@{10}` 是往前第 10 次移动。也可以用时间：`HEAD@{yesterday}`、`HEAD@{2.hours.ago}`。

## 三种典型救援

### 1. reset --hard 之后想反悔

```bash
git reset --hard HEAD~1     # 手滑，提交没了

git reflog
# 找到 reset 之前那条，比如 HEAD@{1}

git reset --hard HEAD@{1}
```

### 2. 删除分支后找回

```bash
git branch -D feature       # 分支和它的提交一起从分支列表消失

git reflog
# 找到 feature 最后所在的提交，比如 a4eea09

git branch feature a4eea09
```

提交对象还在，只要 reflog 里有记录就能重新建分支。

### 3. rebase 搞砸了

```bash
git reflog
# 找到 rebase (start) 之前的位置

git reset --hard HEAD@{5}
```

rebase 会把自己也记进 reflog（`rebase (start)`、`rebase (finish)`），所以整段操作可以回滚。

## 看某个分支的 reflog

```bash
git reflog show main
git reflog show feature
```

分支自己的 reflog 记录它指向过哪些提交，即使 `HEAD` 没动过。

## reflog 会过期

reflog 不是永久档案。默认保留期：

| 类型 | 默认 | 配置项 |
| --- | --- | --- |
| 可达提交的 reflog | 90 天 | `gc.reflogExpire` |
| 不可达提交的 reflog | 30 天 | `gc.reflogExpireUnreachable` |

查看当前设置：

```bash
git config --get gc.reflogExpire
git config --get gc.reflogExpireUnreachable
```

过了期限，`git gc` 会清理，提交对象也可能被删除。**重要的救援要尽快做，并立刻建分支固定住。**

## reflog 救不了什么

| 丢的东西 | 能否用 reflog 找回 |
| --- | --- |
| 已提交的提交（reset/rebase/删分支导致） | 能 |
| 从未提交的工作区改动（`git restore`、`reset --hard` 覆盖） | **不能** |
| 未跟踪文件被 `git clean -fd` 删除 | **不能** |
| stash 被 `git stash clear` 清空 | 通常不能（stash 也是 reflog，但 `clear` 后难恢复） |
| 已推送到远端、又被别人 force push 覆盖的提交 | 本地 reflog 可能还有，尽快找 |

`git reset --hard` 覆盖掉的未提交改动，从来没有进入任何 git 对象，reflog 里没有它的位置。这也是为什么危险操作前先 `git stash` 或提交一次。

## 找「悬空」提交

reflog 里也没有时，还可以试试：

```bash
git fsck --lost-found
```

会列出没有被任何引用指向的悬空提交（dangling commit）。它们可能来自被删的分支、被丢弃的 rebase 提交。找到后：

```bash
git show <hash>
git branch rescue <hash>
```

这是最后手段，不保证能找到。

## 注意事项

1. **reflog 是本地的**。换一台机器、重新 clone，就没有别人的 reflog。
2. **`HEAD@{n}` 会随着新操作变化**。救援时先 `git reflog` 看当前编号，不要照抄教程里的数字。
3. **reflog 记录的是引用移动，不是文件内容**。它指向提交对象，不保存工作区快照。
4. **`git reflog expire --expire=now --all` 会立即清空**，之后 `git gc` 可能删除对象。除非确定，不要执行。
5. **救援后立刻建分支**：`git branch rescue <hash>`，否则后续操作可能让这个提交再次变成不可达。
6. **`git reflog` 输出也会分页**，按 `q` 退出。

## 练习

1. 在沙箱里提交一次，`git reset --hard HEAD~1`，再 `git reflog` 找到并恢复。
2. 创建 `feature/tmp` 并提交，`git branch -D feature/tmp`，再用 reflog 找回并重建分支。
3. 用 `git reflog show main` 看主分支自己的移动记录，和 `git reflog` 对比。
4. 查一下 `gc.reflogExpire` 的默认值，说出你的提交在多长时间内还能被 reflog 找到。

---

上一篇：[reset、restore、revert](05-reset-restore-revert.md) · 下一篇：[remote、fetch、pull、push](../03-remotes/01-remote-fetch-pull-push.md)
