# List<T> Class
# https://docs.microsoft.com/en-us/dotnet/api/system.collections.generic.list-1?view=netframework-4.7.2
#
$fred = New-Object -TypeName 'System.Collections.Generic.List[String](50)';
[Int32]$response = -1;

# Look for any MS Windows services of interest.
Get-WmiObject -Class 'Win32_Service' |
  Where-Object {($_.Name -match '^R') -and ($_.State -eq "Running")} |
  ForEach-Object {$fred.Add($_.Name)}

if ($fred.Count -eq 0) {
  Write-Output "No items to process. Nothing more to do";
} else {

  # Add the exit option to the list.
  $fred.Add('Exit');

  # We have to wait until we've populated our List<T> object
  # first before we can create these two variables as there
  # is a dependency.
  $Limit = @{"Min" = 0; "Max" = ($fred.count - 1)}
  $promptMsg = [String]::Format("Please enter a number [0 - $(($fred.count) - 1 )] ");


  Write-Host '';
  do {
      [Byte]$choiceCounter = 0;
      foreach ($item in $fred.GetEnumerator()) {
         Write-Host ("{0}    {1}" -f $choiceCounter++, $item);
      }

      $response = Read-Host -Prompt $promptMsg;
  } until ($response -in $Limit.Min..$Limit.Max)

  Write-Host 'Looking at an item';
  $resp = $fred[$response];
  Write-Host ("response is now: {0} which is {1}" -f $response, $resp);

}

Write-Host 'End of test';
