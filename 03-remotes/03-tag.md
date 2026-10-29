# tag 与版本号

## 能学到什么

- 轻量 tag 和附注 tag 的区别
- 创建、查看、推送、删除 tag
- 用语义化版本命名
- 知道 tag 和分支的本质区别

## tag 是什么

tag 是**指向某个提交的固定指针**。分支会随着新提交移动，tag 不会。

```text
main:  A──B──C──D──E
              ▲
            v1.0.0   （永远指向 C）
```

适合标记发布版本、里程碑、重要节点。

## 两种 tag

### 轻量 tag（lightweight）

```bash
git tag v1.0.0
```

只是一个指向提交的引用，没有额外信息。

### 附注 tag（annotated）

```bash
git tag -a v1.1.0 -m "release 1.1.0"
```

会创建一个独立的 tag 对象，包含打标签的人、时间、说明，还能签名。

```bash
git show v1.1.0 --stat
```

```text
tag v1.1.0
Tagger: Try Git <try-git@example.com>
Date:   Thu Oct 29 20:58:56 2026 +0800

release 1.1.0

commit 9190fb4a5fe64b69e45afb83edc9f38b62d9b094
Author: Other Dev <other@example.com>
Date:   Thu Oct 29 20:58:46 2026 +0800

    feat: 添加 fig
```

**发版一律用附注 tag**：它能被 `git describe` 使用，能带发布说明，也能用 GPG 签名。

## 查看

```bash
git tag                 # 所有 tag
git tag -l "v1.*"       # 按模式过滤
git show v1.1.0         # 查看 tag 指向的提交和说明
git describe --tags     # 当前提交距离最近的 tag
```

`git describe` 的输出形如 `v1.1.0-3-g9190fb4`：最近 tag 是 `v1.1.0`，之后有 3 个提交，当前提交短哈希 `9190fb4`。

## 给历史提交打 tag

```bash
git tag -a v0.9.0 7b85d58 -m "release 0.9.0"
```

## 推送 tag

**`git push` 不会推送 tag**，必须显式推：

```bash
git push origin v1.1.0      # 推一个
git push origin --tags      # 推所有 tag
```

实测：

```text
To ../remote-origin.git
 * [new tag]         v1.0.0 -> v1.0.0
```

`--tags` 会推送所有本地 tag，包括实验性的。更稳妥的做法是只推需要的版本。

## 删除 tag

```bash
git tag -d v1.0.0                  # 删本地
git push origin --delete v1.0.0    # 删远端
```

两边要分别删。只删本地的话，下次 `fetch` 会把它带回来。

## 移动 tag

tag 本该固定，但确实打错了位置时：

```bash
git tag -f -a v1.0.0 <correct-commit> -m "release 1.0.0"
git push --force origin v1.0.0
```

这会改写远端 tag。**已经有人拉取过这个 tag 时不要这么做**，正确做法是发一个新版本（`v1.0.1`）。

## 检出 tag

```bash
git switch --detach v1.1.0
```

tag 不是分支，检出后处于 detached HEAD。要做修改就基于它建分支：

```bash
git switch -c hotfix/v1.1.1 v1.1.0
```

## 语义化版本

格式：`MAJOR.MINOR.PATCH`

| 位 | 什么时候加 |
| --- | --- |
| MAJOR | 不兼容的 API 变更 |
| MINOR | 向后兼容的新功能 |
| PATCH | 向后兼容的 bug 修复 |

示例：`1.4.2` → 修 bug → `1.4.3`；加功能 → `1.5.0`；破坏性变更 → `2.0.0`。

预发布版本用后缀：`2.0.0-beta.1`、`2.0.0-rc.1`。

tag 名建议带 `v` 前缀（`v1.4.2`），和 GitHub Release 的约定一致。

## tag 还是分支

| | tag | 分支 |
| --- | --- | --- |
| 指向 | 固定提交 | 随提交移动 |
| 用途 | 标记版本 | 持续开发 |
| 能否提交 | 不能（detached） | 能 |
| 推送 | 需要显式推 | `push` 默认推 |
| 删除 | 两端分别删 | 两端分别删 |

## 注意事项

1. **tag 默认不推送**。发版流程里漏掉 `git push origin v1.0.0` 是最常见的错误。
2. **不要复用版本号**。已经发布的 tag 应该视为不可变，打错了发新版本。
3. **轻量 tag 不能带说明**，`git show` 只会显示提交。发版用 `-a`。
4. **tag 和分支可以同名**，但会造成歧义。`git rev-parse v1.0.0` 和 `git rev-parse refs/tags/v1.0.0` 结果可能不同，命名时避开。
5. **删除远端 tag 不会自动通知别人**。其他人本地还有旧 tag，需要他们手动删或重新 clone。
6. **GitHub Release 基于 tag**。先推 tag 再创建 Release，见 [gh release](../04-gh-cli/05-release.md)。

## 练习

1. 在沙箱里创建轻量 tag `v0.1.0` 和附注 tag `v0.2.0`，用 `git show` 对比输出差异。
2. 用 `git tag -l "v0.*"` 过滤，用 `git describe --tags` 看当前提交距离最近 tag 多远。
3. 把 tag 推到本地裸仓库，用 `git ls-remote --tags origin` 确认。
4. 删除本地 tag 和远端 tag，再用 `git fetch` 确认远端已删除。

---

上一篇：[追踪分支](02-tracking-branch.md) · 下一篇：[fork 与 upstream](04-fork-and-upstream.md)
