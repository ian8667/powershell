<#
.SYNOPSIS

Clone an online GitHub repository

.DESCRIPTION

Clones one of my online GitHub repositories to a local Git
repository. When the program is run, the user is able to choose
(select) one of the repositories to clone from the simple list
of repositories as defined in the function 'Get-RepositoryName'.
The repository names are hardcoded in this function, so if there
are changes to the names, the list will have to be manually
edited to reflect these changes.

.EXAMPLE

./Clone-GitRepository.ps1

No parameters are required

.INPUTS

None, no .NET Framework types of objects are used as input.

.OUTPUTS

No .NET Framework types of objects are output from this script.

.NOTES

File Name    : Clone-GitRepository.ps1
Author       : Ian Molloy
Last updated : 2022-11-01T14:41:13
Keywords     : git github clone repository yesno

; ----------
PowerShell: Download script or file from GitHub
An interesting article on downloading a single from from GitHub
https://www.thomasmaurer.ch/2021/07/powershell-download-script-or-file-from-github/
Invoke-WebRequest -Uri https://raw.githubusercontent.com/thomasmaurer/demo-cloudshell/master/helloworld.ps1 -OutFile 'C:\gash\helloworld.ps1';
or
To download a test file from one of my repositories:
$address = 'https://raw.githubusercontent.com/ian8667/powershell/master/gash.abc';
$splat = @{
# Splat data for use with Write-Error cmdlet.
    Uri               = New-Object -TypeName 'System.Uri' -ArgumentList $address;
    OutFile           = 'C:\gash\downloaded_file.ps1'
    TimeoutSec        = 5
    MaximumRetryCount = 5
    RetryIntervalSec  = 3
    ErrorAction       = 'Stop'
}
Invoke-WebRequest  @splat;

.LINK

git documentation
https://git-scm.com/doc

About Object Creation
Explains how to create objects in PowerShell.
https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_object_creation?view=powershell-7
#>

<#
new work:
Possible code to use in order to select the Git repository?


$fred = Invoke-RestMethod -Uri 'https://api.github.com/users/ian8667/repos';

[System.Linq.Enumerable]::Repeat("", 2); #blanklines
Write-Output 'load the hashtable';
$menu = @{}
$counter = 1;
#Populate our menu of choices
foreach ($item in $fred) {

    #Add(Key, Value)
    $menu.Add($counter, $item.name);

    $counter++;
}
$menu.Add($counter, 'Exit');
Set-Variable -Name 'menu' -Option ReadOnly;



[System.Linq.Enumerable]::Repeat("", 2); #blanklines
Write-Output 'Github repositories found';
#Display the contents of our menu
foreach ($item in $menu.GetEnumerator() | Sort-Object Name ) {
    '{0} - {1}' -f $item.Name, $item.Value;
}
[Int32]$ans = 0;
do {
  $ans = Read-Host -Prompt 'Please choooose an item by number';
} until ($ans -in 1..$menu.Count);
$selection = $menu.Item($ans);
Write-Output "Your choice is: $($selection)";

#>

[CmdletBinding()]
Param () #end param

#----------------------------------------------------------
# Start of functions
#----------------------------------------------------------

#region ***** function Get-RepositoryName *****
function Get-RepositoryName {
[CmdletBinding()]
[OutputType([System.String])]
param()

[String]$Repos = '';
[Byte]$Response = 0;
$menu = @"

Please select a GitHub repository to clone

1 powershell
2 javaFX
3 Learn-Java
4 java
5 Exit

"@

do {
  $Response = Read-Host -Prompt $menu;
} until ($Response -in 1..5)

switch($Response) {
   1 {$Repos = 'powershell'; break}
   2 {$Repos = 'javaFX'; break}
   3 {$Repos = 'Learn-Java'; break}
   4 {$Repos = 'java'; break}
   5 {$Repos = 'Exit'; break}
   Default {$Repos = 'Exit'; break}
}

return $Repos;

}
#endregion ***** end of function Get-RepositoryName *****

#----------------------------------------------------------

