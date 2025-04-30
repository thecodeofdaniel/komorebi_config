$processes = @("komorebi", "komorebi-bar")

# Ask the user what they want to do (start or kill) before processing
$action = Read-Host "Do you want to (start/kill) the processes? (start/kill)"

foreach ($name in $processes) {
    if ($action -eq "kill") {
        $proc = Get-Process -Name $name -ErrorAction SilentlyContinue
        if ($proc) {
            Stop-Process -Name $name -Force
            Write-Output "$name has been killed."
        } else {
            Write-Output "$name is not running."
        }

    } elseif ($action -eq "start") {
        $proc = Get-Process -Name $name -ErrorAction SilentlyContinue
        if ($proc) {
            Write-Output "$processes is already running."
        } else {
            Write-Output "Starting $processes..."
            Start-Process "komorebic" -ArgumentList "start --whkd --bar"
            Write-Output "$processes has been started!"
        }
        break
    } else {
        Write-Output "Invalid option entered. Please choose 'start' or 'kill'."
        break
    }
}
