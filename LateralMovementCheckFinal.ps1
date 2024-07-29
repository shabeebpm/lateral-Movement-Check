param (
    [Parameter(Mandatory=$true)]
    [string]$FolderPath
)

# Output directory
$outputDirectory_text = "C:\shabeeb\LateralMovement\text"
$outputDirectory_json = "C:\shabeeb\LateralMovement\json"
$outputDirectory_csv = "C:\shabeeb\LateralMovement\csv"

# Create output directory if it doesn't exist
$null = foreach ($outputDirectory in @($outputDirectory_text, $outputDirectory_json, $outputDirectory_csv)) {
    if (-not (Test-Path -Path $outputDirectory -PathType Container)) {
        New-Item -Path $outputDirectory -ItemType Directory
    }
}

$EventLogFiles = Get-ChildItem -Path $FolderPath -Include Security.evtx, 'Microsoft-Windows-TerminalServices-RDPClient%4Operational.evtx', 'Microsoft-Windows-RemoteDesktopServices-RDPCoreTS%4Operational.evtx', 'Microsoft-Windows-TerminalServices-RemoteConnectionManager%4Operational.evtx', 'Microsoft-Windows-TerminalServices-LocalSessionManager%4Operational.evtx', 'Microsoft-Windows-SmbClient%4Security.evtx', 'Microsoft-Windows-TaskScheduler%4Operational.evtx', 'Microsoft-Windows-WMI-Activity%4Operational.evtx', 'Microsoft-Windows-WinRM%4Operational.evtx', 'Microsoft-Windows-PowerShell%4Operational.evtx' -Recurse


#$LateralEventIDs = @(4648, 1024, 1102, 4778, 4779, 131, 98, 1149, 21, 22, 25, 41, 31001, 4672, 4776, 4768, 4769, 5140, 5145, 7045, 4698, 4702, 4699, 4700, 4701, 106, 140, 141, 200, 201, 5857, 5860, 5861, 6, 8, 15, 16, 33, 40691, 40692, 8193, 8194, 8197, 4103, 4104, 53504, 400, 403, 91, 168)

$LateralEventIDs = @(4648, 1024, 1102, 4778, 4779, 131, 98, 168)

# Specify the logon types you are interested in (e.g., Logon Type 10 for Remote Desktop)
#$LogonTypesFor4624 = @(10, 3, 2)
$4624EventID = 4624
#$logonTypes = 10, 3, 2
$LogonType10 = 10
$LogonType3 = 3
$LogonType2 = 2


# Loop through each file
foreach ($EventLogFile in $EventLogFiles) {
    # Write the file name to the console
    Write-Host "Checking $($EventLogFile.FullName)"

    # Try to get the events from the file
    try {
    
	# Get the events from the file using Get-WinEvent and filter by lateral movement Event IDs and specified logon types
     
	#$Events = Get-WinEvent -Path $EventLogFile.FullName -FilterXPath "<QueryList><Query Id='0'><Select>*[System[(EventID=$($LateralEventIDs -join ' or EventID=')) or (EventID=$4624EventID and (EventData[Data[@Name='LogonType'] and (Data=$($LogonTypesFor4624 -join ' or '))]))]]</Select></Query></QueryList>" -ErrorAction Stop
      
	
	#$Events = Get-WinEvent -Path $EventLogFile.FullName -FilterXPath "<QueryList><Query Id='0'><Select>*[System[(EventID=$4624EventID and (${logonTypes} -contains Data[@Name='LogonType'])) or (EventID=$($LateralEventIDs -join ' or EventID='))]]</Select></Query></QueryList>" -ErrorAction Stop

    #  $Events = Get-WinEvent -Path $EventLogFile.FullName -FilterXPath "<QueryList><Query Id='0'><Select>*[System[EventID=4624 and ((EventData/Data[@Name='LogonType']='$LogonType10') or (EventData/Data[@Name='LogonType']='$LogonType3') or (EventData/Data[@Name='LogonType']='$LogonType2')) or (EventID=$($LateralEventIDs -join ' or EventID='))]]</Select></Query></QueryList>" -ErrorAction Stop

   #$Events1 = Get-WinEvent -Path $EventLogFile.FullName -FilterXPath "<QueryList><Query Id='0'><Select>*[System[(EventID=4624)]] and *[EventData[Data[@Name='LogonType'] and (Data=2 or Data=3 or Data=10)]]</Select></Query></QueryList>" -ErrorAction Stop

    #$Events2 = Get-WinEvent -Path $EventLogFile.FullName -FilterXPath "<QueryList><Query Id='0'><Select>*[System[(EventID=$($LateralEventIDs -join ' or EventID='))]]</Select></Query></QueryList>" -ErrorAction Stop


#$Events = $Events1+$Events2

$Events = (Get-WinEvent -Path $EventLogFile.FullName -FilterXPath "<QueryList><Query Id='0'><Select>*[System[(EventID=4624)]] and *[EventData[Data[@Name='LogonType'] and (Data=2 or Data=3 or Data=10)]]</Select></Query></QueryList>" -ErrorAction Stop) + (Get-WinEvent -Path $EventLogFile.FullName -FilterXPath "<QueryList><Query Id='0'><Select>*[System[(EventID=$($LateralEventIDs -join ' or EventID='))]]</Select></Query></QueryList>" -ErrorAction Stop)


#old one but it is working without logon type

#$Events = Get-WinEvent -Path $EventLogFile.FullName -FilterXPath "<QueryList><Query Id='0'><Select>*[System[(EventID=$($LateralEventIDs -join ' or EventID='))]]</Select></Query></QueryList>" -ErrorAction Stop
  


# Write the events to the console
        Write-Output $Events

        # Write the events to a text file
        $Events | Format-List | Out-File -FilePath "$outputDirectory_text\$($EventLogFile.BaseName)_Lateral_Movement_Events.txt" -Encoding UTF8

        # Write the events to a json file
        $Events | ConvertTo-Json | Out-File -FilePath "$outputDirectory_json\$($EventLogFile.BaseName)_Lateral_Movement_Events.json" -Encoding UTF8

        # Write the events to a csv file
        $Events | Export-Csv -Path "$outputDirectory_csv\$($EventLogFile.BaseName)_Lateral_Movement_Events.csv" -NoTypeInformation
    }
    catch {
        # Write the error message to the console
        Write-Error $_.Exception.Message

        Write-Host "No events were found that match the specified selection criteria in this Windows event log file" -ForegroundColor blue -BackgroundColor black
        Write-Host "`n"
    }
}

Write-Host "`n"
Write-Host "Lateral movement check completed. Results stored in: $outputDirectory_text, $outputDirectory_json, and $outputDirectory_csv" -ForegroundColor yellow -BackgroundColor black
