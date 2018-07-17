using module .\Player.psm1

$p1 = [Player]::new()
$p2 = [Player]::new()

#while (-not ($p1.dead() -or $p2.dead()))

$p1.Print()
