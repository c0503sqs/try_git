# 三区模型：工作区、暂存区、版本库

## 能学到什么

- 说清 git 的三个区域各自存什么
- 知道 `add`、`commit`、`restore` 分别在三个区之间搬运什么
- 用 `git diff` 的三个变体分别查看三种差异

这是整个 git 最重要的心智模型。理解了它，后面的命令都不用死记。

## 三个区

```text
 工作区                暂存区                  版本库
 Working Tree    →     Index / Stage     →    Repository
 （你编辑的文件）      （下一次提交的内容）      （已提交的历史）

   git add ───────────────┘
                          git commit ───────────┘

   ←──── git restore ─────  ←──── git restore --staged ────
```

| 区域 | 英文 | 存什么 | 怎么看 |
| --- | --- | --- | --- |
| 工作区 | working tree | 你当前磁盘上的文件 | 编辑器、`cat`、`ls` |
| 暂存区 | index / stage | 下一次 `commit` 会记录的快照 | `git diff --staged`、`git ls-files --stage` |
| 版本库 | repository / `HEAD` | 已提交的历史 | `git log`、`git show` |

## 关键认知：commit 记录的是暂存区

你改了文件但没 `git add`，`git commit` **不会**把改动带进去。因为 commit 拍的是暂存区这张快照，不是你磁盘的当前状态。

```bash
echo "apple" > fruits.txt
git add fruits.txt      # 把「apple」这一版放进暂存区

echo "banana" >> fruits.txt   # 工作区又变了，但暂存区还是只有 apple

git commit -m "feat: 添加 apple"
# 这次提交里只有 apple，banana 还在工作区
```

这也是为什么 `git add` 被叫做「暂存」而不是「保存」：它挑出你**想**提交的那部分内容。

## 三种差异，三组命令

`git diff` 的默认行为容易让人困惑，记住这张表：

| 命令 | 比较对象 | 看什么 |
| --- | --- | --- |
| `git diff` | 工作区 ↔ 暂存区 | 我改了但**还没 add** 的内容 |
| `git diff --staged` | 暂存区 ↔ 最新提交 | 我 add 了、**将要提交**的内容 |
| `git diff HEAD` | 工作区 ↔ 最新提交 | 所有未提交的改动（add 的和没 add 的） |

`git diff --staged` 也可以写成 `git diff --cached`，两者等价。

## 真实对照

修改 `fruits.txt` 并新建文件后：

```text
$ git status
On branch main
Changes not staged for commit:
  (use "git add <file>..." to update what will be committed)
  (use "git restore <file>..." to discard changes in working directory)
	modified:   fruits.txt

Untracked files:
  (use "git add <file>..." to include in what will be committed)
	new.txt

no changes added to commit (use "git add" and/or "git commit -a")
```

`git diff` 显示工作区的改动：

```text
diff --git a/fruits.txt b/fruits.txt
index f9d4f5a..7e092e5 100644
--- a/fruits.txt
+++ b/fruits.txt
@@ -2,3 +2,4 @@ apple
 banana
 cherry
 date
+elderberry
```

执行 `git add fruits.txt` 之后：

```text
$ git status -s
M  fruits.txt
?? new.txt
```

第一列 `M` 表示**暂存区**有改动，第二列空格表示工作区没有未暂存的改动。这时 `git diff` 是空的，`git diff --staged` 才有内容。

## 三个区的撤销方向

| 想撤销什么 | 命令 | 影响 |
| --- | --- | --- |
| 工作区的改动 | `git restore <file>` | 用暂存区覆盖工作区，**改动丢失** |
| 暂存（取消 add） | `git restore --staged <file>` | 暂存区回到 `HEAD`，工作区不动 |
| 已提交的提交 | `git revert <commit>` | 生成一个反向提交，历史保留 |

`git restore` 和 `git switch` 是 git 2.23 才拆出来的命令，更早的教程里对应 `git checkout -- <file>` 和 `git checkout <branch>`。两种写法现在都能用，但 `restore` / `switch` 语义更清楚，建议优先用。

## 怎么「看见」暂存区

```bash
git ls-files --stage
```

会列出暂存区里每个文件的 mode、blob 哈希和路径：

```text
100644 138965309af59899400ca205cffb54259386c951 0	README.md
100644 f9d4f5ab4cfda7debd7b9b1db383ca9227b565ba 0	fruits.txt
```

`git cat-file -p f9d4f5a` 可以看那个快照里的内容：

```text
apple
banana
cherry
date
```

这是 git 内部结构的入口，日常不需要，但能帮你确认「暂存区到底是文件还是差异」——**是完整的文件快照**，不是 diff。

## 注意事项

1. **`git commit -a` 会跳过新文件**。`-a` 只把「已跟踪文件的修改」自动 add，未跟踪文件仍然不会进提交。
2. **`git add` 之后又改文件，会出现两个版本**：暂存区是 add 时的那一版，工作区是最新的。`git status` 会显示 `MM`。
3. **`git diff` 看不到未跟踪文件**。新建的文件只有 `git status` 能看见，要先 `git add -N <file>` 才会出现在 diff 里。
4. **`git restore` 不可撤销**。它直接用暂存区内容覆盖工作区，被覆盖的改动没有 reflog 可救（因为从未被 git 记录）。
5. **提交前养成看 `git diff --staged` 的习惯**。它就是你即将提交的内容，比 `git status` 更准确。

## 练习

1. 在沙箱里修改 `fruits.txt`，执行 `git status -s`，确认第一列是空格、第二列是 `M`。
2. 执行 `git add fruits.txt`，再 `git status -s`，确认变成 `M `（M 在第一列）。
3. 在暂存之后继续修改文件，观察状态变成 `MM`，分别用 `git diff` 和 `git diff --staged` 看两份不同的内容。
4. 用 `git restore --staged fruits.txt` 取消暂存，再 `git restore fruits.txt` 丢弃改动，回到干净状态。

---

上一篇：[gh 登录与权限](../00-setup/02-gh-auth.md) · 下一篇：[init、add、commit](02-init-add-commit.md)
