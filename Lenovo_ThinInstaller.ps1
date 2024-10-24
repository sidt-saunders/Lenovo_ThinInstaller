#Perform updates for Lenovo devices using ThinInstaller stored on $NetworkLocation
#Update files were stored on $NetworkLocation\Auxiliary_Items\ThinInstaller
#I hope this is useful, I find it useful at least
#Author: Sidt Saunders

#----------
#Variables
#----------

$hostname = hostname
$FailCounter = 0
$CopySuccessOrFail = -1
$NetworkLocation = "\\USALPLATP01\DropBox\Sidt_Saunders"
$Message = "Press any key to continue..."

#----------
#Functions
#----------

Function AnyKey () {
    #Check if running PowerShell ISE
    If ($psISE) {
        Add-Type -AssemblyName System.Windows.Forms
        [System.Windows.Forms.MessageBox]::Show("$Message")
    }
    Else {
        Write-Host "$Message" -ForegroundColor Yellow
        $null = $host.ui.RawUI.ReadKey("NoEcho,IncludeKeyDown")
    }
}

Function InvalidSelectionCopyProcess() {
    While ($FailCounter -ne 2) {
        Write-Host ""
        Write-Warning "Please make a valid selection. " -NoNewline
        $FailCounter++
        CopyProcessFailed
    }
    Write-Host ""
    Write-Error "Too many failed attempts.`nScript will exit in 5 seconds."
    Start-Sleep -Seconds 5
    $FailCounter = 0
    Exit
}

Function CopyProcessFailed() {
    $ViewLog = Read-Host "Would you like to view the log now? (Y/N) "
    If ($ViewLog -eq "y" -or $ViewLog -eq "Y") {
        Invoke-Item "C:\robocopylog.txt"
        AnyKey
        Write-Host "`nScript will exit in 5 seconds.`n"
        Start-Sleep -Seconds 5
        Exit
    }
    If ($ViewLog -eq "n" -or $ViewLog -eq "N") {
        Write-Error "Please view the log at your earliest convenience - C:\robocopylog.txt`nScript will exit in 5 seconds.`n"
        Start-Sleep -Seconds 5
        Exit
    }
    Else {
        InvalidSelectionCopyProcess
    }
}

Function ThinInstallerFolderExists() {
    #Check if ThinInstaller folder is already in C:\
    $ThinInstallerFolder = "\\$hostname\C$\ThinInstaller"
    If (Test-Path -Path $ThinInstallerFolder) {
        Write-Host "`nThinInstaller folder already exists, continuing script.`n" -ForegroundColor DarkGreen
        Start-Sleep -Seconds 2
        CopyAndUpdate
    }
    Else {
        #Copy ThinInstaller folder from $NetworkLocation
        Write-Host "`nPlease wait while the ThinInstaller folder is copied. This may take a few minutes.`n" -ForegroundColor Green
        $CopyProcess = (Start-Process robocopy -ArgumentList "$NetworkLocation\Auxiliary_Items\ThinInstaller \\$hostname\C$\ThinInstaller /mir /log:\\$hostname\C$\robocopylog.txt" -NoNewWindow -PassThru -Wait)
        $CopySuccessOrFail = $CopyProcess.ExitCode
        If ($CopySuccessOrFail -eq 0 -or $CopySuccessOrFail -eq 1) {
            Write-Host "`nThe ThinInstaller folder has been copied successfully.`n" -ForegroundColor Green
            Remove-Item -Force "\\$hostname\C$\robocopylog.txt"
            CopyAndUpdate
        }
        Else {
            Write-Host "`nThe ThinInstaller folder has failed to copy. Please view the logs on C:\robocopylogs.txt .`n" -ForegroundColor Red
            CopyProcessFailed
        }
    }
}

