<#
.SYNOPSIS

Makes a connection to an Oracle database.

.DESCRIPTION

Makes a connection to an Oracle database and executes a basic
SQL query for testing purposes. This can be used to determine
whether a database is OK or not.

.PARAMETER DatabaseName

The name of the database you wish to log in to. This is
essentially the TNS alias from the tnsnames.ora file.

This is a mandatory parameter.

.PARAMETER UserName

The username you wish to log in as.

This is a mandatory parameter.

.EXAMPLE

./Test-OracleDb.ps1 -DatabaseName orcl -UserName scott

Named parameters used to specify the database name and
username to log in as.

.EXAMPLE

./Test-OracleDb.ps1 orcl -UserName

Positional parameters used to specify the database name and
username to log in as.

Be careful to provide values in the same order in which the
parameters are listed, i.e. database name and username.

.EXAMPLE

./Test-OracleDb.ps1

As no parameters have been supplied, you will be prompted for
the database name and username to use.

.INPUTS

None. No .NET Framework types of objects are used as input.

.OUTPUTS

None. No .NET Framework types of objects are output from this script.

.NOTES

Additional information about the function or script.
Additional Notes, eg:

File Name    : Test-OracleDb.ps1
Author       : Ian Molloy
Last updated : 2020-08-05T13:03:47

For information regarding this subject (comment-based help),
execute the command:
PS> Get-Help about_comment_based_help

.LINK

about_Comment_Based_Help
http://technet.microsoft.com/en-us/library/dd819489.aspx

WTFM: Writing the Fabulous Manual
http://technet.microsoft.com/en-us/magazine/ff458353.aspx

about_Functions_Advanced_Parameters
http://technet.microsoft.com/en-us/library/hh847743.aspx

Cmdlet Parameter Sets
http://msdn.microsoft.com/en-us/library/windows/desktop/dd878348(v=vs.85).aspx
#>

[cmdletbinding()]
Param (
    [parameter(Mandatory=$true,
               HelpMessage="Enter the database name to check",
               Position=0)]
    [ValidateNotNullOrEmpty()]
    [String]
    $DatabaseName,

    [parameter(Mandatory=$true,
               HelpMessage="Enter the username to log in as",
               Position=1)]
    [ValidateNotNullOrEmpty()]
    [String]
    $UserName
) #end param

#----------------------------------------------------------
# Start of functions
#----------------------------------------------------------

#region ***** function main_routine *****
##=============================================
## Function: main_routine
## Last updated: 2013-09-24
## Author: Ian Molloy
## Arguments: none
##=============================================
## Purpose: main helper function to gather all other
##          function calls together.
##
## Returns: N/A
##=============================================
function main_routine {
[CmdletBinding()]
#[OutputType([System.Double])]
Param () #end param

Begin {
  if ($PSBoundParameters['Verbose']) {
     Write-Output "doing some verbose things";
     Write-Output "this is mighty fun";
  }

  $dll = "C:\app\oracle\product\11.2.0\client_1\ODP.NET\bin\2.x\Oracle.DataAccess.dll";
  Set-Variable -Name 'dll' -Option ReadOnly;
}

Process {
  Write-Verbose -Message "Loading assembly: `n$dll";
  [System.Reflection.Assembly]::LoadFile($dll) | out-null;

  Write-Verbose -Message "Calling Get-OracleCommand";
  $cmd = Get-OracleCommand;
  $cmd.CommandText = Get-QueryString;

  Write-Verbose -Message "About to execute the query";
  $reader = $cmd.ExecuteReader();

  Write-Verbose -Message "Looking at the resultset";
  $myuser = "";
  $mydb = "";
  $bbool = $reader.Read();
  $myuser = $reader.GetOracleString(0);
  $mydb = $reader.GetOracleString(1);

  Write-Output "Connected to database $mydb as user $myuser";
}

End {
  #Clean up section.
  $reader.Close();
  $reader.Dispose();
  $cmd.Dispose();
}

}
#endregion ***** end of function main_routine *****

#----------------------------------------------------------

#region ***** function Get-QueryString *****
##=============================================
## Function: Get-QueryString
## Last updated: 2013-09-24
## Author: Ian Molloy
## Arguments: none
##=============================================
## Purpose: Constucts the SQL query which will be executed
##          when connected to the database.
##
## Returns: the SQL query as a string.
##=============================================
function Get-QueryString {
[CmdletBinding()]
#[OutputType([System.Double])]
Param () #end param

Begin {
    Write-Verbose -Message "Constructing the SQL query";
}

Process {
$query = @'
SELECT current_user, instance
FROM   (SELECT Sys_context('USERENV', 'SESSION_USER') AS CURRENT_USER
        FROM   dual),
       (SELECT Sys_context('USERENV', 'INSTANCE_NAME') AS INSTANCE
        FROM   dual)
'@
}

End {
  Write-Verbose -Message "The query is currently:`n$query";

  return $query;
}

} #end Get-QueryString
#endregion ***** end of function Get-QueryString *****

