# A temporary scratch file only.
# Creating environment variables suitable for using the PowerShell
# console with Oracle. With this, I can use SQL*Plus within the
# PowerShell console.
#
# Last updated: 24 November 2018 20:43:39
#
$fred = [System.EnvironmentVariableTarget]::Process;
Set-Variable -Name 'fred' -Option ReadOnly;

$envVariable='ORACLE_SID'; # The name of an environment variable.
$value='ORCL';  # A value to assign to the environment variable.
[System.Environment]::SetEnvironmentVariable($envVariable, $value, $fred);

$envVariable='ORACLE_HOME'; # The name of an environment variable.
$value='/u04/app/oracle/product/10gR2/db_1';  # A value to assign to the environment variable.
[System.Environment]::SetEnvironmentVariable($envVariable, $value, $fred);
