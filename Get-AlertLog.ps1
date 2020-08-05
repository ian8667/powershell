<#

File Name    : Compress-File.ps1
Author       : Ian Molloy
Last updated : 2020-08-03T22:48:14

#>

[cmdletbinding()]
Param (
    [parameter(Mandatory=$true,
               HelpMessage="Enter the computer name to check",
               Position=0)]
    [ValidateNotNullOrEmpty()]
    [String]
    $ComputerName
) #end param

#----------------------------------------------------------
# Start of functions
#----------------------------------------------------------

#region ***** function main_routine *****
##=============================================
## Function: main_routine
## Last updated: 2013-08-21
## Author: Ian Molloy
## Arguments: none
##=============================================
## Purpose: main helper function to gather all
## other function calls together.
##
## Returns: N/A
##=============================================
function main_routine {

  if ($PSBoundParameters['Verbose']) {
     Write-Host "doing some verbose things";
     Write-Host "this is mighty fun";
  }

  if (Ping($ComputerName)) {

    Get-Script-Info;

    [Array]$sidList = Get-OracleInstances;
    if (! $sidList) {
       Write-Warning -Message "No Oracle instances found on computer $ComputerName";
       exit 1;
    }

    #Call the Function
    GenerateForm $sidList;

  } else {
    Write-Warning -Message "Computer $ComputerName is not online";
  }

}
#endregion ***** end of function main_routine *****

#----------------------------------------------------------

#region ***** function Get-OracleInstances *****
##=============================================
## Function: Get-OracleInstances
## Created: 2013-08-22
## Author: Ian Molloy
## Arguments: none
##=============================================
## Purpose: obtains a list of Oracle instances (if any).
##
## Returns: an array containing the instances found. If
##          there are no instances, an empty array will
##          be returned.
##
## Note: the words SID and Instance are used interchangeably.
##=============================================
function Get-OracleInstances() {

Begin {
  $sidlist = @();
  $props = @{
       Class = "Win32_Service";
       Namespace = "root\cimv2";
       Filter = "Name Like 'OracleService%'";
       ComputerName = $ComputerName;
   }
}

Process {
   Get-WmiObject @props | foreach-object {
      $longname = $_.Name;
      Write-Verbose "`ndisplay name is now $longname";

      $shortname = $longname -replace "OracleService", "";
      Write-Verbose "the cut down name is $shortname";

      $sidlist += $shortname;
   }
}

End {
  return $sidlist;
}

}
#endregion ***** end of function Get-OracleInstances *****

#----------------------------------------------------------

#region ***** function ping *****
#*=============================================
#* Function: Ping
#* Last updated: 2013-08-20
#* Author: Ian Molloy
#* Arguments: Computer - the computer to check
#*=============================================
#* Purpose: Determines whether the computer is online or not.
#* Returns:
#* true if and only if the computer supplied as a parameter
#* is online; false otherwise
#*=============================================
function Ping()
{
[cmdletbinding()]
Param (
        [parameter(Mandatory=$true,
                   Position=0)]
        [ValidateNotNullOrEmpty()]
        [String]
        $ComputerName
      ) #end param

Begin {
  [Int32]$timeout = 4000;
  [Boolean]$retval = $true;

  $ping = New-Object -TypeName System.Net.NetworkInformation.Ping;
}

Process {
  # -> hostNameOrAddress
  # A String that identifies the computer that is the destination
  # for the ICMP echo message.
  # -> timeout
  # An Int32 value that specifies the maximum number of milliseconds
  # (after sending the echo message) to wait for the ICMP echo reply
  # message.
  Write-Verbose -Message "Pinging the computer with a timeout of $timeout milliseconds";

  Try
  {

    $reply = $ping.Send($ComputerName, $timeout);

    if ( $reply.Status -eq "Success" )
    {
       $retval = $true;
    }
    else
    {
       $retval = $false;
    }
  }
  Catch [System.Management.Automation.MethodInvocationException]
  {
     $retval = $false;
  }
}

End {
  $ping.Dispose();
  Write-Verbose -Message "Returning from function Ping with a value of $retval";
  return $retval;
}

} # end of Ping
#endregion ***** end of function ping *****

