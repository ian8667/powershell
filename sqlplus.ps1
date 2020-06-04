<#

.NOTES

Preferred font to use?
$myFont = New-Object System.Drawing.Font("Times New Roman",12,0,3,0)

File Name    : sqlplus.ps1
Author       : Ian Molloy
Last updated : 2020-06-04T22:01:53

.LINK

GroupBox Class
https://msdn.microsoft.com/en-us/library/system.windows.forms.groupbox(v=vs.110).aspx

System.Windows.Forms Namespace
https://msdn.microsoft.com/en-us/library/system.windows.forms(v=vs.110).aspx

Panel Class
https://msdn.microsoft.com/en-us/library/system.windows.forms.panel(v=vs.110).aspx


#>
[CmdletBinding()]
Param () #end param

#region Cleanup-Exitform
function Cleanup-Exitform {
[CmdletBinding()]
[OutputType([System.Void])]
Param (
        [parameter(Mandatory=$true,
                   Position=0)]
        [ValidateNotNullOrEmpty()]
        [System.Windows.Forms.Form]
        $sform
      ) #end param

#
#Cleanup and exit the form.
#

Begin {
  Write-Verbose -Message "Cleaning up and closing form $($sform.Name)";
}

Process {
  $sform.Close();
  $sform.Dispose();

}

End {
  return;
}

} #end of Cleanup-Exitform
#endregion function Cleanup-Exitform

#region Get-Data
function Get-Data {
[CmdletBinding()]
[OutputType([System.Collections.Hashtable])]
Param () #end param

#
#Gets the list of databases and associated comments.
#

Begin {
  # text file containing the list of databases and comments.
  $datafile = 'C:\Family\powershell\sqlplus.dat';
  $lines=Get-Content $datafile | Where-Object {$_ -notmatch '^#'}
  Write-Verbose -Message "Lines read from file: $lines";
  $data = @{} #hashtable
  $fred = @() #array
}

Process {
  foreach ($line in $lines) {
    $fred = $line.Split('/');
    Write-Verbose -Message "Data read in: $fred";
    $data.Add($fred[0], $fred[1]);

    $fred.Clear();
  }
}

End {
  return $data;
}

} #end of Get-Data
#endregion function Get-Data

