# Sample menu option choice.
#
$choiceData = DATA {
    ""
    "A - Selection A"
    "B - Selection B"
    "C - Selection C"
    "D - Selection D"
    ""
    "X - Exit"
    ""
}

do {

    do {

        $num = $choiceData.Count - 1;
        foreach ($m in 0..$num) {Write-Host ("{0}" -f $choiceData[$m])}

        Write-Host -NoNewline "Type your choice and press Enter: ";

        $choice = Read-Host;
        Write-Host "";

        $ok = $choice -match '^[abcdx]+$';

        if ( -not $ok) { Write-Error -Message "Invalid selection" }
    } until ( $ok )

    switch -Regex ( $choice ) {
        "A"
        {
            Write-Host "You entered 'A'";
        }

        "B"
        {
            Write-Host "You entered 'B'";
        }

        "C"
        {
            Write-Host "You entered 'C'";
        }

        "D"
        {
            Write-Host "You entered 'D'";
        }
    }
} until ( $choice -match "X" )