#----------------------------------------------------------

#region ***** function Get-Script-Info *****
##=============================================
## Function: Get-Script-Info
## Created: 2013-05-25
## Author: Ian Molloy
## Arguments: none
##=============================================
## Purpose: displays the script name and folder from
## where the script is running from.
##
## Returns: N/A
##=============================================
function Get-Script-Info()
{

Begin {}

Process {
  if ($MyInvocation.ScriptName) {
       $p1 = Split-Path -Leaf $MyInvocation.ScriptName;
       $p2 = Split-Path -Parent $MyInvocation.ScriptName;
       Write-Host "`nExecuting script ""$p1"" in folder ""$p2""";
  } else {
      $MyInvocation.MyCommand.Definition;
  }
}

End {}

}
#endregion ***** end of function Get-Script-Info *****

#----------------------------------------------------------

#region ***** function GenerateForm *****
function GenerateForm {
########################################################################
# Code Generated By: SAPIEN Technologies PrimalForms (Community Edition) v1.0.10.0
# Generated On: 25/08/2013 15:51
# Generated By: w7
########################################################################
Param (
        [parameter(Mandatory=$true,
                   Position=0)]
        [ValidateNotNullOrEmpty()]
        [Array]
        $InstanceList
      ) #end param

#region Import the Assemblies
[reflection.assembly]::loadwithpartialname("System.Windows.Forms") | Out-Null;
[reflection.assembly]::loadwithpartialname("System.Drawing") | Out-Null;
#endregion

#region Generated Form Objects
$myfont = New-Object System.Drawing.Font("Microsoft Sans Serif",9.75,0,3,0);
$ComputerNames = @("server1","server2","server3","server4","server5");
$editor = "C:\windows\notepad.exe"; #Editor we wish to view the file with.
Set-Variable -Name $ComputerNames -Option ReadOnly;
Set-Variable -Name $editor -Option ReadOnly;

# Details of the alert log(s) that we're looking for.
$searchinfo = New-Object -TypeName PSObject;
Add-Member -InputObject $searchinfo -MemberType NoteProperty -Name Path -Value "";
Add-Member -InputObject $searchinfo -MemberType NoteProperty -Name Filter -Value "alert*.log";

$fileobj = New-Object -TypeName PSObject;
Add-Member -InputObject $fileobj -MemberType NoteProperty -Name ShortPath -Value "";
Add-Member -InputObject $fileobj -MemberType NoteProperty -Name Filename -Value "";
Add-Member -InputObject $fileobj -MemberType NoteProperty -Name FullPath -Value "";

$form1 = New-Object -TypeName System.Windows.Forms.Form
$listBox1 = New-Object -TypeName System.Windows.Forms.ListBox
$label1 = New-Object -TypeName System.Windows.Forms.Label
$comboBox1 = New-Object -TypeName System.Windows.Forms.ComboBox
$quitB = New-Object -TypeName System.Windows.Forms.Button
$listB = New-Object -TypeName System.Windows.Forms.Button
$viewB = New-Object -TypeName System.Windows.Forms.Button
$InitialFormWindowState = New-Object -TypeName System.Windows.Forms.FormWindowState
#endregion Generated Form Objects

#----------------------------------------------
#Generated Event Script Blocks
#----------------------------------------------

# Button to view the file as selected.
$viewB_OnClick=
{
   #TODO:
   Write-Host "the viewfile onclick bit";
   # Get the filename as selected in the ListBox.
   $fileobj.FileName = $listBox1.SelectedItem.ToString();
   # Combine (join) the short path with the filename to form the absolute
   # fullpath of the file.
   $fileobj.FullPath = [System.IO.Path]::Combine($fileobj.ShortPath,$fileobj.FileName);
   Out-String -InputObject $fileobj;

   # View the file just selected with the editor defined.
   & $editor $fileobj.FullPath;
}

# Button to quite the application.
$quitB_OnClick=
{
   #TODO:
   $form1.Dispose();
   $form1.Close();
}

# Button to list the files.
$listB_OnClick=
{
   #TODO:

   # Get the Oracle Sid with which we can find the correct bdump directory.
   $osid = $comboBox1.SelectedItem.ToString();
   $searchinfo.Path = Get-BdumpDirectory $osid;
   Get-ChildItem -Path $searchinfo.Path -Filter $searchinfo.Filter |
       Sort-Object CreationTime |
       ForEach-Object {
         $listBox1.Items.Add($_.Name);
         $fileobj.ShortPath = $_.DirectoryName;
       }
   $viewB.Enabled = $true;
   $listB.Enabled = $false;
}

$OnLoadForm_StateCorrection=
{#Correct the initial state of the form to prevent the .Net maximized form issue
  $form1.WindowState = $InitialFormWindowState
}

#----------------------------------------------
#region Generated Form Code
$System_Drawing_Size = New-Object System.Drawing.Size
$System_Drawing_Size.Height = 262
$System_Drawing_Size.Width = 469
$form1.ClientSize = $System_Drawing_Size
$form1.DataBindings.DefaultDataSourceUpdateMode = 0
$form1.Name = "form1"
$form1.Text = "Primal Form"
$form1.StartPosition = "CenterScreen";

$listBox1.DataBindings.DefaultDataSourceUpdateMode = 0
$listBox1.FormattingEnabled = $True
$System_Drawing_Point = New-Object System.Drawing.Point
$System_Drawing_Point.X = 24
$System_Drawing_Point.Y = 42
$listBox1.Location = $System_Drawing_Point
$listBox1.Name = "listBox1"
$System_Drawing_Size = New-Object System.Drawing.Size
$System_Drawing_Size.Height = 160
$System_Drawing_Size.Width = 407
$listBox1.Size = $System_Drawing_Size
$listBox1.TabIndex = 5
$listBox1.Font = $myfont;
$form1.Controls.Add($listBox1)

$label1.DataBindings.DefaultDataSourceUpdateMode = 0

$System_Drawing_Point = New-Object System.Drawing.Point
$System_Drawing_Point.X = 24
$System_Drawing_Point.Y = 15
$label1.Location = $System_Drawing_Point
$label1.Name = "label1"
$System_Drawing_Size = New-Object System.Drawing.Size
$System_Drawing_Size.Height = 23
$System_Drawing_Size.Width = 100
$label1.Size = $System_Drawing_Size
$label1.TabIndex = 4
$label1.TabStop = $True
$label1.Text = $ComputerName;
$label1.Font = $myfont;
$form1.Controls.Add($label1)

$comboBox1.DataBindings.DefaultDataSourceUpdateMode = 0
$comboBox1.FormattingEnabled = $True
$System_Drawing_Point = New-Object System.Drawing.Point
$System_Drawing_Point.X = 310
$System_Drawing_Point.Y = 12
$comboBox1.Location = $System_Drawing_Point
$comboBox1.Name = "comboBox1"
$System_Drawing_Size = New-Object System.Drawing.Size
$System_Drawing_Size.Height = 21
$System_Drawing_Size.Width = 121
$comboBox1.Size = $System_Drawing_Size
$comboBox1.TabIndex = 3
# Add Oracle Instance names to the combobox. It could be there
# is only one name to add.
ForEach ($item in $instanceList) {
     $aa = $comboBox1.Items.Add($item);
}
$form1.Controls.Add($comboBox1)
# Set ComboBox to the first item in the list.
$comboBox1.SelectedIndex = 0;
$comboBox1.Font = $myfont;


$quitB.DataBindings.DefaultDataSourceUpdateMode = 0

$System_Drawing_Point = New-Object System.Drawing.Point
$System_Drawing_Point.X = 172
$System_Drawing_Point.Y = 227
$quitB.Location = $System_Drawing_Point
$quitB.Name = "quitB"
$System_Drawing_Size = New-Object System.Drawing.Size
$System_Drawing_Size.Height = 23
$System_Drawing_Size.Width = 75
$quitB.Size = $System_Drawing_Size
$quitB.TabIndex = 2
$quitB.Text = "Quit"
$quitB.UseVisualStyleBackColor = $True
$quitB.add_Click($quitB_OnClick)

$form1.Controls.Add($quitB)


$listB.DataBindings.DefaultDataSourceUpdateMode = 0

$System_Drawing_Point = New-Object System.Drawing.Point
$System_Drawing_Point.X = 263
$System_Drawing_Point.Y = 227
$listB.Location = $System_Drawing_Point
$listB.Name = "listB"
$System_Drawing_Size = New-Object System.Drawing.Size
$System_Drawing_Size.Height = 23
$System_Drawing_Size.Width = 75
$listB.Size = $System_Drawing_Size
$listB.TabIndex = 1
$listB.Text = "List Files"
$listB.UseVisualStyleBackColor = $True
$listB.add_Click($listB_OnClick)

$form1.Controls.Add($listB)


$viewB.DataBindings.DefaultDataSourceUpdateMode = 0

$System_Drawing_Point = New-Object System.Drawing.Point
$System_Drawing_Point.X = 356
$System_Drawing_Point.Y = 227
$viewB.Location = $System_Drawing_Point
$viewB.Name = "viewB"
$System_Drawing_Size = New-Object System.Drawing.Size
$System_Drawing_Size.Height = 23
$System_Drawing_Size.Width = 75
$viewB.Size = $System_Drawing_Size
$viewB.TabIndex = 0
$viewB.Text = "View File"
$viewB.UseVisualStyleBackColor = $True
$viewB.add_Click($viewB_OnClick)
$viewB.Enabled = $false;
$form1.Controls.Add($viewB)

#endregion Generated Form Code

#Save the initial state of the form
$InitialFormWindowState = $form1.WindowState
#Init the OnLoad event to correct the initial state of the form
$form1.add_Load($OnLoadForm_StateCorrection)
#Show the Form
$form1.ShowDialog()| Out-Null

} #End Function
#endregion ***** end of function GenerateForm *****