#----------------------------------------------------------

#region ***** function Get-OracleConnection *****
##=============================================
## Function: Get-OracleConnection
## Last updated: 2013-09-24
## Author: Ian Molloy
## Arguments: none
##=============================================
## Purpose: Creates an OracleConnection object enabling a
##          connection to be made to an Oracle database.
##
## Returns: an OracleConnection object connected to the database
##          specified in the connection string.
##=============================================
## See also:
## OracleConnection Class
## http://docs.oracle.com/html/B28089_01/OracleConnectionClass.htm
##=============================================
function Get-OracleConnection {
[CmdletBinding()]
#[OutputType([System.Double])]
Param () #end param

Begin {
  Write-Verbose -Message "Attempting to get a connection to the database";

  #Get the password for the username specified.
  Write-Output ("Database {0}, username {1}" -f $DatabaseName, $UserName);
  $password = Read-Host -AsSecureString "Please enter the password for the above user";

  $password = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto(
        [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($password));

  $user_info = @{
        UserId        = $UserName;
        Password      = $password;
        DataSource    = $DatabaseName;
  }
  $user = New-Object -TypeName PSObject -Property $user_info;

  $connString = ("User Id={0};Password={1};Data Source={2}" -f
                 $user.UserId,
                 $user.Password,
                 $user.DataSource
                 );
}

Process {
  $f_conn = New-Object -TypeName Oracle.DataAccess.Client.OracleConnection($connString);
  $f_conn.Open();
}

End {
  Write-Verbose -Message "Connection should be open now";

  return $f_conn;
}

} #end Get-OracleConnection
#endregion ***** end of function Get-OracleConnection *****

#----------------------------------------------------------

#region ***** function Get-OracleCommand *****
##=============================================
## Function: Get-OracleCommand
## Last updated: 2013-09-24
## Author: Ian Molloy
## Arguments: none
##=============================================
## Purpose: Creates an OracleCommand object enabling a SQL
##          query to be executed on the database.
##
## Returns: the OracleCommand object created.
##=============================================
## See also:
## OracleCommand Class
## http://docs.oracle.com/html/B28089_01/OracleCommandClass.htm
##=============================================
function Get-OracleCommand {
[CmdletBinding()]
#[OutputType([System.Double])]
Param () #end param

Begin {
  # This property specifies the number of seconds that the
  # command is allowed to execute before terminating with an
  # exception. In other words we expect the command to
  # complete within this number of seconds.
  #
  # When the specified timeout value expires before a command
  # execution finishes, the command attempts to cancel. If
  # cancellation is successful, an exception is thrown with
  # the message of ORA-01013: user requested cancel of current
  # operation. If the command executed in time without any
  # errors, no exceptions are thrown.
  $seconds = 12;

  $f_cmd = New-Object -TypeName Oracle.DataAccess.Client.OracleCommand;
  $f_cmd.CommandTimeout = $seconds;
  $f_cmd.CommandType = [System.Data.CommandType]::Text;
}

Process {
  #Get the connection object previously created.
  $f_cmd.Connection = Get-OracleConnection;
}

End {
  return $f_cmd;
}

} #end Get-OracleCommand
#endregion ***** end of function Get-OracleCommand *****

#----------------------------------------------------------
# End of functions
#----------------------------------------------------------

##=============================================
## SCRIPT BODY
## Main routine starts here
##=============================================
Set-StrictMode -Version Latest;
$ErrorActionPreference = "Stop";

Invoke-Command -ScriptBlock {

   Write-Output '';
   Write-Output 'Connecting to an Oracle database';
   $dateMask = Get-Date -Format 'dddd, dd MMMM yyyy HH:mm:ss';
   Write-Output ('Today is {0}' -f $dateMask);

   $script = $MyInvocation.MyCommand.Name;
   $scriptPath = Split-Path -Parent -Path $MyInvocation.MyCommand.Definition;
   Write-Output ('Running script {0} in directory {1}' -f $script,$scriptPath);

}

main_routine;
##=============================================
## END OF SCRIPT: Test-OracleDb.ps1
##=============================================
