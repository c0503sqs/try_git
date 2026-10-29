# hooks：本地钩子

## 能学到什么

- 知道 git 在哪些时机调用钩子
- 写一个 pre-commit 检查
- 让钩子跟随仓库分发
- 知道钩子的局限

## 钩子是什么

钩子是 git 在特定操作前后自动执行的脚本，放在 `.git/hooks/`。文件名固定，不需要注册。

```text
.git/hooks/
├── pre-commit.sample
├── commit-msg.sample
├── pre-push.sample
└── ...
```

去掉 `.sample` 后缀并加上可执行权限，就会生效。

## 常用客户端钩子

| 钩子 | 触发时机 | 典型用途 |
| --- | --- | --- |
| `pre-commit` | 执行 `git commit` 前 | lint、跑测试、检查大文件 |
| `prepare-commit-msg` | 打开提交信息编辑器前 | 自动填模板、加 issue 号 |
| `commit-msg` | 提交信息写完后 | 校验 Conventional Commits 格式 |
| `pre-push` | 推送前 | 跑完整测试、阻止推 main |
| `post-checkout` | 切换分支/检出后 | 安装依赖、提示 |
| `post-merge` | 合并后 | 同步依赖 |
| `pre-rebase` | rebase 前 | 阻止对已推送分支 rebase |

服务端钩子（`pre-receive`、`update`、`post-receive`）在 GitHub 上不能自定义，只能通过 Rulesets 和 Actions 实现类似约束。

## 写一个 pre-commit

```bash
#!/usr/bin/env bash
set -euo pipefail

# 1. 检查是否有大文件
for f in $(git diff --cached --name-only); do
  size=$(wc -c < "$f" 2>/dev/null || echo 0)
  if [ "$size" -gt 5000000 ]; then
    echo "拒绝提交：$f 超过 5 MB"
    exit 1
  fi
done

# 2. 跑 lint
npm run lint
```

放到 `.git/hooks/pre-commit`：

```bash
chmod +x .git/hooks/pre-commit
```

退出码非 0 会阻止提交。

## 让钩子进入版本库

`.git/hooks/` 不会被提交。团队共享钩子的两种做法：

### 方法一：core.hooksPath

把钩子放在仓库的 `.githooks/`：

```bash
mkdir -p .githooks
# 写入 .githooks/pre-commit
chmod +x .githooks/pre-commit

git config core.hooksPath .githooks
```

把配置写进文档或安装脚本，新成员执行一次即可。可以加一个 `Makefile` 或 `scripts/setup.sh`：

```bash
#!/usr/bin/env bash
git config core.hooksPath .githooks
chmod +x .githooks/*
```

### 方法二：工具管理

| 工具 | 语言生态 |
| --- | --- |
| husky | Node |
| lefthook | 多语言，Go 编写 |
| pre-commit | Python，配置式 |
| overcommit | Ruby |

以 husky 为例：

```bash
npm install -D husky
npx husky init
echo "npm test" > .husky/pre-commit
```

工具的好处是配置简单、跨平台；代价是引入依赖。

## 校验提交信息

`commit-msg` 钩子接收一个参数：提交信息文件路径。

```bash
#!/usr/bin/env bash
msg=$(head -1 "$1")
if ! echo "$msg" | grep -qE '^(feat|fix|docs|style|refactor|perf|test|build|ci|chore|revert)(\(.+\))?: .+'; then
  echo "提交信息不符合 Conventional Commits：$msg"
  exit 1
fi
```

规范细节见 `try_markdown` 的「提交信息与 PR 描述」一课。

## 绕过钩子

```bash
git commit --no-verify -m "..."
git push --no-verify
```

`--no-verify` 跳过 `pre-commit` 和 `commit-msg`。**钩子是本地约束，不是安全边界**，所以 CI 里仍要跑同样的检查。

## 注意事项

1. **钩子不会被 clone**。新成员必须手动安装或跑初始化脚本。
2. **钩子可以绕过**。`--no-verify`、换机器、直接改 `.git` 都能跳过，重要检查必须放进 CI。
3. **钩子要快**。pre-commit 跑 30 秒会让人想关掉它，只做增量检查。
4. **Windows 上要注意 shebang 和换行**。脚本用 `#!/usr/bin/env bash`，避免 CRLF。
5. **`core.hooksPath` 是相对仓库根的路径**，不要写成绝对路径。
6. **钩子失败时提交不会发生**，但已经 `git add` 的内容还在暂存区，修完直接再 commit。
7. **不要用钩子做部署**，服务端事件用 Actions 或 Webhooks。

## 练习

1. 写一个 `pre-commit`，检查暂存区里是否有 `console.log`，有就阻止提交。
2. 用 `core.hooksPath` 把钩子放到 `.githooks/`，提交后在新目录 clone 并验证需要手动启用。
3. 写一个 `commit-msg` 钩子校验 Conventional Commits 前缀。
4. 用 `git commit --no-verify` 绕过，确认 CI 仍能拦住问题。

---

上一篇：[LFS：管理大文件](04-lfs.md) · 下一篇：[签名提交](06-signed-commits.md)
