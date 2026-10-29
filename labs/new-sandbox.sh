#!/usr/bin/env bash
# 生成一个一次性 git 练习仓库。
#
# 所有会改写历史、制造冲突、强制推送的实验都在沙箱里做，
# 不要在主仓库（本项目）里练。
#
# 用法：
#   labs/new-sandbox.sh demo            # 新建 .sandbox/demo
#   labs/new-sandbox.sh demo --force    # 删掉重建
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SANDBOX_ROOT="$ROOT/.sandbox"
NAME="${1:-}"
FORCE="${2:-}"

if [[ -z "$NAME" || "$NAME" == */* || "$NAME" == "." || "$NAME" == ".." ]]; then
  echo "用法：labs/new-sandbox.sh <名称> [--force]" >&2
  exit 1
fi

TARGET="$SANDBOX_ROOT/$NAME"

if [[ -e "$TARGET" ]]; then
  if [[ "$FORCE" == "--force" ]]; then
    rm -rf "$TARGET"
  else
    echo "已存在：$TARGET（加 --force 重建）" >&2
    exit 1
  fi
fi

mkdir -p "$TARGET"
cd "$TARGET"

git init -q -b main
# 沙箱使用独立身份，避免污染本机全局配置
git config user.name "Try Git"
git config user.email "try-git@example.com"
git config commit.gpgsign false

printf '# 沙箱项目\n\n用于练习 git 命令，随时可删。\n' > README.md
git add README.md
git commit -q -m "docs: 初始化沙箱项目"

printf 'apple\nbanana\ncherry\n' > fruits.txt
git add fruits.txt
git commit -q -m "feat: 添加水果清单"

printf 'apple\nbanana\ncherry\ndate\n' > fruits.txt
git commit -q -am "feat: 添加 date"

echo "沙箱已创建：$TARGET"
echo "接下来：cd $TARGET && git log --oneline --graph --all"
