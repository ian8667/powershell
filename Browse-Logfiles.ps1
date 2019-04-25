<#
.SYNOPSIS

Displays a hierarchical collection of directories and log files.

.DESCRIPTION

Uses the .NET TreeView Class to display a hierarchical collection
of directories and log files. The System.Windows.Forms namespace
contains classes for creating Windows-based applications that
take full advantage of the rich user interface features available
in the Microsoft Windows operating system. This means the program
is a GUI style program, not really console based.

This program came about by the need to check RMAN log files.
Rather than having to visit each server in turn, the log files
are copied to the local computer which facilitates the provision
of being able to browse these log files in a predefined directory
structure by selecting the log files from a tree view.

PowerShell script Get-RmanLogfiles.ps1 has to be run before using
this program. It copies the files to be checked and also creates
the predefined directory structure expected. The log files have
been copied from several servers and placed on the local machine.
One directory has been created per server. Log files from a server
will be placed in its respective directory. This is how we know
here the log file came from.

Functionally, this program uses the concept of the following nodes:

Root node - one only
Directory node - one directory node for each server where log
                 files have been copied from.
Logfile node - one logfile node for each log file. There could be
               many log files to check so therefore, many logfile
               nodes per each directory node.

The directory structure will look as follows:
<base directory> (Root node. C:/Temp for example)
|
--> Server01 (Directory node)
|
--------> logfile01.log (Logfile node)
|
--------> logfile02.log (Logfile node)
|
--> Server02 (Directory node)
|
--------> logfile03.log (Logfile node)
|
--------> logfile04.log (Logfile node)
|
--> Server05 (Directory node)
|
--------> logfile05.log (Logfile node)
|
--------> logfile06.log (Logfile node)
|
--> Server99 (Directory node)
|
--------> logfile07.log (Logfile node)
|
--------> logfile08.log (Logfile node)

.EXAMPLE

./Get-Lastlines.ps1

No parameters are required

.INPUTS

None, no .NET Framework types of objects are used as input.

.OUTPUTS

No .NET Framework types of objects are output from this script.

.NOTES

File Name    : Browse-Logfiles.ps1
Author       : Ian Molloy
Last updated : 2019-04-22
Keywords     : rman log file

.LINK

TreeNode Class
Represents a node of a TreeView.
https://docs.microsoft.com/en-us/dotnet/api/system.windows.forms.treenode?view=netframework-4.8

TreeView Class
Displays a hierarchical collection of labeled items, each
represented by a TreeNode.
https://docs.microsoft.com/en-us/dotnet/api/system.windows.forms.treeview?view=netframework-4.8

About Comment Based Help
Describes how to write comment-based help topics for functions
and scripts.
https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_comment_based_help?view=powershell-6

#>

[CmdletBinding()]
Param () #end param


#region ***** function Ask-Continue *****
function Ask-Continue {
<#
.SYNOPSIS
Asks whether log files have been copied to the local computer

.DESCRIPTION
Seeks confirmation from the user whether it's OK to continue. If
the response is no, a warning message is issued asking for the
files to be copied and to try running the program again.

#>

[CmdletBinding()]
Param () #end param

Add-Type -AssemblyName 'System.Windows.Forms';
#[reflection.assembly]::loadwithpartialname("System.Windows.Forms") | Out-Null;

$text = @"
Use of this program requires RMAN log files to be
copied to your local machine for checking.

OK to continue?
"@
$caption = 'Check RMAN log files';
$buttons = [System.Windows.Forms.MessageBoxButtons]::YesNo;
$icon = [System.Windows.Forms.MessageBoxIcon]::Question;
$default = [System.Windows.Forms.MessageBoxDefaultButton]::Button2;

$retval = [System.Windows.Forms.MessageBox]::Show($text, $caption, $buttons, $icon, $default);

  return $retval;
}
#endregion ***** end of function Ask-Continue *****


#region ***** function Create-Node *****
function Create-Node {
<#
.SYNOPSIS
Creates a new TreeNode object

.DESCRIPTION
Creates the next node to be inserted into the tree.

.PARAMETER NameOfNode
Contains the absolute path to a log file or directory the script
is looking at. Used to populate the following TreeNode Class
properties: Name, Text and Tag.

Properties 'Name' and 'Text' contain the leaf of the path only.
Property 'Tag' holds the absolute path as this is required to view
logfile nodes. This information is ignored for all other nodes.
#>
  [CmdletBinding()]
  Param (
    [parameter(Position=0,
               Mandatory=$true)]
    [ValidateNotNullOrEmpty()]
    [System.String]$NameOfNode
  ) #end param

  $shortName = Split-Path -Path $NameOfNode -Leaf;

  $NewNode = New-Object -TypeName 'System.Windows.Forms.TreeNode';
  $NewNode.Name = $shortName;
  $NewNode.Text = $shortName; # Text displayed is the label of the tree node.
  $NewNode.Tag = $NameOfNode;

  return $NewNode;
}
#endregion ***** end of function Create-Node *****


