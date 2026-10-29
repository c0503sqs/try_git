# reset、restore、revert：三种撤销

## 能学到什么

- 用一张表判断「撤销」该用哪条命令
- 分清 `reset --soft` / `--mixed` / `--hard` 各动哪些区
- 知道 `restore` 和 `revert` 的适用场景
- 明白哪些操作一旦执行就无法用 reflog 找回

## 先看决策表

| 你想做的事 | 命令 | 改写历史 | 已推送的分支安全吗 |
| --- | --- | --- | --- |
| 丢弃工作区改动 | `git restore <file>` | 否 | 安全 |
| 取消暂存（add 错了） | `git restore --staged <file>` | 否 | 安全 |
| 撤销上一次提交，改动保留在暂存区 | `git reset --soft HEAD~1` | 是（本地） | 不安全 |
| 撤销上一次提交，改动保留在工作区 | `git reset HEAD~1` | 是（本地） | 不安全 |
| 撤销上一次提交，改动直接丢弃 | `git reset --hard HEAD~1` | 是（本地） | 不安全 |
| 撤销一次已推送的提交 | `git revert <commit>` | 否（新增提交） | 安全 |

一句话记忆：

- **`restore` 管文件，`reset` 管提交指针，`revert` 管历史记录。**

## reset：移动当前分支的指针

`reset` 的本质是把当前分支指向另一个提交，然后可选地重置暂存区和工作区。

```text
reset --soft  ：只移动 HEAD（分支指针）
reset --mixed ：移动 HEAD + 重置暂存区（默认）
reset --hard  ：移动 HEAD + 重置暂存区 + 覆盖工作区
```

### 实际效果

沙箱里有三个提交：

```text
fd9f3e2 feat: 添加 date
856f1e4 feat: 添加水果清单
b8a27b6 docs: 初始化沙箱项目
```

执行 `git reset --soft HEAD~1`：

```text
$ git status -s
M  fruits.txt

$ git log --oneline
856f1e4 feat: 添加水果清单
b8a27b6 docs: 初始化沙箱项目
```

提交没了，但改动**留在暂存区**（第一列 `M`），可以直接重新提交。

接着执行 `git reset`（默认 mixed）：

```text
$ git status -s
 M fruits.txt
```

暂存区也重置了，改动**留在工作区**，需要重新 `git add`。

再执行 `git reset --hard`：

```text
$ git status -s
$ git log --oneline
856f1e4 feat: 添加水果清单
b8a27b6 docs: 初始化沙箱项目
```

工作区也被覆盖，改动**彻底消失**。

### `--hard` 会丢什么

- 已暂存但未提交的改动
- 未暂存的工作区改动
- **不会**删除未跟踪文件

未跟踪文件要用：

```bash
git clean -fd      # 删除未跟踪文件和目录（先加 -n 预览）
```

`git clean -n` 是 dry-run，**养成先预览的习惯**。

## restore：从某个版本还原文件

```bash
git restore fruits.txt                    # 用暂存区覆盖工作区
git restore --staged fruits.txt           # 取消暂存，工作区不动
git restore --source=HEAD~1 fruits.txt    # 从上一个提交还原工作区文件
git restore --source=HEAD~1 --staged --worktree fruits.txt  # 两边都还原
```

`--staged` 等价于旧写法 `git reset HEAD <file>`；`--worktree` 等价于旧写法 `git checkout -- <file>`。

还原整个目录：

```bash
git restore --source=HEAD~2 src/
```

## revert：生成一个反向提交

`revert` 不移动指针，而是新建一个「抵消某次改动」的提交：

```text
A──B──C──D        A──B──C──D──D'
                    D' 抵消了 C 的改动
```

```bash
git revert <commit>
```

会打开编辑器让你写提交信息，默认是：

```text
Revert "feat: 添加 date"

This reverts commit a8636f3...
```

常用参数：

```bash
git revert --no-commit <commit>   # 只改工作区，不自动提交（可连续 revert 多个）
git revert --no-edit <commit>     # 用默认信息，不打开编辑器
git revert -m 1 <merge-commit>    # 撤销合并提交，保留第一父提交（主线）
```

`revert` 也可能冲突，解决方式与 merge 相同。

## 合并提交怎么撤

合并提交有两个父提交，必须告诉 git「保留哪一边」：

```bash
git revert -m 1 <merge-hash>
```

`-m 1` 表示以第一父提交（通常是合并前所在的分支）为主线。撤销合并后再想重新合并同一分支，需要先 revert 那次 revert，否则 git 认为改动已经在历史里了。

## 实际场景对照

| 场景 | 做法 |
| --- | --- |
| 改乱了文件，想回到上次提交 | `git restore <file>` |
| `git add` 了不该加的文件 | `git restore --staged <file>` |
| 提交信息写错，还没推送 | `git commit --amend` |
| 提交内容漏了文件，还没推送 | `git add <file>` + `git commit --amend --no-edit` |
| 最近一次提交完全不要了，但想保留代码 | `git reset --soft HEAD~1` |
| 最近三次提交都要撤，代码也不要 | `git reset --hard HEAD~3` |
| 已经推送的错误提交 | `git revert <commit>` + `git push` |
| 合并提交要撤 | `git revert -m 1 <merge>` |

## 注意事项

1. **`reset --hard` 不经过确认**，也不进回收站。执行前用 `git status` 和 `git stash` 保护现场。
2. **`reset --hard` 救不回未提交的改动**。reflog 只记录提交和指针移动，没被 commit 过的内容不在里面。
3. **`reset` 只适合本地分支**。已推送的分支 reset 后必须 force push，会破坏别人的历史。
4. **`revert` 是安全的撤销**，因为它只增加提交。团队分支上优先用它。
5. **`revert` 不会「删除」代码**，只是再改一次。历史里那次错误提交仍然可见。
6. **`git restore` 会覆盖未保存的改动**，且无法撤销。它和 `reset --hard` 一样需要先确认。
7. **`git checkout -- <file>` 仍然可用**，但语义含糊，新代码统一用 `restore`。

## 练习

1. 在沙箱里提交一次，分别用 `--soft`、默认、`--hard` 三种 reset 撤销，每次用 `git status -s` 和 `git log --oneline` 记录差异。
2. 用 `git restore --source=HEAD~1 fruits.txt` 把文件还原到上一个提交的版本，再用 `git diff` 确认。
3. 在一个已推送到本地裸仓库的分支上，用 `git revert` 撤销一次提交，确认不需要 force push。
4. 用 `git reset --hard HEAD~1` 之后，立刻 `git reflog` 找到刚才的提交并恢复（见下一课）。

---

上一篇：[stash：临时存档](04-stash.md) · 下一篇：[reflog：后悔药](06-reflog.md)
