# stash：临时存档

## 能学到什么

- 把未提交的改动暂存起来，切走再切回
- 区分 `pop` 和 `apply`
- 让 stash 包含未跟踪文件
- 知道 stash 不适合长期保存工作

## 解决什么问题

写到一半，突然要切分支修 bug，但当前改动不想提交。`git stash` 把工作区和暂存区的改动收起来，让工作区回到干净状态：

```bash
git stash push -m "WIP: 水果清单"
```

沙箱实测：

```text
Saved working directory and index state On main: WIP: 水果清单
```

```bash
git status -s      # 没有输出，工作区干净
git stash list
```

```text
stash@{0}: On main: WIP: 水果清单
```

## 取回

```bash
git stash pop      # 恢复并从列表删除
git stash apply    # 恢复但保留在列表
```

`pop` 的真实输出：

```text
On branch main
Changes not staged for commit:
  (use "git add <file>..." to update what will be committed)
  (use "git restore <file>..." to discard changes in working directory)
	modified:   fruits.txt

no changes added to commit (use "git add" and/or "git commit -a")
Dropped refs/stash@{0} (697eaf0b2634fc9793de11b74e28a4b02e438d7f)
```

区别：

| 命令 | 恢复内容 | 是否删除 stash |
| --- | --- | --- |
| `pop` | 是 | 是 |
| `apply` | 是 | 否 |

想先试一下能不能干净应用，用 `apply`；确认没问题再 `drop`。

## 常用操作

```bash
git stash list                  # 列表
git stash show                  # 改了哪些文件
git stash show -p               # 完整 diff
git stash show -p stash@{1}     # 看指定 stash
git stash drop                  # 删除最近一条
git stash drop stash@{1}        # 删除指定
git stash clear                 # 清空全部（不可恢复）
```

## 默认不包含什么

`git stash` 默认只存**已跟踪文件**的改动：

- 未跟踪的新文件：不存
- `.gitignore` 忽略的文件：不存

包含未跟踪文件：

```bash
git stash push -u -m "WIP: 新文件"
```

`-u` 是 `--include-untracked`。连被忽略的文件也要（慎用，可能很大）：

```bash
git stash push -a
```

## 只暂存一部分

```bash
git stash push -p
```

和 `git add -p` 一样逐块选择，只把一部分改动存进 stash。

保留暂存区的状态：

```bash
git stash push --keep-index
```

适合想「先提交已暂存的部分，剩下的收起来」。

## stash 存在哪里

每次 stash 都会创建一个提交对象，挂在 `refs/stash` 这个引用上，`stash@{0}`、`stash@{1}` 是 reflog 里的位置。

所以 stash **不属于某个分支**：在任何分支上 `pop` 都会把改动应用到当前分支。这也意味着，切分支后用 stash 恢复，可能产生冲突。

## 恢复时冲突

```bash
git stash pop
```

```text
Auto-merging fruits.txt
CONFLICT (content): Merge conflict in fruits.txt
```

和 merge 冲突一样，手动解决后：

```bash
git add fruits.txt
git stash drop      # 确认解决后再删除
```

如果搞砸了，stash 还在列表里（因为 pop 冲突时不会删除），可以 `git checkout -- .` 后重新 `git stash apply`。

## stash 还是新分支

| 场景 | 选择 |
| --- | --- |
| 几小时内就回来继续 | stash |
| 要放几天、可能忘 | 新建分支提交 |
| 需要在多个分支间搬改动 | stash 或 cherry-pick |
| 要保留提交历史 | 新分支 + WIP 提交 |

stash 是临时储物柜，不是版本管理。放太久会忘，也容易在 `clear` 时误删。长期未完成的工作建议提交到一条 WIP 分支。

## 注意事项

1. **`git stash clear` 没有确认提示**，直接清空全部。执行前先 `git stash list` 看一眼。
2. **stash 不是备份**。它存在 `.git/refs/stash` 和 reflog 里，reflog 过期后可能被清理。
3. **`pop` 冲突时 stash 不会删除**。这是好事，解决冲突后再手动 `drop`。
4. **stash 里的内容不会自动跟着分支走**。切到别的分支 `pop`，就是把这份改动应用过去。
5. **`-u` 要养成习惯**。新建文件没被 stash 收走，切分支后可能被带到别的分支上，造成困扰。
6. **stash 记录的是改动，不是快照**。如果 stash 之后又改了同一处，`pop` 会产生冲突而不是覆盖。

## 练习

1. 修改一个已跟踪文件，`git stash push -m "test"`，确认工作区干净，再 `git stash pop` 恢复。
2. 新建一个未跟踪文件，分别用不带 `-u` 和带 `-u` 的 stash，比较 `git stash show` 的结果。
3. 连续 stash 两次，用 `git stash list` 和 `stash@{1}` 取回较早的那一条。
4. 用 `git stash apply` 恢复后确认列表还在，再手动 `git stash drop`。

---

上一篇：[rebase：变基](03-rebase.md) · 下一篇：[reset、restore、revert](05-reset-restore-revert.md)
