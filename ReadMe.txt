LateralMovementCheckFinal.ps1

This PowerShell script is developed to check for lateral movement events from Windows event log files. 

Here is a brief overview of what it does:

It defines a mandatory parameter $FolderPath which should be the path to the folder containing the event log files.
It sets up three output directories for text, JSON, and CSV formats. If these directories don’t exist, it creates them.
It defines the event log files and event IDs relevant to lateral movement.
It loops through each event log file in the specified folder, checks for the defined events, and writes any found events to the output directories in the three formats.

However, please note the following:

 - We need to make sure the $FolderPath provided contains the event log files you want to check.
 - Ensure that the script has the necessary permissions to read the event log files and write to the specified output directories.
 - The script uses Get-WinEvent with -FilterXPath


Main function explanation : 

$Events: This is a variable that will store the result of the Get-WinEvent command.
Get-WinEvent: This is a cmdlet that retrieves events from event logs folder, including the System and Application logs and other relevent logs
-Path $EventLogFile.FullName: This specifies the path to the event log file. The $EventLogFile.FullName is a variable that contains the full path to the log file.
-FilterXPath: This parameter specifies an XPath query to select events from an event log. The XPath query in this case is selecting events from the Security log where the Event ID is 4624 and the LogonType is either the value of 2,3 or 10, or where the Event ID is any of the IDs in the $RDPEventIDs array.
-ErrorAction Stop: This tells PowerShell to stop execution if an error occurs.


In summary, this script is used to retrieve specific security events from a Windows event log file. The specific events it’s looking for are successful logon events (Event ID 4624) with specific logon types(2,3 or 10), or any events with an ID that’s in the $RDPEventIDs array. The results are stored in the $Events variable. If any error occurs during the execution, the script will stop due to the -ErrorAction Stop parameter.


Before running this script, make sure to run PowerShell with administrative privileges and set the execution policy if needed:
Set-ExecutionPolicy RemoteSigned -Scope CurrentUser -Force


Below are relevent event IDs for lateral movement : 

 -RDP Source System:
Security.evtx - 4648(Logon specifying alternate credentials)
Micorsoft-Windows-TerminalServices-RDPClientOperational.evtx -1024, 1102

 - RDP Destination System:
Security.evtx - 4624 (logon type 10), 4778 and 4779
Micorsoft-Windows-RemoteDesktopService-RDPCoreTSOperational.evtx - 131, 98
Microsoft-Windows-TerminalServices-RemoteConnectionManagerOperational.evtx - 1149
Microsoft-Windows-TerminalServices-LocalSessionManagerOperational.evtx - 21, 22, 25, 41

 - Windows Admin Shares Source artifacts:
Security.evtx - 4648(Logon specifying alternate credentials)
Microsoft-Windows-SmbClient%4Security.evtx - 31001 (failed logon to destination)

 - Windows Admin Shares Destination artifacts:
Security.evtx - 4624 (logon type 3)
Security.evtx - 4672 (requirement for accessing default shares such as C$ and ADMIN$)
Security.evtx - 4776 (NTLM if authenticating to local system)
Security.evtx - 4768 (TGT Granted, available only on DC)
Security.evtx - 4769 (Service ticket granted if authenticating to DC)
Security.evtx - 5140 (Share Access)
Security.evtx - 5145 (Audenting of Shared files - NOISY)

 - PSExec Source System:
Security.evtx - 4648 (Logon specifying alternate credentials)

 - PSExec Destination System:
Security.evtx - 4624 (logon type 3 and Type 2 if "-u" alternate credentials are used)
Security.evtx - 4672 (logon by a user with administrative rights)
Security.evtx - 5140 (share access, ADMIN$ share used by PSExec)
Security.evtx - 7045 (Service install)

 - Winndows Remote Management Tools, Scheduled Tasks, Source System:
Security.evtx - 4648 (Logon specifying alternate credentials)

 - Windows Remote Management Tools, Scheduled Tasks,  Destination System:
Security.evtx - 4624 (logon type 3)
Security.evtx - 4672 (requirement for accessing default shares such as C$ and ADMIN$)
Security.evtx - 4698 (Scheduled task created)
Security.evtx - 4702 (Scheduled task updated)
Security.evtx - 4699 (Scheduled task deleted)
Security.evtx - 4700/4701 (Scheduled task enabled/disabled)
Microsoft-Windows-TaskScheduler%4Operational.evtx - 106 (Scheduled task created)
Microsoft-Windows-TaskScheduler%4Operational.evtx - 140 (Scheduled task updated)
Microsoft-Windows-TaskScheduler%4Operational.evtx - 141 (Scheduled task deleted)
Microsoft-Windows-TaskScheduler%4Operational.evtx - 200/201 (Scheduled task executed/deleted)

 - WMI Source System:
Security.evtx - 4648 (Logon specifying alternate credentials)

 - WMI Destination System:
Security.evtx - 4624 (logon type 3)
Security.evtx - 4672 (logon by a user with administrative rights)
Microsoft-Windows-WMI-Activity%4Operational.evtx - 5857 (indicates time of wmiprvse execution and path to provider DLL)
Microsoft-Windows-WMI-Activity%4Operational.evtx - 5860, 5861 ( registration of temporary(5860) and permanent (5861) event consumers, typically used for persistance but can be used for remote execution

 - Powershell Remoting, Source System:
Security.evtx - 4648 (Logon specifying alternate credentials)
Microsoft-Windows-WinRM%4Operational.evtx - 6, 8, 15, 16, 33 (WSMan session initiate and deinitialization)
Microsoft-Windows-PowerShell%4Operational.evtx - 40691, 40692 (records the local initialion of powershell.exe and associated user account)
Microsoft-Windows-PowerShell%4Operational.evtx - 8193 and 8194 (session created)
Microsoft-Windows-PowerShell%4Operational.evtx - 8197 (session closed)


 - Powershell Remoting, Destination System:
Security.evtx - 4624 (logon type 3)
Security.evtx - 4672 (logon by a user with administrative rights)
Microsoft-Windows-PowerShell%4Operational.evtx - 4103, 4104 (script block logging)
Microsoft-Windows-PowerShell%4Operational.evtx - 53504 (records the authenticating user)
Windows Powershell.evtx - 400/403 (ServerReoteHostm indicates start/end of remoting session)
Microsoft-Windows-WinRM%4Operational.evtx - 91(Session creation)
Microsoft-Windows-WinRM%4Operational.evtx - 168(Records the authenticating user)


