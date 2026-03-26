#!/bin/bash
VAULT_DIR="/mnt/c/Users/mirsi/OneDrive/Dokumenty/miro_vault/zettelkasten"
DATE=$(date +%Y-%m-%d)
LOG_FILE="/tmp/claude-codmon-${DATE}.log"

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
fi

# Start Edge with remote debugging if not running
if ! powershell.exe -Command "Get-Process msedge -ErrorAction SilentlyContinue" &>/dev/null; then
  echo "Starting Edge with remote debugging..." >> "$LOG_FILE"
  powershell.exe -Command "Start-Process 'C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe' -ArgumentList '--remote-debugging-port=9222','--remote-debugging-address=0.0.0.0','--remote-allow-origins=*'" &>/dev/null
  sleep 5
fi

cd "$VAULT_DIR"

/usr/bin/claude -p "You are running as an automated Codmon nursery record extraction agent. Today is ${DATE}.

## CRITICAL SECURITY RULES

You are a READ-ONLY agent for the browser. You gather information from Codmon and write it to the local vault only.

**ALLOWED actions (exhaustive list):**
- Browser: navigate, snapshot, screenshot, click (for navigation only), tabs, run_code — READ-ONLY browsing of parents.codmon.com
- File system: Write/Edit files ONLY in 'Kids daily activity records/' directory and 'daily/${DATE}.md'
- Bash: ONLY for non-destructive commands

**FORBIDDEN actions:**
- Do NOT send, reply, or interact with any messaging service
- Do NOT fill in any forms or input boxes on Codmon
- Do NOT modify any vault file other than those in 'Kids daily activity records/' and 'daily/${DATE}.md'
- Do NOT execute destructive bash commands

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
- Post to Slack channel C0ACKPPTX2T: a one-line summary like 'Codmon record for ${DATE} added: [brief description of what Miharu did today]'" \
  --dangerously-skip-permissions \
  --output-format text \
  --max-budget-usd 2 \
  >> "$LOG_FILE" 2>&1

echo "Finished: $(date)" >> "$LOG_FILE"