#Generated Form Function
function GenerateForm {
########################################################################
# Code Generated By: SAPIEN Technologies PrimalForms (Community Edition) v1.0.10.0
# Generated On: 12/11/2017 23:03
# Generated By: w7
########################################################################

#region Import the Assemblies
[reflection.assembly]::loadwithpartialname("System.Drawing") | Out-Null;
[reflection.assembly]::loadwithpartialname("System.Windows.Forms") | Out-Null;
#endregion

#region Generated Form Objects
#----------------------------------------------
#Generate (create) objects used by the form
#----------------------------------------------
$sqlplusform = New-Object System.Windows.Forms.Form # parent form
$exit = New-Object System.Windows.Forms.Button
$login = New-Object System.Windows.Forms.Button
$comments = New-Object System.Windows.Forms.TextBox # multi comments on form
$comboBox1 = New-Object System.Windows.Forms.ComboBox; # contains list of databases
$label3 = New-Object System.Windows.Forms.Label
$textBox1 = New-Object System.Windows.Forms.TextBox # database username
$label2 = New-Object System.Windows.Forms.Label
$label1 = New-Object System.Windows.Forms.Label
$InitialFormWindowState = New-Object System.Windows.Forms.FormWindowState

# Create a font to use with the form objects
$myFont = New-Object -TypeName System.Drawing.Font -ArgumentList "Times New Roman", 12;

# Default database username to display in form
New-Variable -Name defaultUser -Value "dba53495" -Description "Default username" -Option ReadOnly;

# Define Oracle SQL*Plus executable
New-Variable -Name sqlplusexe -Value "C:\Family\Oracle\bin\sqlplus.exe" -Option ReadOnly;
#endregion Generated Form Objects

#----------------------------------------------
#Generated Event Script Blocks (event handlers)
#----------------------------------------------
#Provide Custom Code for events specified in PrimalForms.
$login_OnClick=
{
#TODO: Place custom script here
  $thisdbuser = $textBox1.Text;
  $thisdatabase = $comboBox1.SelectedItem.ToString();
  $connString = "$thisdbuser@$thisdatabase";
  #& $sqlplusexe $connString;

  Cleanup-Exitform $sqlplusform;
  return;
  Write-Host 'Dont see';
}

$exit_OnClick=
{
#TODO: Place custom script here
  # $sqlplusform.Close();
  #$sqlplusform.Dispose();
  #return;
  Cleanup-Exitform $sqlplusform;
  return;
  Write-Host 'Dont see';
}

$comboBox1_SelectedIndexChanged =
{
#TODO: Place custom script here
  $thisdatabase = $comboBox1.SelectedItem.ToString();
  $v = $items[$thisdatabase] #get the 'value' from the hashtable
  $comments.Text = $v;
}


$OnLoadForm_StateCorrection=
{#Correct the initial state of the form to prevent the .Net maximized form issue
  $sqlplusform.WindowState = $InitialFormWindowState
}

#----------------------------------------------
#Parent form
#----------------------------------------------
#region Generated Form Code
$System_Drawing_Size = New-Object System.Drawing.Size
$System_Drawing_Size.Height = 335
$System_Drawing_Size.Width = 474
$sqlplusform.ClientSize = $System_Drawing_Size
$sqlplusform.DataBindings.DefaultDataSourceUpdateMode = 0
$sqlplusform.Name = "sqlplusform"
$sqlplusform.Text = "PowerShell SQL*Plus"

#Add-Member -InputObject $sqlplusform -NotePropertyName Myname -NotePropertyValue 'sqlplus';

$exit.DataBindings.DefaultDataSourceUpdateMode = 0

#----------------------------------------------
#Button 'exit'
#----------------------------------------------
$System_Drawing_Point = New-Object System.Drawing.Point
$System_Drawing_Point.X = 137
$System_Drawing_Point.Y = 257
$exit.Location = $System_Drawing_Point
$exit.Name = "exit"
$System_Drawing_Size = New-Object System.Drawing.Size
$System_Drawing_Size.Height = 23
$System_Drawing_Size.Width = 75
$exit.Size = $System_Drawing_Size
$exit.Text = "Exit"
$exit.UseVisualStyleBackColor = $True
$exit.add_Click($exit_OnClick)
$exit.Font = $myFont;
$exit.TabIndex = 3
$exit.TabStop = $True

$sqlplusform.Controls.Add($exit)


$login.DataBindings.DefaultDataSourceUpdateMode = 0
#----------------------------------------------
#Button 'login'
#----------------------------------------------
$System_Drawing_Point = New-Object System.Drawing.Point
$System_Drawing_Point.X = 241
$System_Drawing_Point.Y = 257
$login.Location = $System_Drawing_Point
$login.Name = "login"
$System_Drawing_Size = New-Object System.Drawing.Size
$System_Drawing_Size.Height = 23
$System_Drawing_Size.Width = 75
$login.Size = $System_Drawing_Size
$login.Text = "Log In"
$login.UseVisualStyleBackColor = $True
$login.add_Click($login_OnClick); #event handler
$login.Font = $myFont;
$login.TabIndex = 4
$login.TabStop = $True

$sqlplusform.Controls.Add($login)

#----------------------------------------------
#Multiline text box used to display comments about
#the database selected
#----------------------------------------------
$comments.DataBindings.DefaultDataSourceUpdateMode = 0
$System_Drawing_Point = New-Object System.Drawing.Point
$System_Drawing_Point.X = 48
$System_Drawing_Point.Y = 165
$comments.Location = $System_Drawing_Point
$comments.Multiline = $True
$comments.Name = "textBox2"
$System_Drawing_Size = New-Object System.Drawing.Size
$System_Drawing_Size.Height = 52
$System_Drawing_Size.Width = 287
$comments.Size = $System_Drawing_Size
$comments.Text = "Please select a database"
$comments.Font = $myFont;
$comments.ReadOnly = $True;
$comments.TabStop = $False

$sqlplusform.Controls.Add($comments)

#----------------------------------------------
#Combobox control
#----------------------------------------------
$comboBox1.DataBindings.DefaultDataSourceUpdateMode = 0
$comboBox1.FormattingEnabled = $True
$System_Drawing_Point = New-Object System.Drawing.Point
$System_Drawing_Point.X = 196
$System_Drawing_Point.Y = 115
$comboBox1.Location = $System_Drawing_Point
$comboBox1.Name = "comboBox1"
$System_Drawing_Size = New-Object System.Drawing.Size
$System_Drawing_Size.Height = 20
$System_Drawing_Size.Width = 139
$comboBox1.Size = $System_Drawing_Size
$comboBox1.Sorted = $False
$comboBox1.DropDownStyle = [System.Windows.Forms.ComboBoxStyle]::DropDownList;
$comboBox1.Font = $myFont;
$comboBox1.MaxDropDownItems = 5;
$comboBox1.add_SelectedIndexChanged($comboBox1_SelectedIndexChanged);
$comboBox1.TabIndex = 2
$comboBox1.TabStop = $True


# Put some stuff in the combo box
# This method adds an item to the combo box. If the Sorted property
# of the ComboBox is set to true, the item is inserted into the list
# alphabetically. Otherwise, the item is inserted at the end of the
# list.
#
# Use the SelectedItem property when you want to retrieve the value
# selected by the user
$items = Get-Data;
$items.Keys | ForEach-Object {
  $returns = $comboBox1.Items.Add($_);
}
#Set-Variable -Name $items -Option ReadOnly;

$sqlplusform.Controls.Add($comboBox1)

#----------------------------------------------
#Label containing the word 'Database:'
#----------------------------------------------
$label3.BorderStyle = 1
$label3.DataBindings.DefaultDataSourceUpdateMode = 0

$System_Drawing_Point = New-Object System.Drawing.Point
$System_Drawing_Point.X = 49
$System_Drawing_Point.Y = 115
$label3.Location = $System_Drawing_Point
$label3.Name = "label3"
$System_Drawing_Size = New-Object System.Drawing.Size
$System_Drawing_Size.Height = 23
$System_Drawing_Size.Width = 100
$label3.Size = $System_Drawing_Size
$label3.Text = "Database:"
$label3.TextAlign = 16
$label3.Font = $myFont;
$label3.TabStop = $False

$sqlplusform.Controls.Add($label3)

#----------------------------------------------
#Textbox used to enter the database username
#----------------------------------------------
$textBox1.BorderStyle = 1
$textBox1.DataBindings.DefaultDataSourceUpdateMode = 0
$System_Drawing_Point = New-Object System.Drawing.Point
$System_Drawing_Point.X = 196
$System_Drawing_Point.Y = 76
$textBox1.Location = $System_Drawing_Point
$textBox1.Name = "textBox1"
$System_Drawing_Size = New-Object System.Drawing.Size
$System_Drawing_Size.Height = 20
$System_Drawing_Size.Width = 139
$textBox1.Size = $System_Drawing_Size
$textBox1.Text = $defaultUser
$textBox1.Font = $myFont;
$textBox1.TabIndex = 1
$textBox1.TabStop = $True

#Make this control the primary focus on going into the form
if($textBox1.CanFocus) {
    $textBox1.Focus();
}

$sqlplusform.Controls.Add($textBox1)

#----------------------------------------------
#Textbox containing the word 'User:'
#----------------------------------------------
$label2.BorderStyle = 1
$label2.DataBindings.DefaultDataSourceUpdateMode = 0

$System_Drawing_Point = New-Object System.Drawing.Point
$System_Drawing_Point.X = 49
$System_Drawing_Point.Y = 74
$label2.Location = $System_Drawing_Point
$label2.Name = "label2"
$System_Drawing_Size = New-Object System.Drawing.Size
$System_Drawing_Size.Height = 23
$System_Drawing_Size.Width = 100
$label2.Size = $System_Drawing_Size
$label2.Text = "User:"
$label2.TextAlign = 16
$label2.Font = $myFont;
$label2.TabStop = $False

$sqlplusform.Controls.Add($label2)

#----------------------------------------------
#Main form label containing the words 'PowerShell SQL*Plus'
#----------------------------------------------
$label1.BackColor = [System.Drawing.Color]::FromArgb(255,51,153,255)
$label1.BorderStyle = 1
$label1.DataBindings.DefaultDataSourceUpdateMode = 0

$System_Drawing_Point = New-Object System.Drawing.Point
$System_Drawing_Point.X = 100
$System_Drawing_Point.Y = 20
$label1.Location = $System_Drawing_Point
$label1.Name = "label1"
$System_Drawing_Size = New-Object System.Drawing.Size
$System_Drawing_Size.Height = 23
$System_Drawing_Size.Width = 170
$label1.Size = $System_Drawing_Size
$label1.Text = "PowerShell SQL*Plus"
$label1.TextAlign = 32
$label1.Font = $myFont;
$label1.TabStop = $False

$sqlplusform.Controls.Add($label1)

#endregion Generated Form Code

#Save the initial state of the form
$InitialFormWindowState = $sqlplusform.WindowState
#Init the OnLoad event to correct the initial state of the form
$sqlplusform.add_Load($OnLoadForm_StateCorrection)

#Set the starting position of the form at run time.
$CenterScreen = [System.Windows.Forms.FormStartPosition]::CenterScreen;
$sqlplusform.StartPosition = $CenterScreen;

#Show the Form
$sqlplusform.ShowDialog() | Out-Null

} #End Function

#Call the Function to build and display form
GenerateForm;

##=============================================
## SCRIPT BODY
## Main routine starts here
##=============================================

Set-StrictMode -Version Latest;
$ErrorActionPreference = "Stop";

##=============================================
## END OF SCRIPT: sqlplus.ps1
##=============================================
