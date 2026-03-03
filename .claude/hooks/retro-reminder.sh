#!/bin/bash
# retro-reminder.sh — Stop hook: 提醒用户复盘
# 检查 stop_hook_active 防止无限循环
INPUT=$(cat)
ACTIVE=$(echo "$INPUT" | jq -r '.stop_hook_active // false')
if [ "$ACTIVE" = "true" ]; then
  echo '{}'
  exit 0
fi

# 使用 systemMessage 输出，确保用户可见（普通 echo 只在 verbose 模式显示）
echo '{"systemMessage": "💡 如果本次会话涉及 bug 修复、新功能或踩坑，建议运行 /retro 进行复盘，积累经验防止重犯。"}'
exit 0
