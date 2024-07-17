###############################################################################################################
#
# ABOUT THIS PROGRAM
#
#   CredGuard-Disable-Check.ps1
#   https://github.com/Headbolt/CredGuard-Disable
#
#  This script was designed to Check specific registry values
#  and then exit with an appropriate Exit code.
#
#  Intended use is in Microsoft Endpoint Manager, as the "Check" half of a Proactive Remediation Script
#  The "Remediate" half is found here https://github.com/Headbolt/CredGuard-Disable
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
	Exit 1 # Key does not exist, exit with failure code 
}
else
{
	Write-Host "$SoftwareKeyPath\$SoftwareKey exists"
	$SoftwareKeyCheck=(Get-Item $SoftwareKeyPath\$SoftwareKey).property # Grab values from key
	$SoftwareValueCheck=(select-string -pattern $Value -InputObject $SoftwareKeyCheck) # Grab desired value from key
	if ([string]::IsNullOrEmpty($SoftwareValueCheck)) # Check value exists 
	{
		Write-Host "$SoftwareKeyPath\$SoftwareKey\$Value Does not exist"
		Exit 1 # Value does not exist, exit with failure code
	}
	else
	{
		Write-Host "$SoftwareKeyPath\$SoftwareKey\$Value exists"
		$SoftwareDataCheck=((Get-ItemProperty -Path $SoftwareKeyPath\$SoftwareKey -Name $Value).$Value) # Grab value data
		#
		Write-Host "$SoftwareKeyPath\$SoftwareKey\$Value should be $Data and is $SoftwareDataCheck"
		if ( $SoftwareDataCheck -ne $Data) # Check value data
		{
			Exit 1 # Value data is incorrect, exit with failure code 
		}
	}
}
#
$SystemKeyCheck=(Get-Item $SystemKey).property # Grab values from key
$SystemValueCheck=(select-string -pattern "$Value " -InputObject $SystemKeyCheck) # Grab desired value from key
#
if ([string]::IsNullOrEmpty($SystemValueCheck)) # Check value exists 
{
	Write-Host "$SystemKey\$Value Does not exist"
	Exit 1 # Value does not exist, exit with failure code
}
else
{
	Write-Host "$SystemKey\$Value exists"
	$SystemDataCheck=((Get-ItemProperty -Path $SystemKey -Name $Value).$Value) # Grab value data
	#
	Write-Host "$SystemKey\$Value should be $Data and is $SystemDataCheck"
	if ( $SoftwareDataCheck -ne $Data) # Check value data
	{
		Exit 1 # Value data is incorrect, exit with failure code 
	}
}
Exit 0 # All value data is correct, exit with success code 
