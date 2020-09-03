
Function Start-Flog {
    <#
        .SYNOPSIS
            Start-FLog
        .DESCRIPTION
            Create the logfile and the directory if it doesn't exist
        .PARAMETER LogDir
            This parameter contains the directory where the logfile would be created (e.g. 'C:\temp')
        .PARAMETER ScriptName
            This parameter contains the name of the logfile without file extension (e.g. 'MyScript')
        .EXAMPLE
            $Logfile = Start-FLog -Logdir "C:\temp" -ScriptName "MyScript" 
            or
            $Logfile = Start-FLog "C:\temp" "MyScript"
            Create the directory C:\temp (if not already exist) and the empty log file MyScriptYYYY-mm-dd_HH:MM.log 
        .NOTES
            Author        : Thomas Krampe | t.krampe@loginconsultants.de
            Version       : 1.0
            Creation date : 26.07.2018 | v0.1 | Initial function
                          : 26.07.2018 | v1.0 | Release
            Last change   : 03.09.2020 | v1.1 | Change Logfilename
           
    #>

    [CmdletBinding()]
    Param( 
        [Parameter(Mandatory=$true, Position = 0)][String]$LogDir,
        [Parameter(Mandatory=$true, Position = 1)][String]$ScriptName
    )
    
    begin {

    }

    process {
        $DateTime = Get-Date -uformat "%Y-%m-%d_%H-%M"
        $LogFileName = "$DateTime"+"-$ScriptName.log"
        $LogFile = Join-path $LogDir $LogFileName
 
        # Create the log directory if it does not exist
        if (!(Test-Path $LogDir)) { New-Item -Path $LogDir -ItemType directory | Out-Null }
 
        # Create new log file (overwrite existing one)
        New-Item $LogFile -ItemType "file" -force | Out-Null

        # Insert log file header
        Add-Content $LogFile -value ("********************************************************************************")
        Add-Content $LogFile -value ("Start logging for $ScriptName @ $DateTime")
        Add-Content $LogFile -value ("********************************************************************************")

    }

    end {
        Return $Logfile
    }

} #EndFunction Start-Flog
Export-ModuleMember -Function Start-Flog

function Write-FLog {
    <#
            .SYNOPSIS
                Write text to log file
            .DESCRIPTION
                Write text to this script's log file
            .PARAMETER InformationType
                This parameter contains the information type prefix. Possible prefixes and information types are:
                    I = Information
                    S = Success
                    W = Warning
                    E = Error
            .PARAMETER Text
                This parameter contains the text (the line) you want to write to the log file. If text in the parameter is omitted, an empty line is written.
            .PARAMETER LogFile
                This parameter contains the full path, the file name and file extension to the log file (e.g. C:\Logs\MyApps\MylogFile.log)
            .EXAMPLE
                Write-FLog -$InformationType "I" -Text "Copy files to C:\Temp" -LogFile "C:\Logs\MylogFile.log"
                or
                Write-FLog "I" "Copy files to C:\Temp" $LogFile
                Writes a line containing information to the log file
            .EXAMPLE
                Write-FLog -$InformationType "E" -Text "An error occurred trying to copy files to C:\Temp (error: $($Error[0]))" -LogFile "C:\Logs\MylogFile.log"
                or
                Write-FLog "E" "An error occurred trying to copy files to C:\Temp (error: $($Error[0]))" $LogFile 
                Writes a line containing error information to the log file
            .NOTES
                Author        : Thomas Krampe | t.krampe@loginconsultants.de
                Version       : 1.0
                Creation date : 26.07.2018 | v0.1 | Initial function
                Last change   : 07.09.2018 | v1.0 | Fix some minor typos
    #>
     
        [CmdletBinding()]
        Param( 
            [Parameter(Mandatory=$true, Position = 0)][ValidateSet("I","S","W","E",IgnoreCase = $True)][String]$InformationType,
            [Parameter(Mandatory=$true, Position = 1)][AllowEmptyString()][String]$Text,
            [Parameter(Mandatory=$true, Position = 2)][AllowEmptyString()][String]$LogFile
        )
      
        begin {
        }
      
        process {
            if (Test-Path -Path $Logfile -PathType Leaf) {
                $DateTime = (Get-Date -format dd-MM-yyyy) + " " + (Get-Date -format HH:mm:ss)
      
                if ( $Text -eq "" ) {
                    Add-Content $LogFile -value ("") 
                } Else {
                    Add-Content $LogFile -value ($DateTime + " " + $InformationType.ToUpper() + " - " + $Text)
                    }
                } Else {
                    Write-Error "Logfile missing. Maybe you forgot to start with 'Start-FLog' first."
                }

        }
      
        end {
        }     
} #EndFunction Write-FLog
Export-ModuleMember -Function Write-FLog

