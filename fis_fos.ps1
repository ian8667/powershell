#
$bufSize = 10KB;
$opts1 = [PSCustomObject]@{
    path        = 'C:\test\gashInput.txt';
    mode        = [System.IO.FileMode]::Open;
    access      = [System.IO.FileAccess]::Read;
    share       = [System.IO.FileShare]::Read;
    bufferSize  = $bufSize;
    options     = [System.IO.FileOptions]::SequentialScan
}

$opts2 = [PSCustomObject]@{
    path        = 'C:\test\gashOutput.txt';
    mode        = [System.IO.FileMode]::Truncate;
    access      = [System.IO.FileAccess]::Write;
    share       = [System.IO.FileShare]::None;
    bufferSize  = $bufSize;
    options     = [System.IO.FileOptions]::None;
}


try {
  $sw = New-Object -typeName System.Diagnostics.Stopwatch;
  $sw.Start();

  $fis = New-Object -typeName System.IO.FileStream -ArgumentList `
        $opts1.path, $opts1.mode, $opts1.access, $opts1.share, $opts1.bufferSize, $opts1.options;
  $fos = New-Object -typeName System.IO.FileStream -ArgumentList `
        $opts2.path, $opts2.mode, $opts2.access, $opts2.share, $opts2.bufferSize, $opts2.options;

  $fis.CopyTo($fos, $bufSize);

  $sw.Stop();

} catch {
  Write-Error -Message $error[0];
} finally {
	$fos.Flush();
  $fis.Dispose();
  $fos.Dispose();
}

ls $opts1.path, $opts2.path;

Write-Output "`nFile copy complete in  $($sw.Elapsed.TotalSeconds) seconds";

# Ensure both files have the same MD5 hash
$hashInfo = Get-FileHash -Path $opts1.path, $opts2.path -Algorithm MD5;
$hashInfo | Format-List Path, Hash;

if ($hashInfo[0].Hash -ne $hashInfo[1].Hash) {
  Write-Error -Message 'File hashes are not consistent';
}


Write-Host "`nEnd of test";
