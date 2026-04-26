#!/bin/bash
VAULT_DIR="/mnt/c/Users/mirsi/OneDrive/Dokumenty/miro_vault/zettelkasten"
SCRIPTS_DIR="/home/miro/dev/browser_automations"
DATE=$(date +%Y-%m-%d)
LOG_FILE="/tmp/claude-codmon-${DATE}.log"
NTFY_URL="http://192.168.0.14/claude-agents"

if [ -d "$SCRIPTS_DIR" ]; then
  SCRIPTS_LIST=$(cd "$SCRIPTS_DIR" && find . -type f \
    \( -name "*.py" -o -name "*.sh" -o -name "*.js" -o -name "*.mjs" -o -name "*.md" \) \
    -not -path "./.git/*" | sort | sed 's|^\./||')
else
  SCRIPTS_LIST="(scripts directory not found at ${SCRIPTS_DIR})"
fi

notify_failure() {
  curl -sf -m 5 \
    -H "Title: Codmon Agent Failed" \
    -H "Priority: high" \
    -H "Tags: warning" \
    -d "$1" \
    "$NTFY_URL" 2>/dev/null || true
}

echo "=== Claude Codmon Agent - ${DATE} ===" >> "$LOG_FILE"
echo "Started: $(date)" >> "$LOG_FILE"

# Start Docker Desktop if not running
if ! powershell.exe -Command "Get-Process 'Docker Desktop' -ErrorAction SilentlyContinue" &>/dev/null; then
  echo "Starting Docker Desktop..." >> "$LOG_FILE"
  powershell.exe -Command "Start-Process 'C:\Program Files\Docker\Docker\Docker Desktop.exe'" &>/dev/null
  echo "Waiting for Docker daemon to be ready..." >> "$LOG_FILE"
  for i in $(seq 1 30); do
    if docker info &>/dev/null; then
      echo "Docker ready after ~${i}0s" >> "$LOG_FILE"
      break
    fi
    sleep 10
  done
  if ! docker info &>/dev/null; then
    echo "ERROR: Docker failed to start after 5 minutes" >> "$LOG_FILE"
    notify_failure "Docker Desktop failed to start after 5 minutes. Codmon agent cannot run. Check log: $LOG_FILE"
    exit 1
  fi
fi

# Start Edge with remote debugging if not running
if ! powershell.exe -Command "Get-Process msedge -ErrorAction SilentlyContinue" &>/dev/null; then
  echo "Starting Edge with remote debugging..." >> "$LOG_FILE"
  powershell.exe -Command "Start-Process 'C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe' -ArgumentList '--remote-debugging-port=9222','--remote-debugging-address=0.0.0.0','--remote-allow-origins=*'" &>/dev/null
  echo "Waiting for Edge to fully start..." >> "$LOG_FILE"
  sleep 15
fi

SESSION_FILE="/tmp/claude-codmon-session-${DATE}.id"
CLAUDE_JSON="/tmp/claude-codmon-output-${DATE}.json"

cd "$VAULT_DIR"

/usr/bin/claude -p "You are running as an automated Codmon nursery record extraction agent. Today is ${DATE}.

## CRITICAL SECURITY RULES

You are a READ-ONLY agent for the browser. You gather information from Codmon and write it to the local vault only.

**ALLOWED actions (exhaustive list):**
- Browser: navigate, snapshot, screenshot, click (for navigation only), tabs, run_code — READ-ONLY browsing of parents.codmon.com
- File system: Write/Edit files in 'Kids daily activity records/', 'daily/${DATE}.md', and ${SCRIPTS_DIR}/ (see Script library section below)
- Bash: ONLY for non-destructive commands (e.g. running scripts). No git commands.

**FORBIDDEN actions:**
- Do NOT send, reply, or interact with any messaging service
- Do NOT fill in any forms or input boxes on Codmon
- Do NOT modify any vault file other than those in 'Kids daily activity records/' and 'daily/${DATE}.md' (writing to ${SCRIPTS_DIR}/ is allowed and encouraged)
- Do NOT run any git commands. The wrapper auto-commits ${SCRIPTS_DIR}/ after you exit.
- Do NOT execute destructive bash commands