Function Write-ELog {
    <#
        .SYNOPSIS
            Write-ELog
        .DESCRIPTION
            Write an entry into the Windows event log. New event logs as well as new event sources are automatically created.
        .PARAMETER EventLog
            This parameter contains the name of the event log the entry should be written to (e.g. Application, Security, System or a custom one)
        .PARAMETER Source
            This parameter contains the source (e.g. 'MyScript')
        .PARAMETER EventID
            This parameter contains the event ID number (e.g. 3000)
        .PARAMETER Type
            This parameter contains the type of message. Possible values are: Information | Warning | Error
        .PARAMETER Message
            This parameter contains the event log description explaining the issue
        .EXAMPLE
            Write-ELog -EventLog "System" -Source "MyScript" -EventID "3000" -Type "Error" -Message "An error occurred"
            Write an error message to the System event log with the source 'MyScript' and event ID 3000. The unknown source 'MyScript' is automatically created
        .EXAMPLE
            Write-ELog -EventLog "Application" -Source "Something" -EventID "250" -Type "Information" -Message "Information: action completed successfully"
            Write an information message to the Application event log with the source 'Something' and event ID 250. The unknown source 'Something' is automatically created
        .EXAMPLE
            Write-ELog -EventLog "MyNewEventLog" -Source "MyScript" -EventID "1000" -Type "Warning" -Message "Warning. There seems to be an issue"
            Write an warning message to the event log called 'MyNewEventLog' with the source 'MyScript' and event ID 1000. The unknown event log 'MyNewEventLog' and source 'MyScript' are automatically created
        .NOTES
            Author        : Thomas Krampe | t.krampe@loginconsultants.de
            Version       : 1.0
            Creation date : 26.07.2018 | v0.1 | Initial function
            Last change   : 26.07.2018 | v1.0 | Release
           
            IMPORTANT NOTICE
            ----------------
            THIS SCRIPT IS PROVIDED "AS IS" WITHOUT WARRANTIES OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING
            ANY WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE OR NON- INFRINGEMENT.
            LOGIN CONSULTANTS, SHALL NOT BE LIABLE FOR TECHNICAL OR EDITORIAL ERRORS OR OMISSIONS CONTAINED 
            HEREIN, NOT FOR DIRECT, INCIDENTAL, CONSEQUENTIAL OR ANY OTHER DAMAGES RESULTING FROM FURNISHING,
            PERFORMANCE, OR USE OF THIS SCRIPT, EVEN IF LOGIN CONSULTANTS HAS BEEN ADVISED OF THE POSSIBILITY
            OF SUCH DAMAGES IN ADVANCE.
    #>
     
    [CmdletBinding()]
    Param( 
        [parameter(mandatory=$True)]  
        [ValidateNotNullorEmpty()]
        [String]$EventLog,
        [parameter(mandatory=$True)]  
        [ValidateNotNullorEmpty()]
        [String]$Source,
        [parameter(mandatory=$True)]
        [Int]$EventID,
        [parameter(mandatory=$True)]
        [ValidateNotNullorEmpty()]
        [String]$Type,
        [parameter(mandatory=$True)]
        [ValidateNotNullorEmpty()]
        [String]$Message
    )
  
    begin {
        
    }
  
    process {
        # Check if the event log exist. If not, create it.
        if ( !( [System.Diagnostics.EventLog]::Exists( $EventLog ) ) ) {
            try {
                New-EventLog -LogName $EventLog -Source $EventLog
            } catch {
                Write-Error "An error occurred trying to create the event log '$EventLog' (error: $($Error[0]))!"
 
            }
        } 
 
        # Check if the event source exist. If not, create it.
        if ( !( [System.Diagnostics.EventLog]::SourceExists( $Source ) ) ) {
            try {
                [System.Diagnostics.EventLog]::CreateEventSource( $Source, $EventLog )   
            } catch {
                Write-Error "An error occurred trying to create the event source '$Source' (error: $($Error[0]))!"
            }
        } 
                 
    # Write the event log entry     
    try {
        Write-EventLog -LogName $EventLog -Source $Source -eventID $EventID -EntryType $Type -message $Message
    } catch {
        Write-Verbose "An error occurred trying to write the event log entry (error: $($Error[0]))!"
        }
    }
  
    end {
    }
} #EndFunction Write-ELog
Export-ModuleMember -Function Write-ELog

Function Stop-FLog {
    
    [CmdletBinding()]
    Param( 
        [Parameter(Mandatory=$true, Position = 0)][String]$LogFile,
        [Parameter(Mandatory=$true, Position = 1)][String]$ScriptName
    )

    begin {
        $DateTime = Get-Date -uformat "%Y-%m-%d_%H-%M"

        # Insert log file Footer
        Add-Content $LogFile -value ("********************************************************************************")
        Add-Content $LogFile -value ("Finish logging for $ScriptName @ $DateTime")
        Add-Content $LogFile -value ("********************************************************************************")
    }

    process {

    }

    end {

    }


}
Export-ModuleMember -Function Stop-FLog
