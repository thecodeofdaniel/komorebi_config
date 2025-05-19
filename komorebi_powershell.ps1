$processes = @("whkd", "komorebi-bar", "komorebi")

function _kill-komorebi {
    foreach ($process in $processes) {
        $proc = Get-Process -Name $process -ErrorAction SilentlyContinue
        if ($proc) {
            Stop-Process -Name $process -Force
            Write-Output "$process has been killed."
        } else {
            Write-Output "$process is not running."
        }
    }
}

function _start-komorebi {
    foreach ($process in $processes) {
        $proc = Get-Process -Name $process -ErrorAction SilentlyContinue
        if ($proc) {
            Write-Output "Komorebi is already running."
            return
        }
    }

    Write-Output "Starting $processes..."
    Start-Process "komorebic" -ArgumentList "start --whkd --bar"
    Write-Output "$processes has been started!"
}

function _main {
    # Ask the user what they want to do (start or kill) before processing
    $action = Read-Host "Do you want to (start/kill/exit) the processes?"

    if ($action -eq "start" -or $action -eq "s") {
        _start-komorebi
    } elseif ($action -eq "kill" -or $action -eq "k") {
        _kill-komorebi
    } elseif ($action -eq "exit" -or $action -eq "x") {
        return
    } else {
        Write-Output "Invalid option entered."
    }

    _main
}

_main