#region ***** function Confirm-Delete *****
function Confirm-Delete {
   [CmdletBinding()]
   [OutputType([System.Boolean])]
   Param (
       [parameter(Mandatory=$true,
                  HelpMessage="Confirm remove local GIT repository")]
       [ValidateNotNullOrEmpty()]
       [String]$LocalRepo
   ) #end param

         Begin {

           $retval = $false;
           #Variable 'cDescription' is a shortcut to the .NET class
           #'ChoiceDescription'
           $cDescription = 'System.Management.Automation.Host.ChoiceDescription' -as [type];
           $caption = "Remove directory";
           $message = @"
   Confirm
   Are you sure you want to perform this action?
   Performing the operation "Remove Directory" on local Git repository
   "$LocalRepo".
   This action cannot be undone! Please make sure you have copied all
   required files from this directory first, otherwise you will lose them.
"@ #end of 'message' variable
           Set-Variable -Name 'cDescription', 'caption', 'message' -Option ReadOnly;

           # Create a 'Collection' object of type (ChoiceDescription Class)
           # 'System.Management.Automation.Host.ChoiceDescription'
           # based upon the generic type of
           # 'System.Collections.ObjectModel.Collection'.
           #
           # Choice values use a zero-based index.
           $choices = New-Object -TypeName "System.Collections.ObjectModel.Collection[$cDescription]";
           $defaultChoice = 1;

           # Option choice 'yes'
           $yes = $cDescription::new("&Yes"); # Label value
           $yes.HelpMessage = "Remove local Git repository";
           $choices.Add($yes);

           # Option choice 'no'
           $no = $cDescription::new("&No"); # Label value
           $no.HelpMessage = "Do not remove local Git repository";
           $choices.Add($no);

           # Option choice 'exit'
           $exit = $cDescription::new("&Exit"); # Label value
           $exit.HelpMessage = "Exit and do nothing";
           $choices.Add($exit);
         } #end of Begin block

         Process {
           # https://docs.microsoft.com/en-us/dotnet/api/system.management.automation.host.pshostuserinterface.promptforchoice?view=powershellsdk-7.0.0
           # Returns an 'Int32' value which is the index of the choices
           # element that corresponds to the option selected by the
           # user.
           $result = $host.ui.PromptForChoice($caption, $message, $choices, $defaultChoice)

         }

         End {

          switch ($result) {
             0 {$retval = $true; break}  # Response yes
             1 {$retval = $false; break} # Response no
             2 {$retval = $false; break} # Response exit
          }

           return $retval;
         }
   }
   #endregion ***** end of function Confirm-Delete *****

#----------------------------------------------------------

#region ***** function Get-CloneUrl *****
function Get-CloneUrl {
[CmdletBinding()]
[OutputType([System.Uri])]
Param (
    [parameter(Mandatory=$true,
               Position=0,
               HelpMessage="Base URL of online GitHub repository")]
    [ValidateNotNullOrEmpty()]
    [String]$Base
) #end param

#Get the actual repository name to clone
[String]$repos = Get-RepositoryName;

# Now we have the repository name, create the full URI we'll be using
[String]$u = $Base, $repos -join '/';

$CloneUri = [System.Uri]::new($u);

return $CloneUri;
}
#endregion ***** end of function Get-CloneUrl *****

#----------------------------------------------------------

