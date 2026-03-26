$action = New-ScheduledTaskAction -Execute "wsl.exe" -Argument "-e /home/miro/claude-daily.sh"
$trigger = New-ScheduledTaskTrigger -Daily -At 6:00AM
$settings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries -StartWhenAvailable
$principal = New-ScheduledTaskPrincipal -UserId "$env:USERNAME" -LogonType Interactive

Register-ScheduledTask -TaskName "Claude Daily Morning Agent" -Action $action -Trigger $trigger -Settings $settings -Principal $principal -Description "Runs Claude Code at 6am to check calendar/email/LinkedIn and write daily action plan"
