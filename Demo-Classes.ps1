# Demonstration program showing the use of PowerShell classes.
#
# Classes: see also
# about_Classes
# https://msdn.microsoft.com/en-us/powershell/reference/5.1/microsoft.powershell.core/about/about_classes
#
# Implementing a .NET Class in PowerShell v5
# https://trevorsullivan.net/2014/10/25/implementing-a-net-class-in-powershell-v5/
#
# Can I write a class using powershell?
# https://stackoverflow.com/questions/6848741/can-i-write-a-class-using-powershell
#
# Powershell v5 Classes & Concepts
# https://xainey.github.io/2016/powershell-classes-and-concepts/
#
# Inheritance in PowerShell Classes
# https://www.sapien.com/blog/2016/03/16/inheritance-in-powershell-classes/
#
# Go Back To School with PowerShell Classes
# https://mcpmag.com/articles/2016/08/25/powershell-classes.aspx
#
# Beyond custom objects: Create a .NET class
# https://www.sapien.com/blog/2014/12/02/beyond-custom-objects-create-a-net-class/
#
# New language features in PowerShell 5.0
# https://msdn.microsoft.com/en-us/powershell/wmf/5.0/class_newtype
#
# Adding Methods to a PowerShell 5 Class
# Hey, Scripting Guy! Blog
# https://blogs.technet.microsoft.com/heyscriptingguy/2015/09/04/adding-methods-to-a-powershell-5-class/
#
# PowerShell Classes: A concrete example
# http://powershelldistrict.com/powershell-class/
#
# PowerShell classes - Part 1: Objects
# In this series, I will introduce you to the basic concepts
# of PowerShell classes.
# https://4sysops.com/archives/powershell-classes-part-1-objects/
#
# Note:
# The keyword "$this" is a reference to the object's current instance.
# Each time we create a new instance of our class and save into a
# variable, the class can access its own properties and methods using
# this special keyword. Thus, $this.MyUserName refers to the property
# value of MyUserName that has been set in the instance of the current
# object.
#
# Keywords: powershell class inheritance method
#
# File Name    : Demo-Classes.ps1
# Author       : Ian Molloy
# Last updated : 2017-07-27
#
class TopT {
    # Properties
    [String]$joe
 
    # Constructors
    TopT()
    {
        $this.joe = 'This is joe'
    }

  # Methods
  [System.String]ToString() {
        return ("Name = {0}" -f $this.joe);
   }
} #end of class TopT

class Bott : TopT {
    # Properties
    [String]$helen
 
    # Constructors
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