Function CopyAndUpdate() {
    #Copy Delete_ThinInstaller_Folder.bat to Public Desktop, Delete_ThinInstaller_Folder.ps1 to C:\
    $PublicDesktop = [System.Environment]::GetFolderPath('CommonDesktopDirectory')
    $PublicDesktopShortened = $PublicDesktop.Substring(2)
    $PublicDesktopNetworkLocation = "\\$hostname\C$\$PublicDesktopShortened"
    Copy-Item $NetworkLocation\Scripts\Script_Files\Lenovo_ThinInstaller\Delete_ThinInstaller_Folder.bat $PublicDesktopNetworkLocation
    Copy-Item $NetworkLocation\Scripts\Script_Files\Lenovo_ThinInstaller\Delete_ThinInstaller_Folder.ps1 \\$hostname\C$\
    #Hide Delete_ThinInstaller_folder.ps1
    $FileToHide = Get-Item \\$hostname\C$\Delete_ThinInstaller_Folder.ps1 -Force
    $FileToHide.Attributes = 'Hidden'
    #Reminder to run the Delete_ThinInstaller_Folder script after restart
    Write-Host "`nAfter running this update, please remember to run the batch file " -ForegroundColor Green -NoNewline
    Write-Host "Delete_ThinInstaller_folder.bat" -NoNewline
    Write-Host " that is on the desktop to complete the process.`n" -ForegroundColor Green
    Write-Host "NOTE: If for some reason there is an update that requires a restart before installing other updates that also require a restart, ThinInstaller will automatically start after logging back in.`n" -ForegroundColor DarkGray
    Write-Host "If ThinInstaller does not automatically start after logging back in, it means there are no more updates to be installed, andyou can proceed with uninstall.`n" -ForegroundColor DarkGray
    AnyKey
    
    #Start ThinInstaller after copy is completed
    Write-Host "`nThinInstaller will run in 3 seconds.`n" -ForegroundColor Green
    Start-Sleep -Seconds 3
    Start-Process -FilePath "C:\ThinInstaller\ThinInstaller.exe"
    Exit
}

<#
Had a DeleteFolder function here, but with version 3, I made it so that this script would not need to be re-run
Instead, copied a .bat the desktop and a .ps1 to the C:\ that can be run to delete the folder, and then self destruct
#>

Function ExitScript() {
    Write-Host "`nNo cchnages have been made.`nExiting script in 3 seconds.`n" -ForegroundColor Green
    Start-Sleep -Seconds 3
    Exit
}

Function InvalidSwitchSelection() {
    While ($FailCounter -ne 2) {
        Write-Host ""
        Write-Warning "`nPlease make a valid selection `n" -NoNewline
        ConfirmContinue
        $FailCounter++
    }
    Write-Host ""
    Write-Error "Too many failed attempts.`nScript will exit in 5 seconds."
    Start-Sleep -Seconds 5
    $FailCounter = 0
    Exit
}

Function SwitchSelection() {
    Switch ($SelectOption) {
        Y {ThinInstallerFolderExists}
        N {ExitScript}

        Default {InvalidSwitchSelection}
    }
}

Function AlreadyRun() {
    Switch ($RunAgain) {
        Y {ThinInstallerFolderExists}
        N {ExitScript}

        Default {InvalidAlreadyRun}
    }
}

Function InvalidAlreadyRun() {
    While ($FailCounter -ne 2) {
        Write-Host ""
        Write-Warning "`nPlease make a valid selection. " -NoNewline
        StartTheScript
        $FailCounter++
    }
    Write-Host ""
    Write-Error "Too many failed attempts.`nScript will exit in 5 seconds."
    Start-Sleep -Seconds 5
    $FailCounter = 0
    Exit
}

Function ConfirmContinue() {
    $SelectOption = Read-Host -Prompt "Please confirm you would like to continue (Y/N) "
    #Added this line because $SelectOption is not used again in this function
    $SelectOption | Out-Null
    SwitchSelection
}

Function StartTheScript() {
    #Check if Delete_ThinInstaller_Folder.ps1 exist
    $DeleteThinInstallerFolder = "\\$hostname\C$\Delete_ThinInstaller_folder.ps1"
    If (Test-Path -Path $DeleteThinInstallerFolder) {
        Write-Warning "ThinInstaller might have already been run on this device."
        $RunAgain = Read-Host -Prompt "Would you like to run it again? (Y/N) "
        #Added this line because $RunAgain is not used again in this function
        $RunAgain | Out-Null
        AlreadyRun
    }

    Else {
        ConfirmContinue
    }
}

#----------
#Script
#----------

Clear-Host

#Prompt user to select option
Write-Host "`nTHIS SCRIPT IS FOR UPDATING LENOVO DEVICES USING THE THININSTALLER.`n" -BackgroundColor White -ForegroundColor Black
Write-Host "Press CTRL + C twice at any time to kill the script.`n"
Write-Host "------------------------------`n"
Start-Sleep -Seconds 2
StartTheScript