# List<T> Class
# https://docs.microsoft.com/en-us/dotnet/api/system.collections.generic.list-1?view=netframework-4.7.2
#
$fred = New-Object -TypeName 'System.Collections.Generic.List[String](50)';
[Int32]$response = -1;
[Int32]$hashIndex = 0;
$hash = @{}


# Look for any MS Windows services of interest adding them to
# the hashtable as we go along. The possibility exists we won't
# find any services of interest.
Get-WmiObject -Class 'Win32_Service' |
  Where-Object {($_.Name -match '^R') -and ($_.State -eq "Running")} |
  ForEach-Object {$hash.Add($hashIndex, $_.Name); $hashIndex++}

if ($hash.Count -eq 0) {
  Write-Output "No items to process. Nothing more to do";
} else {

  # Add the exit option to the hashtable.
  $hash.Add($hashIndex, 'Exit');

  # We have to wait until we've populated our hashtable object
  # first before we can create these two variables as there
  # is a dependency.
  $Limit = @{"Min" = 0; "Max" = ($hash.Count - 1)}
  $promptMsg = [String]::Format("Please enter a number [0 - $(($hash.count) - 1 )] ");


  Write-Host '';
  do {

      # Loop through the hashtable so we have an idea what
      # choices (options) we have to choose from.
      foreach ($item in $hash.GetEnumerator() | Sort-Object Name) {
         Write-Output ("{0}     {1}" -f $item.Name, $item.Value);
      }

      # Obtain the required choice.
      $response = Read-Host -Prompt $promptMsg;
  } until ($response -in $Limit.Min..$Limit.Max)

  Write-Host 'Looking at an item';
  $resp = $hash[$response];
  Write-Host ("response is now: {0} which is {1}" -f $response, $resp);

}

Write-Host 'End of test';