#region ***** function Get-Directory *****
function Get-Directory {
<#
.SYNOPSIS
Allows the user to select a directory to work from

.DESCRIPTION
The directory selected here is in effect the base directory
from the which the program will work from. The files and
directories found here will have been created and copied
by an earlier process.

#>

    Add-Type -AssemblyName "System.Windows.Forms";
    #[System.Reflection.Assembly]::LoadWithPartialName("System.windows.forms");

    $myok = [System.Windows.Forms.DialogResult]::OK;
    [System.Windows.Forms.FolderBrowserDialog]$ofd = New-Object -TypeName 'System.Windows.Forms.FolderBrowserDialog';
    [System.Windows.Forms.Application]::EnableVisualStyles();
    $ofd.Description = "Select a directory";
    $ofd.RootFolder=[System.Environment+SpecialFolder]::MyComputer;
    $ofd.ShowNewFolderButton=$false;

    if ($ofd.ShowDialog() -eq $myok) {
        $ret = $ofd.SelectedPath;
    } else {
        Throw "No directory chosen or selected";
    }
    $ofd.Dispose();

    return $ret;
}
#endregion ***** end of function Get-Directory *****

#region ***** function GenerateForm *****
function GenerateForm {
########################################################################
# Code Generated By: SAPIEN Technologies PrimalForms (Community Edition) v1.0.10.0
# Generated On: 21 April 2019
# Generated By: Ian M
########################################################################

#region Import the Assemblies
[reflection.assembly]::loadwithpartialname("System.Windows.Forms") | Out-Null;
[reflection.assembly]::loadwithpartialname("System.Drawing") | Out-Null;
#endregion

#region Generated Form Objects
$form1 = New-Object -TypeName 'System.Windows.Forms.Form';
$viewfile = New-Object -TypeName 'System.Windows.Forms.Button';
$getdir = New-Object -TypeName 'System.Windows.Forms.Button';
$quitapp = New-Object -TypeName 'System.Windows.Forms.Button';
$treeView1 = New-Object -TypeName 'System.Windows.Forms.TreeView';
$label1 = New-Object -TypeName 'System.Windows.Forms.Label';
$InitialFormWindowState = New-Object -TypeName 'System.Windows.Forms.FormWindowState';

# The default font used would be:
# [Font: Name=Microsoft Sans Serif, Size=8.25, Units=3, GdiCharSet=0, GdiVerticalFont=False]
$myFont = New-Object -TypeName System.Drawing.Font("Microsoft Sans Serif", 11.25, 0, 3, 0);
Set-Variable -Name 'myFont' -Option ReadOnly;

# Preferred size for button
# Stores an ordered pair of integers, which specify a
# Height and Width for the button
$ButtonSize = New-Object -TypeName 'System.Drawing.Size';
$ButtonSize.Height = 25;
$ButtonSize.Width = 75;
Set-Variable -Name 'ButtonSize' -Option ReadOnly;

#Control.Location Property
#Gets or sets the coordinates of the upper-left corner of the
#control relative to the upper-left corner of its container.
$ComponentLocation = New-Object -TypeName 'System.Drawing.Point';

#Control.Size Property
#Gets or sets the height and width of the control.
$ComponentSize = New-Object -TypeName 'System.Drawing.Size';

$tooltip = New-Object -TypeName 'System.Windows.Forms.ToolTip';
$tooltip.InitialDelay = 1000; # milliseconds
$tooltip.IsBalloon = $true;
$tooltipmsg = '';

#endregion Generated Form Objects

#----------------------------------------------
#Generated Event Script Blocks
#----------------------------------------------
#Provide Custom Code for events specified in PrimalForms.
$quitapp_OnClick=
{
#TODO: Place custom script here
  # Close and exit the application
  $form1.Close();
  $form1.Dispose();
}

$handler_treeView1_AfterSelect=
{
#TODO: Place custom script here

}

$getdir_OnClick=
{
#Gets the base directory to work from. Then builds (populates)
#tree structure.
[System.Windows.Forms.TreeNode]$currentNode = New-Object -TypeName 'System.Windows.Forms.TreeNode';
[System.Windows.Forms.TreeNode]$newObj = New-Object -TypeName 'System.Windows.Forms.TreeNode';


$treeView1.BeginUpdate();


# Get the user to choose a directory
$mydir = Get-Directory;

# Show on the form which directory we've selected (chosen)
$label1.Text = $mydir;

# Get a list of subdirectories this selected (chosen)
# directory has
$dirList = Get-ChildItem -Path $mydir -Directory;
$counter = ($dirList | Measure-Object).Count;

if ($counter -eq 0) {
   Write-Warning -Message "No subdirectories found in the chosen directory $($mydir)";
} else {

  # Outer loop to add directory nodes just under the root node
  Write-Verbose -Message "$($counter) directories to add`n";
  foreach ($item in (Get-ChildItem -Path $mydir -Directory)) {
    Write-Verbose "Looking at directory $($item.FullName)`n";
    $tipmsg = '';

    # Get a list logfiles found in the current directory we're looking at
    $subfileList = Get-ChildItem -Path $item.FullName -File -Filter '*.log';
    $counter = ($subfileList | Measure-Object).Count;

    if ($counter -eq 0) {
       Write-Warning -Message "No logfile nodes to add for directory $($item)";
       $kolor = [System.Drawing.Color]::Red;
       $tipmsg = '. No log files found';
    } else {
       $kolor = [System.Drawing.Color]::Black;
    }

    # Create a directory node for the current directory
    $newObj = Create-Node -NameOfNode $item.FullName;
    $newObj.ForeColor = $kolor;
    $newObj.ToolTipText = "Directory: $($item.FullName)" + $tipmsg;
    Add-Member -NotePropertyName 'Logfile' -NotePropertyValue $false -InputObject $newObj;

    $rootnode.Nodes.Add($newObj) | Out-Null;
    $currentNode = $rootnode.LastNode;

    Write-Verbose -Message "$($counter) logfile nodes to add for directory $($item)";
    # Inner loop to add logfile nodes for the directory node just entered
    foreach ($logfile in $subfileList) {
       $newObj = Create-Node -NameOfNode $logfile.FullName;
       Add-Member -NotePropertyName 'Logfile' -NotePropertyValue $true -InputObject $newObj;
       $currentNode.Nodes.Add($newObj) | Out-Null;
    }

  }
  $getdir.Enabled = $false;
  $viewfile.Enabled = $true;

}

$treeView1.EndUpdate();

} #end getdir_OnClick

$viewfile_OnClick=
{
#Enables the user to view (browse) log files. A error type
#dialog box, which presents a message to the user will be
#displayed if the object selected is not a log file node.
[System.Windows.Forms.TreeNode]$currentNode = New-Object -TypeName 'System.Windows.Forms.TreeNode;';

$currentNode = $treeView1.SelectedNode;

if ($currentNode.Logfile) {

   $notepad = 'C:\windows\system32\notepad.exe';
   $logfilePath = $currentNode.Tag.ToString();
   & $notepad $logfilePath;

} else {
$text = @"
Unable to view object $($currentNode.Name)
Please ensure you attempt to view logfiles only
"@
$caption = 'View error';
$buttons = [System.Windows.Forms.MessageBoxButtons]::OK;
$icon = [System.Windows.Forms.MessageBoxIcon]::Error;
$def = [System.Windows.Forms.MessageBoxDefaultButton]::Button1;

$retval = [System.Windows.Forms.MessageBox]::Show($text, $caption, $buttons, $icon, $def);
}


} #end viewfile_OnClick

$OnLoadForm_StateCorrection=
{#Correct the initial state of the form to prevent the .Net maximized form issue
  $form1.WindowState = $InitialFormWindowState;
}

#-------------------------------------------------
#region Generated Form Code

#
# Object form1 (System.Windows.Forms.Form)
#
$ComponentSize.Height = 361;
$ComponentSize.Width = 631;
$form1.ClientSize = $ComponentSize;
$form1.DataBindings.DefaultDataSourceUpdateMode = 0;
$form1.Name = "form1";
$form1.StartPosition = 1;
$form1.Text = "RMAN logfiles";


#
# Object viewfile (System.Windows.Forms.Button)
#
$viewfile.DataBindings.DefaultDataSourceUpdateMode = 0;
$viewfile.Font = $myFont;
$ComponentLocation.X = 421;
$ComponentLocation.Y = 288;
$viewfile.Location = $ComponentLocation;
$viewfile.Name = "viewfile";
$viewfile.Size = $ButtonSize;
$viewfile.TabIndex = 1;
$viewfile.TabStop = $true;
$viewfile.Text = "View file";
$viewfile.UseVisualStyleBackColor = $True;
$viewfile.add_Click($viewfile_OnClick);
$viewfile.Enabled = $false;

$tooltipmsg = 'View logfile selected in notepad';
$tooltip.SetToolTip($viewfile, $tooltipmsg);

$form1.Controls.Add($viewfile);


#
# Object quitapp (System.Windows.Forms.Button)
#
$quitapp.DataBindings.DefaultDataSourceUpdateMode = 0;
$quitapp.Font = $myFont;
$ComponentLocation.X = 531;
$ComponentLocation.Y = 288;
$quitapp.Location = $ComponentLocation;
$quitapp.Name = "quitapp";
$quitapp.Size = $ButtonSize;
$quitapp.TabIndex = 2;
$quitapp.TabStop = $true;
$quitapp.Text = "Quit app";
$quitapp.UseVisualStyleBackColor = $True;
$quitapp.add_Click($quitapp_OnClick);

$tooltipmsg = 'Quit the application';
$tooltip.SetToolTip($quitapp, $tooltipmsg);

$form1.Controls.Add($quitapp);


#
# Object rootnode (System.Windows.Forms.TreeNode)
#
$treeView1.DataBindings.DefaultDataSourceUpdateMode = 0;
$ComponentLocation.X = 12;
$ComponentLocation.Y = 60;
$treeView1.Location = $ComponentLocation;
$treeView1.Name = "treeView1";
$rootnode = New-Object -TypeName 'System.Windows.Forms.TreeNode';
$rootnode.Name = "rootNode";
$rootnode.Text = "Root node";
$rootnode.Tag = "rootNode";
$rootnode.ToolTipText = 'Serves no other purpose than to act as the root node for the application';
Add-Member -NotePropertyName 'Logfile' -NotePropertyValue $false -InputObject $rootnode;

# Add the root node to the TreeView object
$treeView1.Nodes.Add($rootnode) | Out-Null;


#
# Object treeView1 (System.Windows.Forms.TreeView)
#
$ComponentSize.Height = 205;
$ComponentSize.Width = 594;
$treeView1.Size = $ComponentSize;
$treeView1.TabIndex = 2
$treeView1.add_AfterSelect($handler_treeView1_AfterSelect);
$treeView1.Font = $myFont;
$treeView1.ShowNodeToolTips = $true;
$treeView1.HideSelection = $false;
$treeView1.ShowLines = $true;
$treeView1.ShowPlusMinus = $true;
$treeView1.ShowRootLines = $true;

# Add the TreeView object to the form
$form1.Controls.Add($treeView1);


#
# Object getdir (System.Windows.Forms.Button)
#
$getdir.DataBindings.DefaultDataSourceUpdateMode = 0;
$getdir.Font = $myFont;
$ComponentLocation.X = 531;
$ComponentLocation.Y = 20;
$getdir.Location = $ComponentLocation;
$getdir.Name = "getdir";
$getdir.Size = $ButtonSize;
$getdir.TabIndex = 0;
$getdir.TabStop = $true;
$getdir.Text = "Get dir"
$getdir.UseVisualStyleBackColor = $True;
$getdir.add_Click($getdir_OnClick);

$tooltipmsg = 'Get base directory and populate the tree structure';
$tooltip.SetToolTip($getdir, $tooltipmsg);

$form1.Controls.Add($getdir);


#
# Object label1 (System.Windows.Forms.Label)
#
$label1.DataBindings.DefaultDataSourceUpdateMode = 0;
$label1.Font = $myFont;
$ComponentLocation.X = 12;
$ComponentLocation.Y = 22;
$label1.Location = $ComponentLocation;
$label1.Name = "label1";
$ComponentSize.Height = 23;
#$ComponentSize.Width = 169;
$ComponentSize.Width = 250;
$label1.Size = $ComponentSize;
$label1.TabStop = $false;
$label1.Text = "Select your base directory";
$label1.Enabled = $false;

$form1.Controls.Add($label1);

#endregion Generated Form Code

#Save the initial state of the form
$InitialFormWindowState = $form1.WindowState;
#Init the OnLoad event to correct the initial state of the form
$form1.add_Load($OnLoadForm_StateCorrection);
#Show the Form
$form1.StartPosition = "CenterScreen";
$form1.ShowDialog() | Out-Null;

} #End Function
#endregion ***** end of function GenerateForm *****

##=============================================
## SCRIPT BODY
## Main routine starts here
##=============================================
Set-StrictMode -Version Latest;
$ErrorActionPreference = "Stop";

#Check first we have some RMAN log files to view.
$response = Ask-Continue;
$yes = [System.Windows.Forms.DialogResult]::Yes;
if ($response -eq $yes) {
  #Start the application
  GenerateForm;
} else {
  Write-Warning -Message 'Copy RMAN log files to local computer and try again';
}

$VerbosePreference = "SilentlyContinue";

##=============================================
## END OF SCRIPT: Browse-Logfiles.ps1
##=============================================
