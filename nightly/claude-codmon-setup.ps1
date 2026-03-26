$action = New-ScheduledTaskAction -Execute "wsl.exe" -Argument "-e /home/miro/claude-codmon.sh"
$trigger = New-ScheduledTaskTrigger -Weekly -DaysOfWeek Monday,Tuesday,Wednesday,Thursday,Friday -At 4:00PM
$settings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries -StartWhenAvailable
$principal = New-ScheduledTaskPrincipal -UserId "$env:USERNAME" -LogonType Interactive -RunLevel Limited

Register-ScheduledTask -TaskName "Claude Codmon Record" -Action $action -Trigger $trigger -Settings $settings -Principal $principal -Description "Extract daily Codmon nursery school records and add to Obsidian vault"
