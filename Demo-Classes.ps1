<#
Demonstration program showing the use of PowerShell classes.

Classes: see also
about_Classes
https://msdn.microsoft.com/en-us/powershell/reference/5.1/microsoft.powershell.core/about/about_classes

Implementing a .NET Class in PowerShell v5
https://trevorsullivan.net/2014/10/25/implementing-a-net-class-in-powershell-v5/

Can I write a class using powershell?
https://stackoverflow.com/questions/6848741/can-i-write-a-class-using-powershell

Powershell v5 Classes & Concepts
https://xainey.github.io/2016/powershell-classes-and-concepts/

Inheritance in PowerShell Classes
https://www.sapien.com/blog/2016/03/16/inheritance-in-powershell-classes/

Go Back To School with PowerShell Classes
https://mcpmag.com/articles/2016/08/25/powershell-classes.aspx

Beyond custom objects: Create a .NET class
https://www.sapien.com/blog/2014/12/02/beyond-custom-objects-create-a-net-class/

New language features in PowerShell 5.0
https://msdn.microsoft.com/en-us/powershell/wmf/5.0/class_newtype

Adding Methods to a PowerShell 5 Class
Hey, Scripting Guy! Blog
https://blogs.technet.microsoft.com/heyscriptingguy/2015/09/04/adding-methods-to-a-powershell-5-class/

PowerShell Classes: A concrete example
http://powershelldistrict.com/powershell-class/

PowerShell classes - Part 1: Objects
In this series, I will introduce you to the basic concepts
of PowerShell classes.
https://4sysops.com/archives/powershell-classes-part-1-objects/

Introduction To PowerShell Classes
This is going to be the first in a series of posts regarding classes.
I want to talk more about DSC and especially some of the cool things
you can do with class based resources. Before we get to the advanced
use cases, we need to cover the basics.
https://overpoweredshell.com/Introduction-to-PowerShell-Classes/

Note:
The keyword "$this" is a reference to the object's current instance.
Each time we create a new instance of our class and save into a
variable, the class can access its own properties and methods using
this special keyword. Thus, $this.MyUserName refers to the property
value of MyUserName that has been set in the instance of the current
object.

ValidateCount Attribute Declaration
(and other function/variable parameter attribution declarations)
https://learn.microsoft.com/en-us/powershell/scripting/developer/cmdlet/validatecount-attribute-declaration?view=powershell-7.3

File Name    : Demo-Classes.ps1
Author       : Ian Molloy
Last updated : 2023-02-28T16:12:44
Keywords     : powershell class inheritance method

#>

[CmdletBinding()]
Param() #end param

class TopT {
    # Properties
    [String]$joe

    # Constructors
    #TopT() {}

    TopT()
    {
        $this.joe = 'This is joe'
    }

  # Methods
  [System.String]ToString() {
        return ("Name = {0}" -f $this.joe);
   }
} #end of class TopT

#------------------------------------------------

class Bott : TopT {
    # Properties
    [String]$helen

    # Constructors
    #Bott() {}
    Bott()
    {
        $this.helen = 'This is helen'
    }

  # Methods
  [System.String]ToString() {
        return ("Name = {0}" -f $this.helen);
   }

} #end of class Bott

##=============================================
## SCRIPT BODY
## Main routine starts here
##=============================================

Invoke-Command -ScriptBlock {

   Write-Output '';
   Write-Output 'PowerShell class demonstration';
   $dateMask = Get-Date -Format 'dddd, dd MMMM yyyy HH:mm:ss';
   Write-Output ('Today is {0}' -f $dateMask);

   $script = $MyInvocation.MyCommand.Name;
   $scriptPath = Split-Path -Parent -Path $MyInvocation.MyCommand.Definition;
   Write-Output ('Running script {0} in directory {1}' -f $script,$scriptPath);

}

[System.Linq.Enumerable]::Repeat("", 2); #blanklines
Write-Host 'Creating the class object';
$me = [Bott]::new();
Write-Host 'Done';

$me | Format-List * -Force;

Write-Host 'Calling the sub class (helen)';
$me.ToString()

# Calling a member of a super class
Write-Host 'Calling the super class (joe)';
([TopT]$me).ToString()

Write-Host 'End of test';

##=============================================
## END OF SCRIPT: Demo-Classes.ps1
##=============================================
