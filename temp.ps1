# Sample menu option choice.
#
do {

    do {
        Write-Host ""
        Write-Host "A - Selection A"
        Write-Host "B - Selection B"
        Write-Host "C - Selection C"
        Write-Host "D - Selection D"
        Write-Host ""
        Write-Host "X - Exit"
        Write-Host ""
        Write-Host -NoNewline "Type your choice and press Enter: "

        $choice = Read-Host
        Write-Host "";

        $ok = $choice -match '^[abcdx]+$'

        if ( -not $ok) { Write-Error -Message "Invalid selection" }
    } until ( $ok )

    switch -Regex ( $choice ) {
        "A"
        {
            Write-Host "You entered 'A'"
        }

        "B"
        {
            Write-Host "You entered 'B'"
        }

        "C"
        {
            Write-Host "You entered 'C'"
        }

        "D"
        {
            Write-Host "You entered 'D'"
        }
    }
} until ( $choice -match "X" )
