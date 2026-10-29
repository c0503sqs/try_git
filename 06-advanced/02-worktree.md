# worktree：一份仓库多个工作区

## 能学到什么

- 用 worktree 同时检出多个分支
- 不靠 stash 在分支间切换
- 清理和排查 worktree
- 知道它的限制

## 解决什么问题

正在 `feature` 上改代码，线上突然要修 bug。传统做法是 stash 或提交半成品，切到 `main`，修完再切回来。

worktree 让你**在另一个目录同时检出 `main`**，两个目录共享同一个 `.git` 历史，互不干扰：

```text
repo/                  ← main
repo-hotfix/           ← hotfix 分支
repo-review/           ← 别人的 PR 分支
```

不需要复制仓库，也不需要 stash。

## 创建

```bash
git worktree add ../repo-hotfix hotfix
```

在 `../repo-hotfix` 检出一条已有的 `hotfix` 分支。

基于某个分支新建分支：

```bash
git worktree add -b hotfix/urgent ../repo-hotfix main
```

基于某个提交：

```bash
git worktree add --detach ../repo-inspect a1b2c3d
```

## 查看

```bash
git worktree list
```

```text
/Users/me/repo           bcf6ece [main]
/Users/me/repo-hotfix    9190fb4 [hotfix]
```

每行：路径、当前提交、检出的分支。

## 删除

```bash
git worktree remove ../repo-hotfix
```

有未提交改动时会被拒绝，加 `--force` 强删（**会丢改动**）。

目录被手动删掉后，元数据还在，用：

```bash
git worktree prune
```

清理失效记录。`git worktree list` 也会提示 stale。

## 典型用法

### 紧急修复

```bash
git worktree add -b hotfix/login ../repo-hotfix main
cd ../repo-hotfix
# 改代码、测试、提交、推送
cd ../repo
git worktree remove ../repo-hotfix
```

原来的 `feature` 目录完全没动，连 stash 都不需要。

### 同时跑两个分支的测试

```bash
git worktree add ../repo-v1 release/1.0
cd ../repo-v1 && npm test
```

两个版本各自有 `node_modules`，互不覆盖。

### 审查别人的 PR

```bash
git fetch origin pull/123/head:pr-123
git worktree add ../repo-pr-123 pr-123
```

### 长时间构建

构建产物在独立目录，不污染开发目录。

## 限制

1. **同一个分支不能同时在两个 worktree 检出**：

   ```text
   fatal: 'main' is already checked out at '/Users/me/repo'
   ```

   需要的话用 `--detach` 或新建分支。

2. **worktree 共享对象库和 refs**。在一个 worktree 里 `git fetch`，另一个也能看到新提交；但各自有独立的 `HEAD`、索引和工作区。
3. **不能把 worktree 放进仓库目录内部**，会互相干扰。放在同级或外部目录。
4. **裸仓库也能加 worktree**，适合服务器上同时部署多个分支。

## 和 clone 的对比

| | worktree | 再 clone 一份 |
| --- | --- | --- |
| 磁盘 | 共享 `.git` 对象，省空间 | 完整复制 |
| 同步 | 共享 refs，fetch 一次全有 | 各自 fetch |
| 分支冲突 | 同一分支不能重复检出 | 无限制 |
| 隔离性 | 共享配置和 hooks | 完全独立 |
| 适合 | 临时切换、并行测试 | 长期独立环境 |

## 注意事项

1. **删除 worktree 用 `git worktree remove`**，不要直接 `rm -rf`。直接删会留下失效记录，要 `prune` 清理。
2. **`--force` 会丢未提交改动**，执行前 `git -C <path> status` 确认。
3. **worktree 里的 `.git` 是一个文件**，内容是 `gitdir: /path/to/main/.git/worktrees/...`，不是目录。
4. **hooks 和配置是共享的**，在 worktree 里改 `core.hooksPath` 会影响主仓库。
5. **分支删除前先移除对应 worktree**，否则 `git branch -d` 会提示分支被检出。
6. **CI 和脚本里不要假设当前目录是仓库根**，worktree 的路径不同。

## 练习

1. 在主仓库执行 `git worktree add -b test/wt ../repo-wt main`，用 `git worktree list` 查看。
2. 在 worktree 里提交一次，回到主仓库 `git log --all` 确认能看到这个提交。
3. 尝试在主仓库检出 `test/wt`，观察被拒绝的提示。
4. 用 `git worktree remove` 删除，再用 `git worktree prune` 清理手动删除的残留。

---

上一篇：[bisect：二分定位坏提交](01-bisect.md) · 下一篇：[submodule：子模块](03-submodule.md)
