<# 

.SYNOPSIS
 Automates manual update install on an air-gapped system. v1.2

.DESCRIPTION
Installs Windows .msu and .exe updates, Firefox and Java. Run script from directory containing only the updates you want to install. -Reboot switch restarts when finished


#>

param (
    [switch]$Reboot
)

$dir = Get-ChildItem
$i = 0

$Firefox = $dir | Where Name -Like *firefox*
if ($Firefox) {
    Unblock-File $Firefox
    Write-Output "Installing:`n$Firefox"
    Write-Progress -Activity "Installing Updates" -PercentComplete ($i++/$dir.name.count*100)
    Start-Process $Firefox.Name -ArgumentList ('-ms') -Wait
}

$JRE = $dir | Where Name -Like jre*
if ($JRE) {
    Unblock-File $JRE
    Write-Output "Installing: `n$JRE`n"
    Write-Progress -Activity "Installing Updates" -PercentComplete ($i++/$dir.name.count*100)
    Start-Process $JRE.Name -ArgumentList ('/s', 'REMOVEOUTOFDATEJRES=1') -Wait 
}

$EXEs = $dir | Where Name -Like *.exe | where Name -NE $Firefox.Name | Where Name -NE $JRE.Name
Foreach ($EXE in $EXEs) {
    Unblock-File $EXE
    Write-output "Installing:`n$EXE`n"
    Write-Progress -Activity "Installing Updates" -PercentComplete ($i++/$dir.name.count*100)
    Start-process $Exe.name -ArgumentList ('/passive', '/norestart') -Wait
}

$MSUs= $dir | Where Name *.msu
Foreach ($MSU in $MSUs) {
    Unblock-File $MSU
    Write-output "Installing:`n$MSU`n"
    Write-Progress -Activity "Installing Updates" -PercentComplete ($i++/$dir.name.count*100)
    Start-Process wusa.exe -ArgumentList ($MSU.Name, "/quiet", "/norestart") -Wait
}


Write-Output Complete!
if ($reboot) {
    Restart-Computer
}
