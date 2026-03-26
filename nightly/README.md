# Nightly Scripts

Scripts run by Windows Task Scheduler via WSL. Each script is symlinked from `~/` so scheduled tasks can reference `~/script-name.sh`.

## Scripts

| Script | Schedule | Task Scheduler Name | Description |
|--------|----------|---------------------|-------------|
| `claude-daily.sh` | 6:00 AM | Claude Daily | Morning agent: checks email, calendar, LinkedIn, Strava; writes daily note and Slack summary |
| `claude-codmon.sh` | 4:00 PM (weekdays) | Claude Codmon Record | Extracts nursery school contact book and activity records from Codmon, translates JP→EN, writes to `Kids daily activity records/` |
| `qmd-embed.sh` | 3:00 AM | QMD Embed | Re-indexes the zettelkasten vault and generates vector embeddings for QMD search |

## Setup

Scripts are symlinked to the home directory:

```bash
ln -s ~/bashSettings/nightly/claude-daily.sh ~/claude-daily.sh
ln -s ~/bashSettings/nightly/claude-codmon.sh ~/claude-codmon.sh
ln -s ~/bashSettings/nightly/qmd-embed.sh ~/qmd-embed.sh
```

Windows Task Scheduler calls `wsl -e /home/miro/<script>.sh`.

## Logs

- `/tmp/claude-daily-YYYY-MM-DD.log`
- `/tmp/claude-codmon-YYYY-MM-DD.log`
- `/tmp/qmd-embed-YYYY-MM-DD.log`

The morning agent checks the QMD embedding log and flags if the 3am job didn't run (laptop was asleep).
