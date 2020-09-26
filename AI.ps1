Using Module .\Player.psm1 
using module .\Hand.psm1

$states = import-csv -Path .\out.csv



[Player] $p1 = [Player]::new([System.ConsoleColor]::Green)
[Player] $p2 = [Player]::new([System.ConsoleColor]::Blue)

$States | ForEach {

    $p1.Left.fingers = [int32]($_.L1)
    $p1.Right.fingers = [int32]($_.R1)
    $p2.Left.fingers = [int32]($_.L2)
    $p2.Right.fingers = [int32]($_.R2)

    $p2.print()
    $p1.print()

    Write-Host "Enter Result (Current: $($_.Result))" -ForegroundColor ([System.ConsoleColor]::Green)
    $result = Read-Host

    if (-not [String]::IsNullOrEmpty($result)) {$_.result = $result}
    $states | Export-Csv -path out.csv -NoTypeInformation

}