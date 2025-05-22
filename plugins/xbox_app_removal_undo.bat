REM PluginName: Xbox App Removal (Undo)
REM Description: Restores Xbox App and allows reinstallation during Windows updates
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
echo --- Remove Xbox App (revert)
PowerShell -ExecutionPolicy Unrestricted -Command "$packageName='Microsoft.GamingApp'; $publisherId='8wekyb3d8bbwe'; if (Get-AppxPackage -Name $packageName) { Write-Host "^""Skipping, `"^""$packageName`"^"" is already installed for the current user."^""; exit 0; }; Write-Host "^""Starting the installation process for `"^""$packageName`"^""..."^""; <# Attempt installation using the manifest file #>; Write-Host "^""Checking if `"^""$packageName`"^"" is installed on another user profile..."^""; $packages = @(Get-AppxPackage -AllUsers $packageName); if (!$packages) { Write-Host "^""`"^""$packageName`"^"" is not installed on any other user profiles."^""; } else { foreach ($package in $packages) { Write-Host "^""Found package `"^""$($package.PackageFullName)`"^""."^""; $installationDir = $package.InstallLocation; if ([string]::IsNullOrWhiteSpace($installationDir)) { Write-Warning "^""Installation directory for `"^""$packageName`"^"" is not found or invalid."^""; continue; }; $manifestPath = Join-Path -Path $installationDir -ChildPath 'AppxManifest.xml'; try { if (-Not (Test-Path "^""$manifestPath"^"")) { Write-Host "^""Manifest file not found for `"^""$packageName`"^"" on another user profile: `"^""$manifestPath`"^""."^""; continue; }; } catch { Write-Warning "^""An error occurred while checking for the manifest file: $($_.Exception.Message)"^""; continue; }; Write-Host "^""Manifest file located. Trying to install using the manifest: `"^""$manifestPath`"^""..."^""; try { Add-AppxPackage -DisableDevelopmentMode -Register "^""$manifestPath"^"" -ErrorAction Stop; Write-Host "^""Successfully installed `"^""$packageName`"^"" using its manifest file."^""; exit 0; } catch { Write-Warning "^""Error installing from manifest: $($_.Exception.Message)"^""; }; }; }; <# Attempt installation using the package family name #>; $packageFamilyName = "^""$($packageName)_$($publisherId)"^""; Write-Host "^""Trying to install `"^""$packageName`"^"" using its package family name: `"^""$packageFamilyName`"^"" from system installation..."^""; try { Add-AppxPackage -RegisterByFamilyName -MainPackage $packageFamilyName -ErrorAction Stop; Write-Host "^""Successfully installed `"^""$packageName`"^"" using its package family name."^""; exit 0; } catch { Write-Warning "^""Error installing using package family name: $($_.Exception.Message)"^""; }; throw "^""Unable to reinstall the requested package ($packageName). "^"" + "^""It appears to no longer be included in this version of Windows. "^"" + "^""You may search for it or an alternative in the Microsoft Store or "^"" + "^""consider using an earlier version of Windows where this package was originally provided."^"""
PowerShell -ExecutionPolicy Unrestricted -Command "$keyPath='HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Appx\AppxAllUserStore\Deprovisioned\Microsoft.GamingApp_8wekyb3d8bbwe'; $registryHive = $keyPath.Split('\')[0]; $registryPath = "^""$($registryHive):$($keyPath.Substring($registryHive.Length))"^""; Write-Host "^""Removing registry key at `"^""$registryPath`"^""."^""; if (-not (Test-Path -LiteralPath $registryPath)) { Write-Host "^""Skipping, no action needed, registry key `"^""$registryPath`"^"" does not exist."^""; exit 0; }; try { Remove-Item -LiteralPath $registryPath -Force -ErrorAction Stop | Out-Null; Write-Host "^""Successfully removed the registry key at path `"^""$registryPath`"^""."^""; } catch { Write-Error "^""Failed to remove the registry key at path `"^""$registryPath`"^"": $($_.Exception.Message)"^""; }"
endlocal
exit /b 0
