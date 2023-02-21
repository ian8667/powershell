<#

.SYNOPSIS

Demonstration program of a TreeView and TreeNode

.DESCRIPTION

Demonstration program showing the use of a TreeView and TreeNode.
The program also uses a FlowLayoutPanel panel to hold some buttons
which react to the 'FlowLayoutPanel' event by the use of a script
block

This program is the PowerShell version of SimpleTree.java which
uses javax.swing.JTree

.EXAMPLE

./SimpleTree.ps1

No parameters are required. Data used by the program is created
as required

.INPUTS

None, no .NET Framework types of objects are used as input.

.OUTPUTS

No .NET Framework types of objects are output from this script.

.NOTES

File Name    : SimpleTree.ps1
Author       : Ian Molloy
Last updated : 2023-02-21T17:27:25
Keywords     : java jtree treeview nodes tree event demo

.LINK

System.Windows.Forms Namespace
https://learn.microsoft.com/en-us/dotnet/api/system.windows.forms?view=windowsdesktop-7.0

TreeView Class
https://learn.microsoft.com/en-us/dotnet/api/system.windows.forms.treeview?view=windowsdesktop-7.0

TreeNode Class
https://learn.microsoft.com/en-us/dotnet/api/system.windows.forms.treenode?view=windowsdesktop-7.0

javax.swing.JTree
https://docs.oracle.com/en/java/javase/19/docs/api/java.desktop/javax/swing/JTree.html

Walkthrough: Lay out controls (PowerShell) with padding, margins,
and the AutoSize property.
Precise placement of controls on your form is a high priority
for many applications. Three of the most important are the
Margin, Padding, and AutoSize properties, which are present
on all Windows Forms controls.
https://learn.microsoft.com/en-us/dotnet/desktop/winforms/controls/windows-forms-controls-padding-autosize?view=netframeworkdesktop-4.8

#>

[CmdletBinding()]
Param() #end param

#-------------------------------------------------
# Start of functions
#-------------------------------------------------

#region ***** Function Get-NewNode *****
function Get-NewNode {
  <#
  .SYNOPSIS

  Creates a new node

  .DESCRIPTION

  Creates a new node from the class 'System.Windows.Forms.TreeNode'

  .PARAMETER NodeName

  A String that represents the name of the tree node.

  .PARAMETER NodeText

  The text displayed in the label of the tree node.

  .PARAMETER NodeTag

  Sets the object that contains a tag for the tree node.

  .PARAMETER NodeToolTip

  Sets the text that appears when the mouse pointer hovers over a TreeNode.

  .LINK

  TreeView Class
  Displays a hierarchical collection of labeled items, each represented by a TreeNode.
  https://learn.microsoft.com/en-us/dotnet/api/system.windows.forms.treeview?view=windowsdesktop-7.0

  TreeNode Class
  Represents a node of a TreeView.
  https://learn.microsoft.com/en-us/dotnet/api/system.windows.forms.treenode?view=windowsdesktop-7.0

  #>

[CmdletBinding()]
[OutputType([System.Windows.Forms.TreeNode])]
Param(
   [parameter(Position=0,
              Mandatory=$true,
              HelpMessage="Node name")]
   [ValidateNotNullOrEmpty()]
   [String]
   $NodeName,
   [parameter(Position=1,
              Mandatory=$true,
              HelpMessage="Node text")]
   [ValidateNotNullOrEmpty()]
   [String]
   $NodeText,
   [parameter(Position=2,
              Mandatory=$true,
              HelpMessage="Node tag")]
   [ValidateNotNullOrEmpty()]
   [String]
   $NodeTag,
   [parameter(Position=3,
              Mandatory=$true,
              HelpMessage="Node tool tip text")]
   [ValidateNotNullOrEmpty()]
   [String]
   $NodeToolTip
) #end param

  Begin {

    Add-Type -AssemblyName "System.Windows.Forms";
    $newNode = [System.Windows.Forms.TreeNode]::new();
  }

  Process {

    $newNode.Name = $NodeName;
    $newNode.Text = $NodeText;
    $newNode.Tag = $NodeTag;
    $newNode.ToolTipText = $NodeToolTip;

  }

  End {
    return $newNode;
  }
  }
  #endregion ***** End of function Get-NewNode *****

