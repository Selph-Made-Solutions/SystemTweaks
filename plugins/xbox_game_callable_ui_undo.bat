REM PluginName: Xbox Game Callable UI (Undo)
REM Description: Restores Xbox Game Callable UI application and related files
@echo off
setlocal EnableExtensions DisableDelayedExpansion
echo --- Remove Xbox Game Callable UI (revert)
PowerShell -ExecutionPolicy Unrestricted -Command "$packageName='Microsoft.XboxGameCallableUI'; if (Get-AppxPackage -Name $packageName) { Write-Host 'Already installed'; exit 0; }; try { Add-AppxPackage -RegisterByFamilyName -MainPackage 'Microsoft.XboxGameCallableUI_cw5n1h2txyewy' -ErrorAction Stop; Write-Host 'Successfully installed'; } catch { Write-Warning 'Installation failed'; }"
PowerShell -ExecutionPolicy Unrestricted -Command "$keyPath='HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Appx\AppxAllUserStore\Deprovisioned\Microsoft.XboxGameCallableUI_cw5n1h2txyewy'; if (-not (Test-Path $keyPath)) { Write-Host 'Key does not exist'; exit 0; }; try { Remove-Item $keyPath -Force; Write-Host 'Registry key removed'; } catch { Write-Error 'Failed to remove key'; }"
endlocal
exit /b 0
