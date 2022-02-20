# Author Jasen C
# Date 2/20/2022
# Description: Remove members of the local administrators group after running audit script on servers and/or workstations


$Cred = $host.ui.PromptForCredential("Need Admin credentials.", "Please enter your user name and password.", "", "NetBiosUserName")

# Any accounts listed in CSV will be removed from the coresponding computer
$CSV = "C:\temp\Workstation-LocalAdmins.csv"

# import list of computers/servers and the account to remove for each
$LocalAdmins = ""
$LocalAdmins = Import-Csv $CSV | Select-Object UserName,PSComputerName

$count = 24 #how many time through the loop before stopping
$t = 0
# Loop through the list after waiting 5 minutes, this ensure systems roaming systems eventually get updated as the come back online
while ($t -le $count) {

        foreach ($i in $localAdmins){
            #Write-Output $i
            #Write-Output $i.PSComputerName
            #write-output $i.UserName
            $CODE = {
                param($AAA)
                Remove-LocalGroupMember -Group "Administrators" -Member $($AAA)  
            }
            Invoke-Command -ComputerName $i.PSComputerName -Credential $Cred -ScriptBlock {$env:COMPUTERNAME} -erroraction SilentlyContinue
            Write-Output "Removing " $i
            Invoke-Command -Credential $Cred -ComputerName $i.PSComputerName -ScriptBlock $CODE -ArgumentList $i.UserName 
        }

Write-Output "Waiting 5 minutes and running again"
start-sleep -seconds 300
 $t += 1

}

# Clear our credential
$Cred = ""