#region ***** function Clone-Repository *****
function Clone-Repository {
[CmdletBinding()]
[OutputType([System.Void])]
Param (
    [parameter(Position=0,
               Mandatory=$true,
               HelpMessage="Online URL of repository to be cloned")]
    [ValidateNotNullOrEmpty()]
    [System.Uri]$CloneUri,

    [parameter(Position=1,
               Mandatory=$true,
               HelpMessage="Base directory of local Git repository")]
    [ValidateNotNullOrEmpty()]
    [String]$Base
) #end param

   #Get the individual repository name which is being cloned. This
   #is the last segment of the URI.
   $ReposName = $CloneUri.Segments[-1];
   Set-Variable -Name 'ReposName' -Option ReadOnly;

   #Get the absolute pathname which will be the path to the local
   #Git repository.
   $LocalRepo = Join-Path -Path $Base -ChildPath $ReposName
   Set-Variable -Name 'LocalRepo' -Option ReadOnly;
   Write-Output ('Local repository pathname is [{0}]' -f $LocalRepo);

   #Syntax used:
   #git clone <options> <repository> <directory>
   #where <repository> = The remote GitHub repository to clone from
   #<directory> = The name of a new local directory to clone into.
   #              Cloning into an existing directory is only allowed
   #              if the directory is empty.
   $gitexe = 'C:\Program Files\Git\bin\git.exe';
   $options = @('clone', '--verbose', '--progress');
   $cmdArgs = @($options, $CloneUri, $LocalRepo);
   Set-Variable -Name 'gitexe', 'options', 'cmdArgs' -Option ReadOnly;

   if (Test-Path -Path $LocalRepo) {
      #As we're going to clone to this directory, remove it
      #if it exists. Cloning into an existing directory is
      #only allowed if the directory is empty.

      #Ensure all required files have been copied from the local
      #Git repository before removing it.
      if (Confirm-Delete -LocalRepo $LocalRepo) {

         Write-Output ('Trying to remove unwanted directory {0}' -f $LocalRepo);
         Remove-Item -Path $LocalRepo -Force -Recurse -ErrorAction Stop;
         Write-Output ('Unwanted directory removed');

      } else {
         Write-Error -Message "Local Git repository $LocalRepo not removed at user request";
      }

   }

   & $gitexe @cmdArgs;
   $rc = $LastExitCode;
   Write-Output "Clone of repository exit code = $rc";
#shall I use this?
#Exit setup process (Return code: 0)
}
#endregion ***** end of function Clone-Repository *****

#----------------------------------------------------------
# End of functions
#----------------------------------------------------------

##=============================================
## SCRIPT BODY
## Main routine starts here
##=============================================
Set-StrictMode -Version Latest;
$ErrorActionPreference = 'Stop';

Invoke-Command -ScriptBlock {

   Write-Output '';
   Write-Output 'Clone online GitHub repository to local repository';
   $dateMask = Get-Date -Format 'dddd, dd MMMM yyyy HH:mm:ss';
   Write-Output ('Today is {0}' -f $dateMask);

   $script = $MyInvocation.MyCommand.Name;
   $scriptPath = Split-Path -Parent -Path $MyInvocation.MyCommand.Definition;
   Write-Output ('Running script {0} in directory {1}' -f $script,$scriptPath);

}

$ConfigData = [PSCustomObject]@{
   #Base URL of my online GitHub repository
   BaseUrl       = 'https://github.com/ian8667';

   #Base directory of my local Git repository. All of my
   #local repositories will be in this directory
   BaseDirectory = 'C:\IanmTools\GitRepos';
}
Set-Variable -Name 'ConfigData' -Option ReadOnly;

#Get the remote GitHub URL that we'll use to clone to a
#local Git repository
$uri = Get-CloneUrl -Base $ConfigData.BaseUrl;
Set-Variable -Name 'uri' -Option ReadOnly;

#The last segment of the URI contains the name of the actual
#repository that will be cloned. i.e., 'powershell' repository,
#'java' repository, etc. If the user has chosen to exit, then
#this segment will contain the value 'Exit'. Exit if this is
#the case with no further action.
$lastSegment = $uri.Segments[-1];
if ($lastSegment -eq 'Exit') {
   Write-Warning -Message 'Quitting at user request. No further action taken';
   return;
}

Write-Output ('The clone uri is now [{0}]' -f $uri);

Clone-Repository -CloneUri $uri -Base $ConfigData.BaseDirectory;

Write-Output 'Local Git repositories created in the last few minutes';
Get-ChildItem -Directory -Path $ConfigData.BaseDirectory |
Where-Object -Property 'CreationTime' -GT -Value (Get-Date).AddMinutes(-5);

[System.Linq.Enumerable]::Repeat("", 2); #blanklines
Write-Output 'All done now';
##=============================================
## END OF SCRIPT: Clone-GitRepository.ps1
##=============================================
