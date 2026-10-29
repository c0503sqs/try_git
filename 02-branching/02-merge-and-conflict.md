# merge 与冲突解决

## 能学到什么

- 分清 fast-forward 和 three-way merge
- 读懂冲突标记，手动解决冲突
- 用 `--no-ff` / `--ff-only` 控制合并方式
- 合并到一半想反悔怎么办

## 两种合并

### fast-forward

如果当前分支是目标分支的祖先，git 只需要把指针往前挪：

```text
合并前：  A──B──C (main)
                 ╲
                  D──E (feature)

合并后：  A──B──C──D──E (main, feature)
```

没有新提交，历史是一条直线。

```bash
git switch main
git merge feature
```

```text
Updating c3a1b2d..e5f6a7b
Fast-forward
 fruits.txt | 2 ++
 1 file changed, 2 insertions(+)
```

### three-way merge

两个分支都有对方没有的提交时，git 会找到共同祖先，把两边的改动合起来，生成一个**合并提交**：

```text
       D──E (feature)
      ╱
 A──B──C──F──G (main)
```

```bash
git merge feature
```

```text
Merge made by the 'ort' strategy.
 fruits.txt | 1 +
 1 file changed, 1 insertion(+)
```

合并提交有两个父提交，`git log --graph` 里表现为一个分叉再汇合。

## 冲突是怎么产生的

冲突**不是**「两个分支都改了文件」，而是「两边改了同一个文件的**同一段**」，git 无法自动判断该保留哪个。

复现（沙箱里的真实过程）：

```bash
git switch -c feature
# 把 cherry 改成 cherry-pie
git commit -am "feat: 把 cherry 改成 cherry-pie"

git switch main
# 把 cherry 改成 cherry-tart
git commit -am "feat: 把 cherry 改成 cherry-tart"

git merge feature
```

```text
Auto-merging fruits.txt
CONFLICT (content): Merge conflict in fruits.txt
Automatic merge failed; fix conflicts and then commit the result.
```

```bash
git status
```

```text
On branch main
You have unmerged paths.
  (fix conflicts and run "git commit")
  (use "git merge --abort" to abort the merge)

Unmerged paths:
  (use "git add <file>..." to mark resolution)
	both modified:   fruits.txt
```

## 冲突标记

打开文件：

```text
apple
banana
<<<<<<< HEAD
cherry-tart
=======
cherry-pie
>>>>>>> feature
date
```

| 标记 | 含义 |
| --- | --- |
| `<<<<<<< HEAD` | 从这里开始是**当前分支**（main）的内容 |
| `=======` | 分隔线 |
| `>>>>>>> feature` | 到这里结束是**被合并分支**（feature）的内容 |

## 解决冲突

三步：

```bash
# 1. 编辑文件，删掉标记，留下最终想要的内容
#    可以保留一边、另一边，也可以合并成新内容
cherry-tart

# 2. 标记为已解决
git add fruits.txt

# 3. 完成合并
git commit
```

`git commit` 会打开编辑器，默认信息是：

```text
Merge branch 'feature'
```

保存退出即可。也可以直接 `git commit -m "merge: 合并 feature 分支"`。

合并后的历史：

```text
*   <merge commit>
|\
| * a4eea09 feat: 把 cherry 改成 cherry-pie
* | f2d2729 feat: 把 cherry 改成 cherry-tart
|/
* 7b85d58 feat: 添加 date
```

## 不想合了：abort

```bash
git merge --abort
```

回到 `git merge` 之前的状态，工作区恢复干净。**只在还没 `git commit` 完成合并时有效。**

如果已经开始解决并 `git add` 了一部分，`--abort` 也能撤销，但你在冲突文件里手写的内容会丢失。拿不准就先复制一份。

## 控制合并方式

```bash
git merge --no-ff feature    # 即使能 fast-forward 也生成合并提交
git merge --ff-only feature  # 只允许 fast-forward，否则拒绝
git merge --squash feature   # 把 feature 的所有改动压成一个未提交的改动
```

什么时候用：

| 参数 | 场景 |
| --- | --- |
| 默认 | 个人分支、能 FF 就 FF，历史干净 |
| `--no-ff` | 团队要求保留「这个功能是一条分支」的结构 |
| `--ff-only` | 主分支只接受线性历史，避免意外合并 |
| `--squash` | 分支提交太碎，只想在主分支留一个提交 |

`--squash` 之后要自己 `git commit`，因为它只改工作区和暂存区，不生成合并提交。

## 合并时的其他冲突类型

| 类型 | 提示 | 处理 |
| --- | --- | --- |
| 内容冲突 | `both modified` | 手动编辑，见上 |
| 删除/修改冲突 | `deleted by us` / `deleted by them` | `git rm <file>` 或 `git add <file>` 二选一 |
| 新增/新增冲突 | `both added` | 同内容冲突 |
| 重命名冲突 | `rename/rename` | 决定保留哪个路径 |

删除/修改冲突的判断：

```bash
git rm path/to/file    # 接受删除
git add path/to/file   # 保留文件
```

## 用图形工具

```bash
git mergetool
```

需要先配置工具（VS Code、meld、Beyond Compare 等）。VS Code 用户也可以直接打开冲突文件，编辑器会显示「Accept Current / Incoming / Both」按钮。

## 注意事项

1. **解决冲突后必须 `git add`**。只改文件不 add，git 仍认为未解决，`git commit` 会拒绝。
2. **不要留冲突标记**。`<<<<<<<`、`=======`、`>>>>>>>` 进入代码会直接报语法错误。提交前全局搜一遍。
3. **冲突解决是一次人工决策**，不是「选一边就完事」。两边改动都有价值时，合并成新逻辑更常见。
4. **合并提交也有冲突**。在合并提交上再合并另一分支时，冲突可能更难读，建议先合并上游再处理。
5. **`git merge --abort` 不能撤销已完成的合并**。已经 commit 的合并要用 `git reset --hard HEAD~1` 或 `git revert -m 1 <merge>`。
6. **合并前先更新目标分支**。在 `main` 上 `git pull` 后再 `git merge feature`，能减少「本地看着没问题、推上去冲突」的情况。

## 练习

1. 在沙箱里按上面的步骤制造一次冲突，手动保留两边内容（两行都留），提交后用 `git log --graph --all` 观察合并提交。
2. 再做一次冲突，这次用 `git merge --abort` 放弃，确认 `git status` 回到干净状态。
3. 用 `--no-ff` 合并一个能 fast-forward 的分支，对比 `git log --graph` 的差异。

---

上一篇：[branch 与 switch](01-branch-switch.md) · 下一篇：[rebase：变基](03-rebase.md)
