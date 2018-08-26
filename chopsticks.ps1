Using Module .\Player.psm1 




[Player] $p1 = [Player]::new([System.ConsoleColor]::Green)
[Player] $p2 = [Player]::new([System.ConsoleColor]::Blue)

$players = @($p1,$p2)
$turn = 0
$turnplayer = $players[$turn]

:startturn while (-not ($p1.dead() -or $p2.dead()))
{
    Clear-Host
    
    $p1.print()
    $p2.print()

    Write-Host "Enter source hand..." -ForegroundColor $turnplayer.colour
    Write-Host "Left [L], Right [R], Split [S]" -ForegroundColor $turnplayer.colour
    $src = Read-Host 

    if ($src -ne "S")
    {
        Write-Host "Enter Dest hand..." -ForegroundColor $turnplayer.colour
        Write-Host "Left [L], Right [R]" -ForegroundColor $turnplayer.colour
        $dest = Read-Host
    }

    Switch ($src)
    {
        "S"
        {
            # If split returns false, split was invalid so don't change turns
            if(-not $turnplayer.Split())
            {
                Continue startturn
            }
        }

        "L"
        {
            # Can't fight with a dead hand
            if($turnplayer.GetFingers("L") -eq 0)
            {
                Continue startturn
            }

            # If addfingers returns <0 the add was invalid so don't change turns
            if($players[-not $turn].AddFingers($turnplayer.GetFingers("L"), $dest) -lt 0)
            {
                continue startturn
            }
        }

        "R"
        {
            # Can't fight with a dead hand
            if($turnplayer.GetFingers("R") -eq 0)
            {
                Continue startturn
            }

            # If addfingers returns <0 the add was invalid so don't change turns
            if($players[-not $turn].AddFingers($turnplayer.GetFingers("R"), $dest) -lt 0)
            {
                continue startturn
            }
        }

        default
        {
            Continue startturn
        }

    }

    $turn = -not $turn
    $turnplayer = $players[$turn]
}

if ($p1.dead())
{
    Clear-Host
    Write-Host "`n`nWINNER!." -ForegroundColor $p2.colour
    $p1.print()
    $p2.print()
}
elseif ($p2.dead())
{
    Clear-Host
    Write-Host "`n`nWINNER!." -ForegroundColor $p1.colour
    $p1.print()
    $p2.print()
}