#----------------------------------------------------------

#region ***** function Get-BdumpDirectory *****
##=============================================
## Function: Get-BdumpDirectory
## Created: 2013-09-23
## Author: Ian Molloy
## Arguments: OracleSid
## The Oracle Sid for which to find the bdump directory.
##=============================================
## Purpose: finds the bdump directory for the Oracle Sid
##          supplied.
##
## Returns: the bdump directory pathname.
##
## Note: the words SID and Instance are used interchangeably.
## Note: the variable ComputerName is taken from the global
##       context.
##=============================================
function Get-BdumpDirectory() {
Param (
        [parameter(Mandatory=$true,
                   HelpMessage="Enter the Oracle Sid",
                   Position=0)]
        [ValidateNotNullOrEmpty()]
        [String]
        $OracleSid
      ) #end param

Begin {
  $retval = "";
  $Regex = [regex]"\d{2}.\d{1}.\d{1}"; # ie 10.2.0, 6 characters.
  $myFilter = ("Name = 'OracleService{0}'" -f $OracleSid);
  $props = @{
         Class = "Win32_Service";
         Namespace = "root\cimv2";
         Filter = $myFilter;
         ComputerName = $ComputerName;
  }
}

Process {
  # d:\oracle\product\10.2.0\db\bin\ORACLE.EXE ORCL1
  Get-WmiObject @props | select PathName |
     ForEach-Object {
        $pp = $_.Pathname.ToString();
        $myMatch = $Regex.Match( $pp );
        $pos = ($myMatch.Index + $myMatch.Length);
        $newsub = $pp.Substring(0,$pos);
        $retval = ("{0}\admin\{1}\bdump" -f $newsub,$OracleSid);
     }
}

End {
  return $retval;
}

}
#endregion ***** end of function Get-BdumpDirectory *****

#----------------------------------------------------------
# End of functions
#----------------------------------------------------------

##=============================================
## SCRIPT BODY
## MAIN ROUTINE STARTS HERE
##=============================================
main_routine;
##=============================================
## END OF SCRIPT: Get-AlertLog.ps1
##=============================================
