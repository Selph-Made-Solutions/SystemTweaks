REM PluginName: Xbox Game Callable UI
REM Description: Removes Xbox Game Callable UI application and related files
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
echo --- Remove "Xbox Game Callable UI" app (breaks Xbox Live games)
PowerShell -ExecutionPolicy Unrestricted -Command "Get-AppxPackage 'Microsoft.XboxGameCallableUI' | Remove-AppxPackage"
PowerShell -ExecutionPolicy Unrestricted -Command "$keyPath='HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Appx\AppxAllUserStore\Deprovisioned\Microsoft.XboxGameCallableUI_cw5n1h2txyewy'; $registryHive = $keyPath.Split('\')[0]; $registryPath = "^""$($registryHive):$($keyPath.Substring($registryHive.Length))"^""; if (Test-Path $registryPath) { Write-Host "^""Skipping, no action needed, registry path `"^""$registryPath`"^"" already exists."^""; exit 0; }; try { New-Item -Path $registryPath -Force -ErrorAction Stop | Out-Null; Write-Host "^""Successfully created the registry key at path `"^""$registryPath`"^""."^""; } catch { Write-Error "^""Failed to create the registry key at path `"^""$registryPath`"^"": $($_.Exception.Message)"^""; }"
endlocal
exit /b 0
