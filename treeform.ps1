# ==============================================================================================
#
# Microsoft PowerShell Source File -- Created with SAPIEN Technologies PrimalScript 2009
#
# NAME: TreeForm.ps1
# version 1.1 5/29/2009 Removed TreeNode class declaration in Get-SubFolder function

# AUTHOR: Jeffery Hicks , SAPIEN Technologies
# DATE  : 4/3/2009
#
# COMMENT: Display a graphical directory tree using PowerShell and Windows forms
# Folders with 0 files and 0 subfolders will be displayed in magenta. This does not count
# hidden files or folders.
#
# You can run the script without any parameters. The default directory is %TEMP%.
# Or specify a path:
# PS C:\scripts\> .\treeform.ps1 -path c:\files
#
# Once the form is open you can enter in a new path and click the button to get another
# tree.
#
# The form may temporarily stop responding when analyzing a large directory structure, but
# it should eventually finish and respond again.

# Use the -debug parameter to turn on debug messages so you can see what the script is doing.

# DISCLAIMER AND WARNING:
# 	THIS CODE AND INFORMATION ARE PROVIDED "AS IS" WITHOUT WARRANTY OF ANY
# 	KIND, EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE
# 	IMPLIED WARRANTIES OF MERCHANTABILITY AND/OR FITNESS FOR A PARTICULAR PURPOSE.
#   TEST THOROUGHLY IN A NON-PRODUCTION ENVIRONMENT. IF YOU DON'T KNOW WHAT THIS
#   SCRIPT WILL DO...DO NOT RUN IT!
# ==============================================================================================
<#
The TreeView Control
SAPIEN Information Center
https://info.sapien.com/index.php/guis/gui-controls/spotlight-on-controls-the-treeview-control


#>

Param ([string]$Path='C:\Family\powershell',
       [switch]$debug)

if ($debug) {
  $debugPreference="Continue"
}

Write-Debug "Starting script in debug mode for $($path)"

