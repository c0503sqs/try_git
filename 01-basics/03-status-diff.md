# status 与 diff

## 能学到什么

- 读懂 `git status` 的每一段
- 用 `-s` 的短格式快速判断改动在哪一侧
- 用 `diff` 的常用参数定位改动
- 知道未跟踪文件为什么不出现在 diff 里

## status：我现在处于什么状态

```bash
git status
```

沙箱里修改一个文件、新建一个文件后：

```text
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

分四段读：

| 段落 | 含义 |
| --- | --- |
| `On branch main` | 当前分支；如果处于 detached HEAD，这里会变 |
| `Changes to be committed` | 已暂存，下次 commit 会记录 |
| `Changes not staged for commit` | 已跟踪文件有改动，但没 add |
| `Untracked files` | 从未被 git 跟踪过的新文件 |

提示行里的命令可以直接照抄，git 已经按当前状态给出了最合适的下一步。

## 短格式 `-s`

```bash
git status -s
```

```text
 M fruits.txt
?? new.txt
```

两个字符分别表示**暂存区**和**工作区**的状态：

```text
 X          Y
 │          └─ 工作区相对暂存区
 └─ 暂存区相对 HEAD
```

| 输出 | 含义 |
| --- | --- |
| ` M` | 工作区改了，没 add |
| `M ` | 已 add，工作区没再改 |
| `MM` | 已 add，但 add 之后又改了 |
| `A ` | 新文件已暂存 |
| `AM` | 新文件已暂存，之后又改过 |
| ` D` / `D ` | 工作区删除 / 暂存删除 |
| `??` | 未跟踪 |
| `!!` | 被忽略（需要 `--ignored`） |

`-s` 加上 `-b` 还能看到分支和领先/落后情况：

```bash
git status -sb
```

```text
## main...origin/main [ahead 2]
```

## diff：改了什么

默认比较**工作区 ↔ 暂存区**：

```bash
git diff
```

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

逐行拆解：

| 行 | 含义 |
| --- | --- |
| `a/fruits.txt` `b/fruits.txt` | 旧版本 / 新版本 |
| `index f9d4f5a..7e092e5 100644` | 前后 blob 哈希和文件 mode |
| `@@ -2,3 +2,4 @@` | 旧文件从第 2 行起 3 行；新文件从第 2 行起 4 行 |
| `+elderberry` | 新增（`-` 是删除，空格是上下文） |

## 常用参数

```bash
git diff --staged            # 暂存区 ↔ HEAD（即将提交的内容）
git diff HEAD                # 工作区 ↔ HEAD（全部未提交改动）
git diff --stat              # 只看每个文件改了几行
git diff --name-only         # 只看文件名
git diff --name-status       # 文件名 + 状态（M/A/D）
git diff --word-diff         # 按词比较，适合改长段落
git diff main..feature       # 两个分支之间
git diff HEAD~2 HEAD         # 最近两次提交之间
git diff -- src/             # 只看某个目录
git diff -U0                 # 只显示改动行，不带上下文
```

`--stat` 的输出：

```text
 fruits.txt | 1 +
 1 file changed, 1 insertion(+)
```

## 什么时候用哪个

| 场景 | 命令 |
| --- | --- |
| 提交前确认要提交什么 | `git diff --staged` |
| 想看看自己都改了什么 | `git diff HEAD` |
| 只想看文件名 | `git diff --name-only` |
| 看某次提交改了什么 | `git show <commit>` |
| 在某分支上对比另一分支 | `git diff main...feature` |

> `A..B` 和 `A...B` 的区别：两个点表示两端直接比较；三个点表示从**共同祖先**到 B 的改动，也就是「这个分支相对主分支新增了什么」，review 时更常用。

## 未跟踪文件不出现在 diff 里

```bash
echo "grape" > new.txt
git diff          # 什么都没有
git status -s     # ?? new.txt
```

这是设计使然：diff 比较的是「已知内容」，新文件还没有旧版本可比。想看它的内容，先标记为 intent-to-add：

```bash
git add -N new.txt
git diff          # 现在会显示 new.txt 的全部新增行
```

## 注意事项

1. **`git diff` 不显示已暂存内容**。add 之后再看 `git diff` 是空的，别误以为改动丢了，用 `--staged`。
2. **`git status` 的输出会随版本微调**，但四个段落的结构十年没变。
3. **二进制文件只显示 `Binary files ... differ`**。要比较二进制，用 `git diff --no-index a.bin b.bin` 也只能告诉你不一致。
4. **大仓库里 `git status` 慢**，多半是文件太多或有巨型未跟踪目录。用 `.gitignore` 排除，或 `git status --untracked-files=no`。
5. **`git diff` 默认会调用分页器**（`less`）。按 `q` 退出；想整屏输出用 `git --no-pager diff`。

## 练习

1. 在沙箱里制造「已暂存 + 工作区又改」的状态，用 `git status -s` 找到 `MM`，再用两种 diff 分别查看。
2. 用 `git diff --stat` 和 `git diff --name-status` 对比同一组改动，说出两者信息的差别。
3. 新建一个未跟踪文件，先用 `git diff` 确认看不到，再用 `git add -N` 让它出现。

---

上一篇：[init、add、commit](02-init-add-commit.md) · 下一篇：[log：查看历史](04-log.md)