#----------------------------------------------------------

#region ***** Function Add-DatabaseNodes *****
function Add-DatabaseNodes {
  <#
  .SYNOPSIS

  Add database node to a server node

  .DESCRIPTION

  Add database nodes to server nodes as determined by the parameters
  supplied

  .PARAMETER DatabaseList

  A list of database names to add to a server node

  .PARAMETER ServerNode

  The server node to which the databases will be added

  .LINK

  TreeView Class
  Displays a hierarchical collection of labeled items, each represented by a TreeNode.
  https://learn.microsoft.com/en-us/dotnet/api/system.windows.forms.treeview?view=windowsdesktop-7.0

  TreeNode Class
  Represents a node of a TreeView.
  https://learn.microsoft.com/en-us/dotnet/api/system.windows.forms.treenode?view=windowsdesktop-7.0

  #>

[CmdletBinding()]
[OutputType([System.Windows.Forms.TreeNode])]
Param(
   [parameter(Position=0,
              Mandatory=$true,
              HelpMessage="List of databases to add to a server node")]
   [ValidateNotNullOrEmpty()]
   [String[]]
   $DatabaseList,
   [parameter(Position=1,
              Mandatory=$true,
              HelpMessage="Server node where the databases will be added")]
   [ValidateNotNullOrEmpty()]
   [System.Windows.Forms.TreeNode]
   $ServerNode
) #end param

  Begin {}

  Process {

    foreach ($dbName in $DatabaseList) {

      $splat = @{NodeName = $dbName
                 NodeText = $dbName
                 NodeTag = $dbName
                 NodeToolTip = "Database $dbName"};
      $tempDbNode = Get-NewNode @splat;
      $ServerNode.Nodes.Add($tempDbNode) | Out-Null;

    } #end foreach loop

  }

  End {
    return $ServerNode;
  }
  }
  #endregion ***** End of function Add-DatabaseNodes *****

#----------------------------------------------------------