#Generated Form Function
Function GenerateForm {
    ########################################################################
    # Code Generated By: SAPIEN Technologies PrimalForms (Community Edition) v1.0.3.0
    # Generated On: 4/3/2009 2:09 PM
    # Generated By: Jeffery Hicks
    ########################################################################

    #region Import the Assemblies
    Write-Debug "Loading Assemblies"
    Add-Type -AssemblyName "System.Windows.Forms";
    Add-Type -AssemblyName "System.Drawing";
    #endregion

    #region Generated Form Objects
    Write-Debug "Generating Form Objects"
    $form1 = New-Object System.Windows.Forms.Form
    $statusBar1 = New-Object System.Windows.Forms.StatusBar
    $btnUpdate = New-Object System.Windows.Forms.Button
    $btnControl = New-Object System.Windows.Forms.Button
    $txtPath = New-Object System.Windows.Forms.TextBox
    $treeView1 = New-Object System.Windows.Forms.TreeView
    $InitialFormWindowState = New-Object System.Windows.Forms.FormWindowState
    #endregion Generated Form Objects

    #----------------------------------------------
    #Generated Event Script Blocks
    #----------------------------------------------
    #Provide Custom Code for events specified in PrimalForms.
    $Toggle=
    {
    Write-Debug "Toggle"

        if ($blnExpandAll)
          {
          Write-Debug "Collapsing root"
          $root.Collapse()
          $btnControl.text="Expand All"
          $blnExpandAll=$False
          }
       else
          {
          Write-Debug "Exanding all"
           $root.ExpandAll()
           $btnControl.text="Collapse All"
           $blnExpandAll=$True
          }

        #select the top node
        Write-Debug "Selecting top node"
        $treeview1.TopNode=$root
        $form1.Refresh()
    }


    $BuildTree=
    {
    Write-Debug "BuildTree"
        #clear existing nodes if any
        if ($root)
        {
        Write-Debug "Removing `$root"
            $treeview1.Nodes.remove($root)
            $form1.Refresh()
        }

        $path=$txtPath.Text

        Function Get-SubFolder {
            Param([string]$path,$parent)

            Write-Debug "Get-SubFolder function for $($path)"
            $statusbar1.Text="Analyzing $path"

            $subdirs = dir $path | where {$_.GetType() -match "directoryInfo"}

            if ($subdirs)
            {
                foreach ($subdir in $subdirs) {
                    $subfiles=dir $subdir.fullname | where {$_.GetType() -match "FileInfo"}
                    Write-Debug "Measuring folder $($subdir.fullname)"
                    $stats=$subfiles | Measure-Object -sum length
                    [int64]$subcount=$stats.count
                    [int64]$subsize=$stats.sum

                    $leaf=("{0} ({1} files {2} KB)" -f ($subdir.name,$subcount,("{0:N2}" -f ($subsize/1KB))))

                    Write-Debug "Creating tree node"
                    $node = New-Object System.Windows.Forms.TreeNode
                    $node.Text=$leaf
                    $node.name=$subdir.name
                    Write-Debug "Adding $($node.name) to $($parent.name)"
                    $parent.nodes.add($node) | Out-Null

                    Get-SubFolder  -path $subdir.fullname -parent $node
                } #end foreach
            } #end if

        if ($parent.Nodes.count -eq 0 -and $subsize -eq 0)
         {
             #empty directory so change font color
             Write-Debug "Changing font color for empty directory"
             $parent.ForeColor=[System.Drawing.Color]::FromArgb(255,192,0,192)
         }
     } #end Get-Subfolder function

        #Turn off the error pipeline
        Write-Debug "Turn off error pipeline"
        $ErrorActionPreference="SilentlyContinue"

        if ((Get-Item $path).exists)
        {
            $data=dir $path
            $statusbar1.Text="Analyzing $path"
            $files=$data | where {$_.GetType() -match "FileInfo"}
            Write-Debug "Counting files for $($path)"
            [int64]$count=$files.count
            [int64]$size=($files | Measure-Object -Sum Length).sum

            #write the tree root
            $leaf=("{0} ({1} files {2} KB)" -f $path,$count,("{0:N2}" -f ($size/1KB)))

            Write-Debug "Creating tree node"
            $root = New-Object System.Windows.Forms.TreeNode
            $root.text = $leaf
            $root.Name = $path

            $treeView1.Nodes.Add($root)|Out-Null
            #enumerate child folders
            Write-Debug "Enumerating child folders"
            Get-SubFolder -path $path -parent $root
            $statusbar1.Text="Ready"

        }
        else
        {
            Write-Debug "Failed to find $($path)"
            $statusbar1.text= "Failed to find $path"
        }

        #expand the root node
        Write-Debug "Expanding the root"
        $root.Expand()
        $blnExpandAll=$False
        #select the top node
        Write-Debug "Selecting the top node"
        $treeview1.TopNode=$root
        #set the toggle button
        Write-Debug "Set the toggle button text"
        $btnControl.text="Expand All"
    } #end Build Tree

    $OnLoadForm_StateCorrection=
    {#Correct the initial state of the form to prevent the .Net maximized form issue
    	Write-Debug "Set initialFormWindowState"
    	$form1.WindowState = $InitialFormWindowState
    }

    #----------------------------------------------
    #region Generated Form Code
    Write-Debug "Running form generating code"
    Write-Debug "Creating form"
    $form1.Text = 'Tree'
    $form1.Name = 'form1'
    $form1.DataBindings.DefaultDataSourceUpdateMode = 0
    $System_Drawing_Size = New-Object System.Drawing.Size
    $System_Drawing_Size.Width = 392
    $System_Drawing_Size.Height = 276
    $form1.ClientSize = $System_Drawing_Size
    $form1.add_Shown($BuildTree)

    Write-Debug "Creating btnControl"
    $btnControl.TabIndex = 4
    $btnControl.Name = 'btnControl'
    $System_Drawing_Size = New-Object System.Drawing.Size
    $System_Drawing_Size.Width = 75
    $System_Drawing_Size.Height = 23
    $btnControl.Size = $System_Drawing_Size
    $btnControl.UseVisualStyleBackColor = $True

    $btnControl.Text = 'Expand All'

    $System_Drawing_Point = New-Object System.Drawing.Point
    $System_Drawing_Point.X = 305
    $System_Drawing_Point.Y = 40
    $btnControl.Location = $System_Drawing_Point
    $btnControl.DataBindings.DefaultDataSourceUpdateMode = 0
    $btnControl.add_Click($Toggle)

    $form1.Controls.Add($btnControl)

    Write-Debug "Creating statusBar1"
    $statusBar1.Name = 'statusBar1'
    $statusBar1.Text = 'Ready'
    $System_Drawing_Size = New-Object System.Drawing.Size
    $System_Drawing_Size.Width = 392
    $System_Drawing_Size.Height = 22
    $statusBar1.Size = $System_Drawing_Size
    $System_Drawing_Point = New-Object System.Drawing.Point
    $System_Drawing_Point.X = 0
    $System_Drawing_Point.Y = 254
    $statusBar1.Location = $System_Drawing_Point
    $statusBar1.DataBindings.DefaultDataSourceUpdateMode = 0
    $statusBar1.TabIndex = 3

    $form1.Controls.Add($statusBar1)

    Write-Debug "Creating btnUpdate"
    $btnUpdate.TabIndex = 2
    $btnUpdate.Name = 'btnUpdate'
    $System_Drawing_Size = New-Object System.Drawing.Size
    $System_Drawing_Size.Width = 75
    $System_Drawing_Size.Height = 23
    $btnUpdate.Size = $System_Drawing_Size
    $btnUpdate.UseVisualStyleBackColor = $True

    $btnUpdate.Text = 'Build Tree'

    $System_Drawing_Point = New-Object System.Drawing.Point
    $System_Drawing_Point.X = 305
    $System_Drawing_Point.Y = 10
    $btnUpdate.Location = $System_Drawing_Point
    $btnUpdate.DataBindings.DefaultDataSourceUpdateMode = 0
    $btnUpdate.add_Click($BuildTree)

    $form1.Controls.Add($btnUpdate)

    Write-Debug "Creating txtPath"
    $System_Drawing_Size = New-Object System.Drawing.Size
    $System_Drawing_Size.Width = 273
    $System_Drawing_Size.Height = 20
    $txtPath.Size = $System_Drawing_Size
    $txtPath.DataBindings.DefaultDataSourceUpdateMode = 0
    $txtPath.Text = $path
    $txtPath.Name = 'txtPath'
    $System_Drawing_Point = New-Object System.Drawing.Point
    $System_Drawing_Point.X = 13
    $System_Drawing_Point.Y = 13
    $txtPath.Location = $System_Drawing_Point
    $txtPath.TabIndex = 1

    $form1.Controls.Add($txtPath)

    Write-Debug "Creating treeView1"
    $System_Drawing_Size = New-Object System.Drawing.Size
    $System_Drawing_Size.Width = 367
    $System_Drawing_Size.Height = 180
    $treeView1.Size = $System_Drawing_Size
    $treeView1.Name = 'treeView1'
    $System_Drawing_Point = New-Object System.Drawing.Point
    $System_Drawing_Point.X = 13
    $System_Drawing_Point.Y = 69
    $treeView1.Location = $System_Drawing_Point
    $treeView1.DataBindings.DefaultDataSourceUpdateMode = 0
    $treeView1.TabIndex = 0

    $form1.Controls.Add($treeView1)

    #endregion Generated Form Code

    #Save the initial state of the form
    Write-Debug "Save the initial state"
    $InitialFormWindowState = $form1.WindowState

    #Init the OnLoad event to correct the initial state of the form
    $form1.add_Load($OnLoadForm_StateCorrection)

    #Show the Form
    Write-Debug "Showing the form"
    $form1.StartPosition = "CenterScreen"
    $form1.ShowDialog() | Out-Null

} #End Function

#////////// MAIN SCRIPT //////////
#Call the Function
Write-Debug "Calling GenerateForm"
GenerateForm;

Write-Debug "End Script";
