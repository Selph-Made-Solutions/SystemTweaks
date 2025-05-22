REM PluginName: Xbox Live Networking Service (Undo)
REM Description: Restores Xbox Live Networking Service to default state
@echo off
where PowerShell >nul 2>&1 || (
    echo PowerShell is not available. Please install or enable PowerShell.
    pause & exit 1
)
fltmc >nul 2>&1 || (
    echo Administrator privileges are required.
    PowerShell Start -Verb RunAs '%0' 2> nul || (
        echo Right-click on the script and select "Run as administrator".
        pause & exit 1
    )
    exit 0
)
setlocal EnableExtensions DisableDelayedExpansion
echo --- Disable Xbox Live Networking Service (revert)
PowerShell -ExecutionPolicy Unrestricted -Command "$serviceName = 'XboxNetApiSvc'; $defaultStartupMode = 'Manual'; $ignoreMissingOnRevert =  $false; Write-Host "^""Reverting service `"^""$serviceName`"^"" start to `"^""$defaultStartupMode`"^""."^""; <# -- 1. Skip if service does not exist #>; $service = Get-Service -Name $serviceName -ErrorAction SilentlyContinue; if (!$service) { if ($ignoreMissingOnRevert) { Write-Output "^""Skipping: The service `"^""$serviceName`"^"" is not found. No action required."^""; Exit 0; }; Write-Warning "^""Failed to revert changes to the service `"^""$serviceName`"^"". The service is not found."^""; Exit 1; }; <# -- 2. Enable or skip if already enabled #>; $startupType = $service.StartType <# Does not work before .NET 4.6.1 #>; if (!$startupType) { $startupType = (Get-WmiObject -Query "^""Select StartMode From Win32_Service Where Name='$serviceName'"^"" -ErrorAction Ignore).StartMode; if (!$startupType) { $startupType = (Get-WmiObject -Class Win32_Service -Property StartMode -Filter "^""Name='$serviceName'"^"" -ErrorAction Ignore).StartMode; }; }; if ($startupType -eq "^""$defaultStartupMode"^"") { Write-Host "^""`"^""$serviceName`"^"" has already expected startup mode: `"^""$defaultStartupMode`"^"". No action required."^""; } else { try { Set-Service -Name "^""$serviceName"^"" -StartupType "^""$defaultStartupMode"^"" -Confirm:$false -ErrorAction Stop; Write-Host "^""Reverted `"^""$serviceName`"^"" with `"^""$defaultStartupMode`"^"" start, this may require restarting your computer."^""; } catch { Write-Error "^""Failed to enable `"^""$serviceName`"^"": $_"^""; Exit 1; }; }; <# -- 4. Start if not running (must be enabled first) #>; if ($defaultStartupMode -eq 'Automatic' -or $defaultStartupMode -eq 'Boot' -or $defaultStartupMode -eq 'System') { if ($service.Status -ne [System.ServiceProcess.ServiceControllerStatus]::Running) { Write-Host "^""`"^""$serviceName`"^"" is not running, starting it."^""; try { Start-Service $serviceName -ErrorAction Stop; Write-Host "^""Started `"^""$serviceName`"^"" successfully."^""; } catch { Write-Warning "^""Failed to start `"^""$serviceName`"^"", requires restart, it will be started after reboot.`r`n$_"^""; }; } else { Write-Host "^""`"^""$serviceName`"^"" is already running, no need to start."^""; }; }"
endlocal
exit /b 0
