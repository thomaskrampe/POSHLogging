# POSHLogging
## Introduction
This lightweight PowerShell module is for easily creating log files for your PowerShell scripts. Logging is very important to see whats happen, with this module you don't have to care about this anymore.

This module provides the following functionality:
- Create a new log file with timestamp in the filename
- Log Warnings, Error or informational messages with time stamp to that logfile
- As an alternative you can also log your messages to Windows Event Log

## Install instructions
There are several steps possible, follow the instructions below:

1. Download the PSOHLogging Module from the Module directory in this repo 
2. Copy the PSLogging directory (and its contents) to your PSModulePath location. This can be either of the following locations:
    1. **Install for Current User** - `$Home\Documents\WindowsPowerShell\Modules (%UserProfile%\Documents\WindowsPowerShell\Modules)`
    2. **Install for All Users** - `$Env:ProgramFiles\WindowsPowerShell\Modules (%ProgramFiles%\WindowsPowerShell\Modules)``
    3. For more information see [Microsoft TechNet - Installing PowerShell Modules](https://technet.microsoft.com/en-us/library/dd878350(v=vs.85).aspx)
3. To use POSHLogging in your own scripts just run `Import-Module POSHLogging`.
4. You should also be able to use the PowerShell Gallery by running `Install-Module POSHLogging`.

## How to use POSHLogging
After you import the POSHLogging module into your script you can start.
### Start logging
1. To create the log file for your script start with `$Logfile = Start-Flog "C:\temp" "MyScript"`. The first parameter is the log file destination folder, if not already there, it will be created. The second parameter is the name of your script or whatever you want to name it. As the result of the function call above the directory C:\temp would be created (if not already exist) and a log file MyScriptYYYY-mm-dd_HH:MM.log will be created as well. The full path to the log file is than in the variable `$LogFile` for the following function calls.
2. To send messages to you log file use the following function call: `Write-FLog -InformationType "I" -Text "Copy files to C:\Temp" -LogFile $LogFile`. Possible information types are:
    - **E** for Error
    - **W** for Warning
    - **I** for Information
    - **S** for Success
3. At the end of your script just call `Stop-FLog` which adds a footer message with time stamp to your log file.
4. Sometimes it's helpful to have logging in Windows Event logs as well, e.g. special things which should be logged for monitoring systems. In this case you can call 
`Write-ELog -EventLog "System" -Source "MyScript" -EventID "3000" -Type "Error" -Message "An error occurred"` 
to write an entry to the event log **System** with the **Source** "MyScript", **EventID** "3000" of **type** "Error" and the **message**  "An error occurred".
