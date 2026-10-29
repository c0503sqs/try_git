# Git / gh 一页速查

## 配置

```bash
git config --global user.name "名字"
git config --global user.email "邮箱"
git config --global init.defaultBranch main
git config --global core.quotepath false
git config --list --show-origin
git config --global alias.lg "log --oneline --graph --all --decorate"
```

## 日常

```bash
git init -b main
git clone <url>
git status
git status -sb
git add <file>
git add -p
git add -A
git commit -m "feat: ..."
git commit --amend --no-edit
git diff
git diff --staged
git diff HEAD
```

## 分支

```bash
git branch
git branch -vv
git switch main
git switch -c feature/x
git switch -
git branch -d feature/x
git branch -D feature/x
git branch -m old new
git switch --detach <commit>
```

## 合并与变基

```bash
git merge feature
git merge --no-ff feature
git merge --abort
git rebase main
git rebase -i HEAD~3
git rebase --continue
git rebase --abort
git cherry-pick <commit>
```

## 撤销

```bash
git restore <file>                  # 丢弃工作区改动
git restore --staged <file>         # 取消暂存
git reset --soft HEAD~1             # 撤销提交，保留暂存
git reset HEAD~1                    # 撤销提交，保留工作区
git reset --hard HEAD~1             # 撤销提交并丢弃改动
git revert <commit>                 # 生成反向提交
git revert -m 1 <merge-commit>      # 撤销合并
git clean -nd                       # 预览未跟踪文件
git clean -fd                       # 删除未跟踪文件
```

## 历史与找回

```bash
git log --oneline --graph --all --decorate
git log --stat -1
git log -p -- <file>
git log -S "字符串"
git log --author="名字" --since="2 weeks ago"
git show <commit>
git blame <file>
git reflog
git reset --hard HEAD@{n}
git fsck --lost-found
```

## 暂存与远程

```bash
git stash push -u -m "说明"
git stash list
git stash pop
git stash apply
git stash drop
git remote -v
git remote add origin <url>
git fetch
git fetch --prune
git pull --rebase
git push -u origin main
git push --force-with-lease
git push origin --delete <branch>
```

## Tag

```bash
git tag
git tag -a v1.0.0 -m "release 1.0.0"
git show v1.0.0
git push origin v1.0.0
git push origin --tags
git tag -d v1.0.0
git push origin --delete v1.0.0
git describe --tags
```

## gh 仓库与协作

```bash
gh auth status
gh auth login
gh auth refresh -s workflow
gh repo create <name> --private --source=. --push
gh repo clone owner/repo
gh repo view --web
gh repo fork owner/repo --clone
gh repo sync
gh issue create --title ... --body ... --label bug
gh issue list --state open --label bug
gh issue view 42 --comments
gh issue develop 42 --checkout
gh issue close 42
gh pr create --base main --title ... --body ...
gh pr list --author @me
gh pr view 123 --web
gh pr diff 123
gh pr checkout 123
gh pr checks 123
gh pr review 123 --approve
gh pr merge 123 --squash --delete-branch
gh pr update-branch 123 --rebase
gh run list --status failure
gh run view <id> --log-failed
gh run watch <id> --exit-status
gh workflow run ci.yml
gh release create v1.2.0 --generate-notes
gh release upload v1.2.0 ./dist/*.zip
gh api repos/{owner}/{repo} --jq '.stargazers_count'
gh alias set pv 'pr view'
gh extension list
```

## 故障排查

| 现象 | 先查 |
| --- | --- |
| 提交被拒，提示 identity unknown | `git config user.email` |
| push 被拒 `non-fast-forward` | `git fetch` + `git status -sb` |
| push 被拒 `workflow scope` | `gh auth refresh -s workflow` |
| PR 里混入别人的提交 | 分支是否基于最新 main |
| `Unverified` 提交 | 签名 key 是否上传、邮箱是否一致 |
| 合并后主分支没更新 | 本地是否 `git pull` |
| 找不到删掉的提交 | `git reflog`，尽快建分支固定 |
| 文件被 ignore 但仍被跟踪 | `git rm --cached <file>` |
| 大文件推不上去 | Git LFS，见 [LFS](06-advanced/04-lfs.md) |

## 三条保命习惯

1. 危险操作前：`git status` + `git log --oneline -3`。
2. 不确定时：先 `git stash` 或建备份分支，不要 `--hard`。
3. 只在 `.sandbox/` 里做实验，见 [练习沙箱](labs/README.md)。
