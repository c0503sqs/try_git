# 练习 1：制造并解决一次冲突

## 目标

在沙箱里制造一次内容冲突，手动保留两边的改动，完成合并。全程不碰主仓库。

## 准备

```bash
labs/new-sandbox.sh conflict --force
cd .sandbox/conflict
```

确认起点：

```bash
git log --oneline
```

应该是 3 个提交，`fruits.txt` 里有 `apple / banana / cherry / date`。

## 任务

1. 创建分支 `feature/a`，把 `cherry` 改成 `cherry-pie`，提交。
2. 切回 `main`，把 `cherry` 改成 `cherry-tart`，提交。
3. 在 `main` 上合并 `feature/a`，制造冲突。
4. 解决冲突：**两行都保留**，最终文件里既有 `cherry-pie` 也有 `cherry-tart`。
5. 完成合并提交。
6. 用 `git log --oneline --graph --all` 确认合并结构。

## 验收标准

- [ ] `git status` 显示工作区干净
- [ ] `fruits.txt` 里没有 `<<<<<<<`、`=======`、`>>>>>>>`
- [ ] `fruits.txt` 同时包含 `cherry-pie` 和 `cherry-tart`
- [ ] `git log --graph` 能看到一个合并提交和两条父线
- [ ] 没有修改主仓库的任何文件

## 提示

- 冲突标记的三段分别是什么含义？
- `git add` 在解决冲突流程里起什么作用？
- 不想要这次合并时，用什么命令退出？

## 完成后

对照 [参考答案](01-solution.md)，确认每一步的命令和输出。

---

上一篇：[从 issue 到 release](../07-workflows/01-issue-to-release.md) · 下一篇：[练习 2：撤销一次误操作](02-undo.md)
