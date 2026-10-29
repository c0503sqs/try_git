# submodule：子模块

## 能学到什么

- 子模块是什么，和普通目录的区别
- 添加、克隆、更新子模块
- 移除子模块的完整步骤
- 知道子模块最容易踩的坑

## 子模块是什么

子模块是**嵌套在仓库里的另一个 git 仓库**。父仓库不保存子模块的文件内容，只记录**它当前指向哪个提交**。

```text
parent-repo/
├── .gitmodules          # 子模块的 URL 和路径
├── libs/
│   └── lib/             # 实际是一个独立仓库
└── src/
```

父仓库里的记录长这样：

```text
160000 commit a1b2c3d...  libs/lib
```

`160000` 是 git 的特殊 mode，表示这是一个子模块提交引用。

## 添加

```bash
git submodule add https://github.com/owner/lib.git libs/lib
git commit -m "chore: 添加 lib 子模块"
```

会生成 `.gitmodules`：

```ini
[submodule "libs/lib"]
	path = libs/lib
	url = https://github.com/owner/lib.git
```

`.gitmodules` 要提交；子模块目录本身在父仓库里只记录哈希。

## 克隆带子模块的仓库

直接 `git clone` 只会得到空的子模块目录：

```bash
git clone --recurse-submodules https://github.com/owner/parent.git
```

已经克隆了但忘了加参数：

```bash
git submodule update --init --recursive
```

| 参数 | 作用 |
| --- | --- |
| `--init` | 初始化 `.gitmodules` 里登记的路径 |
| `--recursive` | 子模块里还有子模块时递归处理 |

## 查看状态

```bash
git submodule status
```

```text
 a1b2c3d... libs/lib (v1.2.0)
+a1b2c3e... libs/other (heads/main)
```

行首符号：

| 符号 | 含义 |
| --- | --- |
| 空格 | 和父仓库记录的提交一致 |
| `+` | 子模块当前提交和记录不一致 |
| `-` | 子模块未初始化 |

## 更新子模块

### 跟着父仓库的记录走

```bash
git submodule update
```

把子模块切回父仓库记录的那个提交。这是最常用的，保证和团队一致。

### 拉到子模块的最新

```bash
git submodule update --remote
git submodule update --remote --merge
git submodule update --remote --rebase
```

`--remote` 会去子模块的远端拉最新，默认跟踪子模块的默认分支。

### 批量执行

```bash
git submodule foreach 'git switch main && git pull'
git submodule foreach --recursive 'git status --short'
```

## 提交顺序

改了子模块里的代码：

```bash
cd libs/lib
git add -A && git commit -m "fix: ..." && git push

cd ../..
git add libs/lib          # 记录新的子模块提交
git commit -m "chore: 升级 lib 到新版本"
```

**必须先提交并推送子模块**，再提交父仓库。否则别人拉到的是一个远端不存在的提交。

## 移除子模块

```bash
git submodule deinit -f libs/lib
git rm libs/lib
rm -rf .git/modules/libs/lib
git commit -m "chore: 移除 lib 子模块"
```

三步缺一不可：

1. `deinit` 解除初始化
2. `git rm` 从父仓库索引和 `.gitmodules` 移除
3. 删 `.git/modules/` 里的缓存，否则以后重新添加同名子模块会冲突

## 子模块还是其他方案

| 方案 | 适合 |
| --- | --- |
| submodule | 需要固定到某个提交、多仓库协作 |
| subtree | 想把代码真正嵌进来，不想让使用者额外操作 |
| 包管理器 | 语言生态里的库，优先用 npm/pip/go mod |
| monorepo | 团队和发布节奏完全一致 |

多数情况下，**能用包管理器就不要用子模块**。子模块对使用者的要求更高。

## 注意事项

1. **子模块默认处于 detached HEAD**，直接改代码后提交不会在分支上。先 `git switch main` 或 `git switch -c fix`。
2. **子模块的改动不会被父仓库自动发现**。必须在父仓库 `git add libs/lib` 记录新提交。
3. **CI 要加 `--recurse-submodules`**，否则构建时子模块目录是空的。
4. **`.gitmodules` 的 URL 改了要同步**，只改本地 `.git/config` 不会影响别人。
5. **删除子模块不能只 `rm -rf`**，会留下索引记录和 `.git/modules` 缓存。
6. **子模块的提交可能丢失**：父仓库记录了哈希，但子模块仓库里那个提交没推送，别人就拉不到。
7. **权限要分别配置**：能访问父仓库不代表能访问子模块仓库。

## 练习

1. 创建两个本地仓库，用 `git submodule add` 把其中一个作为子模块加入另一个。
2. 用 `git clone --recurse-submodules` 克隆，确认子模块有内容。
3. 在子模块里提交并推送，再在父仓库记录新提交，观察 `git submodule status` 的 `+` 号。
4. 按三步移除子模块，确认 `.gitmodules` 和 `.git/modules` 都清理干净。

---

上一篇：[worktree：一份仓库多个工作区](02-worktree.md) · 下一篇：[LFS：管理大文件](04-lfs.md)