#region ***** Function GenerateForm *****
Function GenerateForm {

    Add-Type -AssemblyName "System.Windows.Forms";
    Add-Type -AssemblyName "System.Drawing";

    $form1 = [System.Windows.Forms.Form]::new();
    $txtPan1 = [System.Windows.Forms.Panel]::new();
    $btnPan1 = [System.Windows.Forms.FlowLayoutPanel]::new();

    $treeView1 = [System.Windows.Forms.TreeView]::new();
    $treeRoot = [System.Windows.Forms.TreeNode]::new('World');
    $Padding = [System.Windows.Forms.Padding]::new(10,10,10,10);
    $btnB1 = [System.Windows.Forms.Button]::new();
    $btnTest = [System.Windows.Forms.Button]::new();
    $btnExit = [System.Windows.Forms.Button]::new();


    #Set-Variable -Name 'treeView1' -Option ReadOnly;

<#
Stores an ordered pair of integers, which specify a Height
and Width. This structure is typically used to set the size
of form components.
  Height - sets the vertical component of this Size structure.
  Width - sets the horizontal component of this Size structure.
#>
$DrawSize = [System.Drawing.Size]::new(0,0); #width, height

<#
Represents an ordered pair of integer X- and Y-coordinates
that defines a point in a two-dimensional plane. This
structure is typically used to set the location of form
components.
  X - the horizontal position of the point.
  Y - the vertical position of the point.
#>
$DrawPoint = [System.Drawing.Point]::new(0,0); #X, Y

#----------------------------------------------
#Generated Event Script Blocks
#----------------------------------------------
#Script block event handlers for the button Click event
#Use the following code to register an event:
#<object name>.add_<event name of interest>(script block to handle the event);
#ie
#$btnExit.add_Click($btnExit_OnClick);
#
$btnExit_OnClick =
{
#TODO: Place custom script here
    $treeView1.Dispose();
    $btnPan1.Dispose();
    $form1.Close();
    $form1.Dispose();

    return;
}

$btnTest_OnClick =
{
#TODO: Place custom script here
    Write-Host 'this is from button test';
    #return;
}

$btnB1_OnClick =
{
#TODO: Place custom script here
    Write-Host 'this doesn''t do a lot';

    #return;
}

#----------------------------------------------
#End Generated Event Script Blocks
#----------------------------------------------

#----------------------------------------------------------

$OnLoadForm_StateCorrection=
{#Correct the initial state of the form to prevent the .Net maximized form issue
  $form1.WindowState = $InitialFormWindowState
}

$treeRoot.Name = 'treeRoot';
$treeRoot.Expand();

# ----------

# form1 (main form)
$DrawSize.Width = 300;
$DrawSize.Height = 250;
$form1.ClientSize = $DrawSize;
$form1.DataBindings.DefaultDataSourceUpdateMode = 0;
$form1.Name = "form1";
$form1.Text = "My Tree";
$form1.Margin = $Padding;
$form1.Padding = $Padding;
$form1.FormBorderStyle = [System.Windows.Forms.FormBorderStyle]::FixedDialog;
$form1.AutoSize = $true;

# ----------

# btnPan1 (button panel)
$btnPan1.DataBindings.DefaultDataSourceUpdateMode = 0
$DrawPoint.X = 5;
$DrawPoint.Y = 185;
$btnPan1.Location = $DrawPoint
$btnPan1.Name = "btnPan1"
$DrawSize.Width = 285;
$DrawSize.Height = 50;
$btnPan1.Size = $DrawSize;
$btnPan1.BorderStyle = [System.Windows.Forms.BorderStyle]::Fixed3D;
$btnPan1.Margin = $Padding;
$btnPan1.Padding = $Padding;
$btnPan1.FlowDirection = [System.Windows.Forms.FlowDirection]::RightToLeft;
$btnPan1.AutoSize = $true;

$form1.Controls.Add($btnPan1);

# ----------

# btnExit (the exit button)
$btnExit.Name = "btnExit";
$DrawSize.Height = 25;
$DrawSize.Width = 75;
$btnExit.Size = $DrawSize;
$btnExit.TabIndex = 0;
$btnExit.TabStop = $True;
$btnExit.Text = "Exit";
$btnExit.BackColor = [System.Drawing.Color]::Red;
$btnExit.UseVisualStyleBackColor = $True;
$btnExit.add_Click($btnExit_OnClick);

$btnPan1.Controls.Add($btnExit);

# ----------

# btnTest (the test button)
$btnTest.Name = "btnTest";
$DrawSize.Height = 25;
$DrawSize.Width = 75;
$btnTest.Size = $DrawSize;
$btnTest.TabIndex = 0;
$btnTest.TabStop = $True;
$btnTest.Text = "Test";
$btnTest.BackColor = [System.Drawing.Color]::Yellow;
$btnTest.UseVisualStyleBackColor = $True;
$btnTest.add_Click($btnTest_OnClick);

$btnPan1.Controls.Add($btnTest);

# ----------

# btnB1 (the b1 test button)
$btnB1.Name = "btnB1";
$DrawSize.Height = 25;
$DrawSize.Width = 75;
$btnB1.Size = $DrawSize;
$btnB1.TabIndex = 0;
$btnB1.TabStop = $True;
$btnB1.Text = "b1";
$btnB1.BackColor = [System.Drawing.Color]::LightSeaGreen;
$btnB1.UseVisualStyleBackColor = $True;
$btnB1.add_Click($btnB1_OnClick);

$btnPan1.Controls.Add($btnB1);

# ----------

$treeView1.BeginUpdate();

# treeView1 (the tree to which all nodes will be attached)
$treeView1.ShowNodeToolTips = $true;
$treeView1.TopNode = $treeRoot;
$treeView1.Margin = $Padding;
$treeView1.Padding = $Padding;
$DrawSize.Width = 285;
$DrawSize.Height = 180
$treeView1.Size = $DrawSize;
$treeView1.Scrollable = $true;
$treeView1.AutoSize = $true;

$treeView1.Nodes.Add($treeRoot) | Out-Null;

#------------------------------------------------

#Create operating system type nodes. For the purpose
#of this program, the only two operating systems used
#are Unix and MS Windows
#Unix O/S node
$splat = @{NodeName = 'Unix'
           NodeText = 'Unix'
           NodeTag = 'Unix'
           NodeToolTip = 'Unix operating system servers'};
$osNodeUnix = Get-NewNode @splat;
$treeRoot.Nodes.Add($osNodeUnix) | Out-Null;

#MS Windows O/S node
$splat = @{NodeName = 'MS-Windows'
           NodeText = 'MS-Windows'
           NodeTag = 'MS-Windows'
           NodeToolTip = 'MS-Windows operating system servers'};
$osNodeMsWindows = Get-NewNode @splat;
$treeRoot.Nodes.Add($osNodeMsWindows) | Out-Null;

# ----------

#Create server nodes. 
#Unix server node UK-SOL-007-F02
$splat = @{NodeName = 'uk-sol-007-f02'
           NodeText = 'uk-sol-007-f02'
           NodeTag = 'uk-sol-007-f02'
           NodeToolTip = 'Server uk-sol-007-f02'};
$unixSrvUksolf02 = Get-NewNode @splat;
$osNodeUnix.Nodes.Add($unixSrvUksolf02) | Out-Null;

#Unix server node UK-SOL-007-F03
$splat = @{NodeName = 'uk-sol-007-f03'
           NodeText = 'uk-sol-007-f03'
           NodeTag = 'uk-sol-007-f03'
           NodeToolTip = 'Server uk-sol-007-f03'};
$unixSrvUksolf03 = Get-NewNode @splat;
$osNodeUnix.Nodes.Add($unixSrvUksolf03) | Out-Null;

#MS Windows server node SERVER01
$splat = @{NodeName = 'server01'
           NodeText = 'server01'
           NodeTag = 'server01'
           NodeToolTip = 'Server server01'};
$winSrvServer01 = Get-NewNode @splat;
$osNodeMsWindows.Nodes.Add($winSrvServer01) | Out-Null;

# ----------

#Add databases to each of the server nodes
#Server UK-SOL-007-F02
[String[]]$dbList = @('iasdb');
$unixSrvUksolf02 = Add-DatabaseNodes -DatabaseList $dbList -ServerNode $unixSrvUksolf02;

#Server UK-SOL-007-F02
$dblist.Clear();
$dbList = @('csd','eve','hlp','deve','ssdb','tsrs');
$unixSrvUksolf03 = Add-DatabaseNodes -DatabaseList $dbList -ServerNode $unixSrvUksolf03;

#Server SERVER01
$dblist.Clear();
$dbList = @('dummy01','dummy02');
$winSrvServer01 = Add-DatabaseNodes -DatabaseList $dbList -ServerNode $winSrvServer01;

#------------------------------------------------

$treeView1.EndUpdate();

#$treeRoot.Select();
$form1.Controls.Add($treeView1);
#$treeView1.SelectedNode = $treeRoot;


# The form is centered on the current display, and has the
# dimensions specified in the form's size.
$form1.StartPosition = [System.Windows.Forms.FormStartPosition]::CenterScreen;

#Save the initial state of the form
$InitialFormWindowState = $form1.WindowState;
#Init the OnLoad event to correct the initial state of the form
$form1.add_Load($OnLoadForm_StateCorrection);
#Show the Form
$form1.ShowDialog() | Out-Null;

} #End Function GenerateForm
#endregion ***** End of function GenerateForm *****

#-------------------------------------------------
# End of functions
#-------------------------------------------------

##=============================================
## SCRIPT BODY
## Main routine starts here
##=============================================
Set-StrictMode -Version Latest;
$ErrorActionPreference = "Stop";

#Call the Function
GenerateForm;

Write-Output 'All done now';

##=============================================
## END OF SCRIPT: SimpleTree.ps1
##=============================================
