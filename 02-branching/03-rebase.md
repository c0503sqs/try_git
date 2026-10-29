# rebase：变基

## 能学到什么

- 理解 rebase 和 merge 的本质区别
- 解决 rebase 过程中的冲突
- 用 `rebase -i` 整理提交
- 知道「不要 rebase 公开历史」这条铁律

## rebase 做了什么

rebase 把当前分支上的提交**逐个复制**到另一个分支的最新提交之后。原提交被丢弃，新提交内容相同但哈希不同。

```text
rebase 前：
       D──E (feature)
      ╱
 A──B──C──F──G (main)

rebase 后：
              D'──E' (feature)
             ╱
 A──B──C──F──G (main)
```

结果是一条直线，没有合并提交。`D'`、`E'` 是新建的提交，哈希和原来的 `D`、`E` 不同。

```bash
git switch feature
git rebase main
```

## merge 还是 rebase

| | merge | rebase |
| --- | --- | --- |
| 历史形状 | 分叉 + 合并提交 | 一条直线 |
| 是否改写提交 | 否 | 是（哈希全变） |
| 冲突处理 | 一次性解决 | 每个提交都可能冲突 |
| 适合 | 合并到共享分支 | 整理本地未推送的提交 |

常见策略：**在功能分支上 rebase 主分支，合并时用 merge（或快进）**。这样功能分支保持线性，主分支保留「合并了哪个功能」的记录。

## 冲突处理

在沙箱里实测：

```text
$ git rebase main
Rebasing (1/1)Auto-merging fruits.txt
CONFLICT (content): Merge conflict in fruits.txt
error: could not apply a4eea09... feat: 把 cherry 改成 cherry-pie
hint: Resolve all conflicts manually, mark them as resolved with
hint: "git add/rm <conflicted_files>", then run "git rebase --continue".
hint: You can instead skip this commit: run "git rebase --skip".
hint: To abort and get back to the state before "git rebase", run "git rebase --abort".
Could not apply a4eea09... feat: 把 cherry 改成 cherry-pie
```

此时 `git status -s`：

```text
UU fruits.txt
```

处理流程：

```bash
# 1. 编辑文件，删掉冲突标记
# 2. 标记已解决
git add fruits.txt

# 3. 继续变基
git rebase --continue
```

其他出口：

```bash
git rebase --skip     # 跳过这个提交（内容会丢）
git rebase --abort    # 回到 rebase 之前
```

> rebase 冲突和 merge 冲突的标记一样，但**每一步的「HEAD」含义不同**：rebase 时 HEAD 是「已经放好的位置」，另一边是「正在复制的提交」。

## 交互式 rebase

```bash
git rebase -i HEAD~3
```

会打开编辑器，列出最近 3 个提交（从旧到新）：

```text
pick 48138fd docs: 初始化沙箱项目
pick f183ba8 feat: 添加水果清单
pick a8636f3 feat: 添加 date
```

把 `pick` 改成别的指令：

| 指令 | 作用 |
| --- | --- |
| `pick` | 保留提交 |
| `reword` | 改提交信息，内容不变 |
| `edit` | 停下让你修改内容（然后 `git commit --amend` + `git rebase --continue`） |
| `squash` | 合并进上一个提交，并编辑合并后的信息 |
| `fixup` | 合并进上一个提交，丢弃这条信息 |
| `drop` | 删除这个提交 |
| `exec` | 执行一条 shell 命令 |

### 合并多个提交

```text
pick 48138fd docs: 初始化沙箱项目
pick f183ba8 feat: 添加水果清单
fixup a8636f3 feat: 添加 date
```

后两条会被压成一条。常用于把「写完功能 + 修 review 意见」的几个提交整理成一个。

### 修改提交信息

```bash
git rebase -i HEAD~3
# 把要改的那行改成 reword
```

### 删除提交

```bash
git rebase -i HEAD~3
# 把对应行改成 drop，或直接删掉那一行
```

## 顺序很重要

交互式列表是**从旧到新**排列的，和 `git log` 相反。改动的顺序决定提交的顺序，`squash` 只会向上合并到前一个提交。

## 铁律：不要 rebase 公开历史

已经被别人拉取、或者已经合并进主分支的提交，**不要 rebase**。因为哈希变了，别人的分支和你的分叉，会产生大量重复提交和冲突。

判断标准：

- 提交只在你本地 → 随便 rebase
- 提交已经 `push` 到共享分支 → 不要 rebase
- 提交在你自己 fork 的、只有你用的分支 → 可以 rebase，但推送时要用 `--force-with-lease`

已经推送的分支 rebase 后推送：

```bash
git push --force-with-lease
```

`--force-with-lease` 会在远端有你没见过的提交时拒绝推送，比 `--force` 安全。仍然会改写远端历史，团队协作分支上要先沟通。

## 其他常用形式

```bash
git rebase main                 # 把当前分支变基到 main
git rebase --onto main old-base feature   # 把 feature 中 old-base 之后的提交搬到 main
git pull --rebase               # 拉取时用 rebase 而不是 merge
git rebase --autosquash         # 自动识别 fixup!/squash! 开头的提交信息
git rebase --exec "npm test"    # 每个提交后跑一次测试
```

`git pull --rebase` 是很多人默认开启的配置：

```bash
git config --global pull.rebase true
```

它让「拉取」不产生无意义的合并提交。

## 注意事项

1. **rebase 会改写哈希**。所有提交都会变成新对象，`git log` 里的旧哈希消失（但 reflog 还留着）。
2. **冲突要解决多次**。rebase 逐个应用提交，同一个文件的冲突可能在多个提交上重复出现。
3. **`--skip` 是丢提交**，不是「稍后处理」。跳过前确认这个提交的改动别处也有。
4. **rebase 前先建一个备份分支**：`git branch backup-feature`。出问题可以 `git reset --hard backup-feature`。
5. **交互式 rebase 只能改本地提交**。改历史范围和 `HEAD~N` 要数清楚，数错了会重写不该动的提交。
6. **rebase 后不要直接 `git push`**。远端还是旧历史，普通推送会被拒绝；需要 force-with-lease。

## 练习

1. 在沙箱里创建 feature 分支并提交两次，main 上提交一次，然后 `git rebase main`，用 `--graph` 确认历史变成直线。
2. 制造一次 rebase 冲突，解决后 `git rebase --continue`，观察提交哈希变化（用 reflog 对比）。
3. 用 `git rebase -i HEAD~3` 把后两个提交 `fixup` 成一个，确认 `git log` 只剩两条。
4. 在 rebase 前建备份分支，rebase 后用 `git reset --hard backup` 恢复，体会备份的作用。

---

上一篇：[merge 与冲突解决](02-merge-and-conflict.md) · 下一篇：[stash：临时存档](04-stash.md)
