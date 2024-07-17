###############################################################################################################
#
# ABOUT THIS PROGRAM
#
#   CredGuard-Disable-Remediate.ps1
#   https://github.com/Headbolt/CredGuard-Disable
#
#  This script was designed to Remediate specific registry values
#
#  Intended use is in Microsoft Endpoint Manager, as the "Remediate" half of a Proactive Remediation Script
#  The "Check" half is found here https://github.com/Headbolt/CredGuard-Disable
#
###############################################################################################################
#
# HISTORY
#
#   Version: 1.0 - 17/07/2024
#
#   - 17/07/2024 - V1.0 - Created by Headbolt
#
###############################################################################################################
#
#   DEFINE VARIABLES & READ IN PARAMETERS
#
###############################################################################################################
#
$SystemKey="HKLM:\SYSTEM\CurrentControlSet\Control\Lsa"
$SoftwareKeyPath="HKLM:\SOFTWARE\Policies\Microsoft\Windows"
$SoftwareKey="DeviceGuard"
$Value="LsaCfgFlags"
$Data="0"
#
###############################################################################################################
#
# SCRIPT CONTENTS - DO NOT MODIFY BELOW THIS LINE
#
###############################################################################################################
#
# Begin Processing
#
###############################################################################################################
#
# Check for HKLM:\SOFTWARE\Policies\Microsoft\Windows\DeviceGuard 
$SoftwareKeyPathCheck=(Get-ChildItem -Path $SoftwareKeyPath\ | Select-Object Name | select-string -pattern $SoftwareKey)
#
if ([string]::IsNullOrEmpty($SoftwareKeyPathCheck)) # Check if key path exists 
{
	Write-Host "HKLM:\SOFTWARE\Policies\Microsoft\Windows\$SoftwareKey Does not exist"
	Write-Host 'Running Command'
	Write-Host "New-Item -Path $SoftwareKeyPath -Name $SoftwareKey | Out-Null"
	New-Item -Path $SoftwareKeyPath -Name $SoftwareKey | Out-Null
	Write-Host 'Running Command'
	Write-Host "New-ItemProperty -Path $SoftwareKeyPath\$SoftwareKey -Name $Value -PropertyType DWORD | Out-Null"
	New-ItemProperty -Path $SoftwareKeyPath\$SoftwareKey -Name $Value -PropertyType DWORD | Out-Null
	Write-Host ""
}
else
{
	Write-Host "$SoftwareKeyPath\$SoftwareKey exists"
	$SoftwareKeyCheck=(Get-Item $SoftwareKeyPath\$SoftwareKey).property # Grab values from key
	$SoftwareValueCheck=(select-string -pattern $Value -InputObject $SoftwareKeyCheck) # Grab desired value from key
	if ([string]::IsNullOrEmpty($SoftwareValueCheck)) # Check value exists 
	{
		Write-Host "$SoftwareKeyPath\$SoftwareKey\$Value Does not exist"
		Write-Host 'Running Command'
		Write-Host "New-ItemProperty -Path $SoftwareKeyPath\$SoftwareKey -Name $Value -PropertyType DWORD | Out-Null"
		New-ItemProperty -Path $SoftwareKeyPath\$SoftwareKey -Name $Value -PropertyType DWORD | Out-Null
	}
	else
	{
		Write-Host "$SoftwareKeyPath\$SoftwareKey\$Value exists"
		$SoftwareDataCheck=((Get-ItemProperty -Path $SoftwareKeyPath\$SoftwareKey -Name $Value).$Value) # Grab value data
		#
		Write-Host "$SoftwareKeyPath\$SoftwareKey\$Value should be $Data and is $SoftwareDataCheck"
		if ( $SoftwareDataCheck -ne $Data) # Check value data
		{
			Write-Host 'Running Command'
			Write-Host "New-ItemProperty -Path $SoftwareKeyPath\$SoftwareKey -Name $Value -PropertyType DWORD -Force | Out-Null"
			New-ItemProperty -Path $SoftwareKeyPath\$SoftwareKey -Name $Value -PropertyType DWORD -Force | Out-Null
		}
	}
}
#
Write-Host ""
$SystemKeyCheck=(Get-Item $SystemKey).property # Grab values from key
$SystemValueCheck=(select-string -pattern "\b$Value\b" -InputObject $SystemKeyCheck) # Grab desired value from key
#
if ([string]::IsNullOrEmpty($SystemValueCheck)) # Check value exists 
{
	Write-Host "$SystemKey\$Value Does not exist"
	Write-Host 'Running Command'
	Write-Host "New-ItemProperty -Path $SystemKey -Name $Value -PropertyType DWORD | Out-Null"
	New-ItemProperty -Path $SystemKey -Name $Value -PropertyType DWORD | Out-Null # Create value
}
else
{
	Write-Host "$SystemKey\$Value exists"
	$SystemDataCheck=((Get-ItemProperty -Path $SystemKey -Name $Value).$Value) # Grab value data
	#
	Write-Host "$SystemKey\$Value should be $Data and is $SystemDataCheck"
	if ( $SystemDataCheck -ne $Data) # Check value data
	{
		Write-Host 'Running Command'
		Write-Host "New-ItemProperty -Path $SystemKey -Name $Value -PropertyType DWORD -Force | Out-Null"
		New-ItemProperty -Path $SystemKey -Name $Value -PropertyType DWORD -Force | Out-Null # Update value
	}
}
