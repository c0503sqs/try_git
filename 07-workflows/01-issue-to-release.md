# 从 issue 到 release

## 能学到什么

- 把前面所有命令串成一条完整的协作流程
- 每一步用哪条 git / gh 命令
- 哪些地方容易出错
- 一份可以照着执行的操作清单

## 流程全景

```text
① 建 issue
      │
② 从 issue 拉分支
      │
③ 开发 + 规范提交
      │
④ 推送 + 开 PR（关联 issue）
      │
⑤ CI 通过
      │
⑥ review + 修改
      │
⑦ 合并 + 删分支
      │
⑧ 打 tag + 发 Release
```

下面以「修复 CSV 导出中文乱码」为例，命令都在你自己的测试仓库里执行。

## ① 建 issue

```bash
gh issue create \
  --title "导出 CSV 时中文乱码" \
  --body "## 复现

1. 导出含中文的表格
2. 用 Excel 打开

## 期望

中文正常显示。" \
  --label bug \
  --assignee @me
```

记下返回的 issue 编号，例如 `#42`。

## ② 从 issue 拉分支

```bash
gh issue develop 42 --checkout
# 或手动
git switch main && git pull
git switch -c fix/42-csv-encoding
```

`gh issue develop` 会在远端建分支并关联 issue，省去手动推送。

## ③ 开发 + 规范提交

```bash
# 改代码
git add src/export.ts
git commit -m "fix(export): 写入 UTF-8 BOM 修复中文乱码"
```

提交信息格式见 `try_markdown` 的「提交信息与 PR 描述」。

提交前：

```bash
git status
git diff --staged
```

确认没有误加文件、没有冲突标记。

## ④ 推送 + 开 PR

```bash
git push -u origin fix/42-csv-encoding

gh pr create \
  --base main \
  --title "fix(export): 修复 CSV 导出中文乱码" \
  --body "## 做了什么

- 写文件时显式添加 UTF-8 BOM

## 为什么

Excel 在 Windows 下按本地编码解析无 BOM 的 CSV。

## 怎么验证

1. 导出含中文的表格
2. 用 Excel 打开确认

Closes #42"
```

`Closes #42` 会在合并后自动关闭 issue。

## ⑤ 等待 CI

```bash
gh pr checks
```

```text
All checks were successful
0 failing, 3 successful, 0 skipped, and 0 pending checks
```

失败时：

```bash
gh run list --status failure --limit 5
gh run view <id> --log-failed
```

修完后继续提交并推送，PR 自动更新。

## ⑥ review + 修改

```bash
gh pr view --web
gh pr diff
```

收到意见后：

```bash
# 改代码
git add -A
git commit -m "fix: 处理 review 意见，补充边界测试"
git push
```

如果主分支有新提交，PR 落后：

```bash
git fetch origin
git rebase origin/main
git push --force-with-lease
```

或者交给 GitHub：

```bash
gh pr update-branch 123 --rebase
```

## ⑦ 合并 + 删分支

```bash
gh pr merge 123 --squash --delete-branch
```

合并后本地同步：

```bash
git switch main
git pull
git branch -d fix/42-csv-encoding   # --delete-branch 通常已删
```

确认 issue 自动关闭：

```bash
gh issue view 42 --json state --jq '.state'
```

```text
CLOSED
```

## ⑧ 打 tag + 发 Release

```bash
git switch main && git pull
git tag -a v1.2.0 -m "release 1.2.0"
git push origin v1.2.0

gh release create v1.2.0 \
  --title "v1.2.0" \
  --generate-notes \
  --verify-tag
```

需要附件时：

```bash
gh release upload v1.2.0 ./dist/*.zip
```

## 完整检查清单

- [ ] issue 描述清楚，有复现步骤
- [ ] 分支名包含类型和 issue 号
- [ ] 提交信息符合规范，一个提交一件事
- [ ] PR 描述包含「做了什么 / 为什么 / 怎么验证」
- [ ] PR 里有 `Closes #<编号>`
- [ ] CI 全部通过
- [ ] review 意见已处理
- [ ] 合并方式符合团队约定（squash / merge / rebase）
- [ ] 合并后删除分支
- [ ] 本地主分支已同步
- [ ] tag 已推送
- [ ] Release 说明对用户可读
- [ ] 附件完整，没有敏感信息

## 容易出错的点

| 环节 | 常见错误 | 后果 |
| --- | --- | --- |
| 拉分支 | 没先更新 main | PR 里混入别人的提交 |
| 提交 | 一次提交混多个改动 | review 和回滚都困难 |
| PR | 忘了 `Closes` | issue 不会自动关闭 |
| CI | 只看到 PR 页面绿勾，没看具体 job | 部分检查被跳过 |
| 合并 | 在网页合并后本地没 pull | 本地继续基于旧代码开发 |
| 发版 | 忘了 `git push origin v1.2.0` | 远端没有 tag，Release 基于错误提交 |
| 清理 | 分支不删 | 列表膨胀，误以为还有未完成工作 |

## 注意事项

1. **每一步都先确认当前分支**。`git status -sb` 是最快的检查方式。
2. **不要在 main 上直接开发**。即使个人项目，也走一遍分支流程，习惯成自然。
3. **force push 只在个人分支**，共享分支用 merge。
4. **CI 失败先看日志再改**，不要反复空提交触发重跑。
5. **Release 说明面向用户**，不是提交列表的复制。
6. **合并后立刻同步本地**，避免下次开发基于旧代码。

## 练习

1. 在自己的测试仓库完整走一遍上面八步，记录每步的输出。
2. 故意制造一次 CI 失败，用 `gh run view --log-failed` 定位并修复。
3. 故意让 PR 落后主分支，分别用 rebase 和 `gh pr update-branch` 处理，比较结果。
4. 发布一个 Release，用 `gh release view --json assets` 确认附件。

---

上一篇：[签名提交](../06-advanced/06-signed-commits.md) · 下一篇：[练习 1：制造并解决一次冲突](../exercises/01-conflict.md)
