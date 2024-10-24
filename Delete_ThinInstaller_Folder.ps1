#This is part 2 of the script, which serves to delete the ThinInstaller folder, and self destruct
#Author: Sidt Saunders

#----------
#Variables
#----------

$PublicDesktop = [System.Environment]::GetFolderPath('CommonDesktopDirectory')

#----------
#Functions
#----------

Function DeleteDesktopBat() {
    Remove-Item "$PublicDesktop\Delete_ThinInstaller_Folder.bat"
}

#----------
#Script
#----------

Clear-Host

#Check if ThinInstaller folder exists
$ThinInstallerFolder = "C:\ThinInstaller"

If (Test-Path -Path $ThinInstallerFolder) {
    Write-Host "`nThe ThinInstaller folder will now be recursively removed."
    Start-Sleep -Seconds 2
    #Delete ThinInstaller folder from C:\ThinInstaller
    Remove-Item "C:\ThinInstaller" -Recurse -Force
    Write-Host "`nThe ThinInstaller folder has been removed. Script will self destruct in 5 seconds.`n"
    Start-Sleep -Seconds 5
    DeleteDesktopBat
}
Else {
    #Well, if you ran this and got this output... That would be pretty weird
    Write-Error "`nWell, this is awkward... The ThinInstaller folder does not exist."
    Write-Host "`nThis script will self destruct in 5 seconds."
    Start-Sleep -Seconds 5
    DeleteDesktopBat
}

Remove-Item -Path $MyInvocation.MyCommand.Source -Force