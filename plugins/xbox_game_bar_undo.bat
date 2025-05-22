REM PluginName: Xbox Game Bar (Undo)
REM Description: Restores Xbox Game Bar and Xbox Game Overlay applications
@echo off
setlocal EnableExtensions DisableDelayedExpansion
echo --- Remove Game Bar (revert)
PowerShell -ExecutionPolicy Unrestricted -Command "$packageName='Microsoft.XboxGamingOverlay'; if (Get-AppxPackage -Name $packageName) { Write-Host 'Already installed'; exit 0; }; try { Add-AppxPackage -RegisterByFamilyName -MainPackage 'Microsoft.XboxGamingOverlay_8wekyb3d8bbwe' -ErrorAction Stop; Write-Host 'Successfully installed'; } catch { Write-Warning 'Installation failed'; }"
PowerShell -ExecutionPolicy Unrestricted -Command "$keyPath='HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Appx\AppxAllUserStore\Deprovisioned\Microsoft.XboxGamingOverlay_8wekyb3d8bbwe'; if (-not (Test-Path $keyPath)) { Write-Host 'Key does not exist'; exit 0; }; try { Remove-Item $keyPath -Force; Write-Host 'Registry key removed'; } catch { Write-Error 'Failed to remove key'; }"
PowerShell -ExecutionPolicy Unrestricted -Command "$packageName='Microsoft.XboxGameOverlay'; if (Get-AppxPackage -Name $packageName) { Write-Host 'Already installed'; exit 0; }; try { Add-AppxPackage -RegisterByFamilyName -MainPackage 'Microsoft.XboxGameOverlay_8wekyb3d8bbwe' -ErrorAction Stop; Write-Host 'Successfully installed'; } catch { Write-Warning 'Installation failed'; }"
PowerShell -ExecutionPolicy Unrestricted -Command "$keyPath='HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Appx\AppxAllUserStore\Deprovisioned\Microsoft.XboxGameOverlay_8wekyb3d8bbwe'; if (-not (Test-Path $keyPath)) { Write-Host 'Key does not exist'; exit 0; }; try { Remove-Item $keyPath -Force; Write-Host 'Registry key removed'; } catch { Write-Error 'Failed to remove key'; }"
endlocal
exit /b 0
