REM PluginName: Xbox Live In-Game Experience (Undo)
REM Description: Restores Xbox Live in-game experience
@echo off
setlocal EnableExtensions DisableDelayedExpansion
echo --- Remove Xbox Live in-game experience (revert)
PowerShell -ExecutionPolicy Unrestricted -Command "$packageName='Microsoft.Xbox.TCUI'; if (Get-AppxPackage -Name $packageName) { Write-Host 'Already installed'; exit 0; }; try { Add-AppxPackage -RegisterByFamilyName -MainPackage 'Microsoft.Xbox.TCUI_8wekyb3d8bbwe' -ErrorAction Stop; Write-Host 'Successfully installed'; } catch { Write-Warning 'Installation failed'; }"
PowerShell -ExecutionPolicy Unrestricted -Command "$keyPath='HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Appx\AppxAllUserStore\Deprovisioned\Microsoft.Xbox.TCUI_8wekyb3d8bbwe'; if (-not (Test-Path $keyPath)) { Write-Host 'Key does not exist'; exit 0; }; try { Remove-Item $keyPath -Force; Write-Host 'Registry key removed'; } catch { Write-Error 'Failed to remove key'; }"
endlocal
exit /b 0