## MCP Server Readiness

Before starting tasks, check if the MCP Docker gateway is connected by calling any MCP tool (e.g. browser_snapshot or slack_list_channels). Based on the result:

- **MCP is ready:** Proceed with all tasks.
- **MCP is NOT ready:** Sleep 2 minutes (\`sleep 120\` via Bash) and check MCP again.
  - If MCP is now ready: proceed with all tasks.
  - If MCP is still not ready: send an ntfy notification describing the problem and exit. Do NOT retry again.

## Script library

You have a shared, version-controlled script library at ${SCRIPTS_DIR}/. It is meant to grow and improve across runs. Reuse over re-derivation; save what's worth saving; never run git yourself.

**Currently available scripts (relative to ${SCRIPTS_DIR}/):**
\`\`\`
${SCRIPTS_LIST}
\`\`\`

**How to use it:**
1. **Reuse first.** Before writing a new browser_evaluate snippet, JP→EN translation table, or DOM extractor, scan the listing above. Codmon-specific scripts live under \`codmon/\`. If something fits, Read it to confirm its interface, then use it.
2. **Save new reusable code.** The \`browser_evaluate\` snippet for picking the right activity-record card (the \`spans = document.querySelectorAll('span.more')\` loop) is a perfect candidate to save as \`codmon/extract-activity-card.js\` and parameterise on date. Same for translation tables (teacher names, meal statuses) — save them to \`codmon/translations.json\` or similar.
3. **Fix bugs in place.** If a saved selector breaks because Codmon's DOM changed, fix the saved script.
4. **Do NOT run git.** The wrapper auto-commits ${SCRIPTS_DIR}/ after you exit.
5. **Use /tmp/ only for ephemeral data files.** Long-lived code goes in ${SCRIPTS_DIR}/.

## Task: Extract today's Codmon nursery records

### Step 1: Navigate to Codmon home feed
- Use browser MCP tools to navigate to https://parents.codmon.com/home
- Wait for the page to load

### Step 2: Check for today's records
- Look for entries dated ${DATE} (today) in the feed
- There may be a 連絡帳 (contact book) entry and/or an 活動記録 (activity record) for today
- If neither exists for today, post to Slack channel C0ACKPPTX2T: 'No new Codmon records found for ${DATE}' and exit

### Step 3: Extract contact book (連絡帳)
- Find the contact book entry for today by looking for text matching today's date pattern (e.g. '3月26日' for 2026-03-26)
- Click on the entry header div that contains 'の連絡帳' and 'より' to open the detail view
- Extract the full text including: teacher message, meal info (主食/主菜/副菜/汁物), bowel movements if any, and the To/date line
- Navigate back to https://parents.codmon.com/home and re-scroll to load entries

### Step 4: Extract activity record (活動記録)
- Find the activity record entry for today's date that contains 'すみれ組'
- Use this approach to click the correct entry:
  \`\`\`javascript
  const spans = document.querySelectorAll('span.more');
  for (let i = 0; i < spans.length; i++) {
    const card = spans[i].closest('.homeCard');
    if (card && card.textContent.includes('活動記録') && card.textContent.includes('TARGET_DATE') && card.textContent.includes('すみれ組')) {
      spans[i].scrollIntoView({ behavior: 'instant', block: 'center' });
      spans[i].click();
      break;
    }
  }
  \`\`\`
- Extract the full text from the detail view

### Step 5: Check for photos
- Before clicking into the detail views, check if the activity record card has list items (li elements inside .homeCard) — these are photo thumbnails
- Count them (visible thumbnails + any '+N' indicator)

### Step 6: Write the note file
- Create the file: Kids daily activity records/nursery-school-${DATE}.md
- Use this format:
  \`\`\`markdown
  # Nursery School Record - [Day of week], [Month] [Day], 2026

  ## Contact Book
  **From:** [Teacher name romanized]

  [Translated English text of the teacher's message]

  ### Meal (Lunch)
  - Staple: [status]
  - Main dish: [status]
  - Side dish: [status]
  - Soup: [status]

  **To:** Oku Miharu
  **Date:** [date and time]

  ## Class Activity Record (Sumire Class)

  > **Photos available on Codmon:** N photos  ← only if photos exist

  [Translated English text of the activity record]

  **To:** Oku Yurie
  **Date:** [date and time]
  \`\`\`

- Translate all Japanese text to natural English
- Meal status translations: 完食 = 'Finished all', おかわり = 'Had seconds', だいたい = 'Mostly eaten'
- Teacher name romanizations: 北澤 = Kitazawa, 酒井 = Sakai, 朝倉 = Asakura, 吉田 = Yoshida, 鳥居 = Torii, 山下 = Yamashita
- Do NOT add any AI-generated banner

### Step 7: Add backlink to daily note
- Check if daily/${DATE}.md exists
- If it exists and doesn't already contain 'nursery-school-${DATE}', append:
  \`\`\`
  [[Kids daily activity records/nursery-school-${DATE}|Nursery school record]]
  \`\`\`
- If it doesn't exist, create it with just the backlink

### Step 8: Notify on Slack
- Post to Slack channel C0ACKPPTX2T: a one-line summary like 'Codmon record for ${DATE} added: [brief description of what Miharu did today]'

### Error handling: ntfy notification
If you cannot complete all the tasks above (e.g. browser won't connect, Codmon is down, login fails, page crashes, or you are running low on budget), send a notification to ntfy so the user knows:
\`\`\`bash
curl -sf -m 5 -H 'Title: Codmon Agent Issue' -H 'Priority: high' -H 'Tags: warning' -d 'DESCRIPTION OF WHAT WENT WRONG' '${NTFY_URL}'
\`\`\`
Replace DESCRIPTION with a brief explanation of what failed and what was or wasn't completed. Always attempt this notification before exiting." \
  --permission-mode auto \
  --output-format json \
  --max-budget-usd 2 \
  > "$CLAUDE_JSON" 2>> "$LOG_FILE"

CLAUDE_EXIT=$?

# Extract and save session ID for resumability
python3 -c "import json,sys; d=json.load(open(sys.argv[1])); print(d.get('session_id',''))" "$CLAUDE_JSON" > "$SESSION_FILE" 2>/dev/null
SESSION_ID=$(cat "$SESSION_FILE" 2>/dev/null)
echo "Session ID: ${SESSION_ID}" >> "$LOG_FILE"

# Log the result text
python3 -c "import json,sys; d=json.load(open(sys.argv[1])); print(d.get('result',''))" "$CLAUDE_JSON" >> "$LOG_FILE" 2>/dev/null

if [ $CLAUDE_EXIT -ne 0 ]; then
  echo "ERROR: Claude exited with code $CLAUDE_EXIT" >> "$LOG_FILE"
  notify_failure "Codmon agent exited with code $CLAUDE_EXIT (budget exceeded or crash). Session: ${SESSION_ID}. Check log: $LOG_FILE"
fi

# Auto-commit any scripts the agent saved or modified.
# Done outside the agent so it never burns budget on git operations.
if [ -d "$SCRIPTS_DIR/.git" ]; then
  if [ -n "$(git -C "$SCRIPTS_DIR" status --porcelain 2>/dev/null)" ]; then
    git -C "$SCRIPTS_DIR" add -A >> "$LOG_FILE" 2>&1
    git -C "$SCRIPTS_DIR" commit -m "auto: claude-codmon ${DATE}" >> "$LOG_FILE" 2>&1 \
      && echo "Committed script changes in $SCRIPTS_DIR" >> "$LOG_FILE" \
      || echo "WARNING: git commit failed in $SCRIPTS_DIR" >> "$LOG_FILE"
  else
    echo "No script changes to commit in $SCRIPTS_DIR" >> "$LOG_FILE"
  fi
else
  echo "WARNING: $SCRIPTS_DIR is not a git repo; skipping auto-commit" >> "$LOG_FILE"
fi

echo "Finished: $(date)" >> "$LOG_FILE"
