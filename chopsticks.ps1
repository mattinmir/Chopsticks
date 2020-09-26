Using Module .\Player.psm1 

class Move
{

    [uint32]$L1
    [uint32]$R1
    [uint32]$L2
    [uint32]$R2
    [uint32]$turn
    [String]$result

    Move([uint32]$_L1,[uint32]$_R1,[uint32]$_L2,[uint32]$_R2,[uint32]$_turn,[String]$_result)
    {
        $this.L1 = $_L1
        $this.R1 = $_R1
        $this.L2 = $_L2
        $this.R2 = $_R2
        $this.turn = $_turn
        $this.result = $_result.ToUpper()

    }
}



[Player] $p1 = [Player]::new([System.ConsoleColor]::Green)
[Player] $p2 = [Player]::new([System.ConsoleColor]::Blue)

$players = @($p1,$p2)
$turn = (Get-Random) % 2
$turnplayer = $players[$turn]
$moves = 1

$cpu = $p1
$player = $p2

$history = @()

$difficulty = 1
$csv = ".\statemap.csv"
$states = import-csv -Path $csv

:startturn while (-not ($p1.dead() -or $p2.dead()))
{
    $premoveL1 = $p1.Left.fingers
    $premoveR1 = $p1.Right.fingers
    $premoveL2 = $p2.Left.fingers
    $premoveR2 = $p2.Right.fingers

    Clear-Host
    
    Write-Host "Move $moves" -ForegroundColor Yellow
    Write-Host "Turn: Player $($turn + 1)" -ForegroundColor $turnplayer.colour

    $p1.print()
    $p2.print()

    if ($turnplayer -ne $cpu)
    {
        Write-Host "Enter source hand..." -ForegroundColor $turnplayer.colour
        Write-Host "Left [L], Right [R], Split [S]" -ForegroundColor $turnplayer.colour
        $src = Read-Host 

        if ($src -eq '[') {$src = 'L'} 
        elseif ($src -eq ']') {$src = 'R'}
        elseif ($src -eq '#') {$src = 'S'}

        if ($src -ne "S")
        {
            Write-Host "Enter Dest hand..." -ForegroundColor $turnplayer.colour
            Write-Host "Left [L], Right [R]" -ForegroundColor $turnplayer.colour
            $dest = Read-Host
            
        if ($dest -eq '[') {$dest = 'L'} 
        elseif ($dest -eq ']') {$dest = 'R'}
        elseif ($dest -eq '#') {$dest = 'S'}
        }
    }
    else 
    {
        Switch ($difficulty)
        {

            0
            {
                $src = @("L","R","S")[(Get-Random) % 3]   
                $dest = @("L","R")[(Get-Random) % 2]   
            }

            1
            {   

                $state = $states | Where {
                    $_.L1 -eq $cpu.Left.fingers -and `
                    $_.R1 -eq $cpu.Right.fingers -and `
                    $_.L2 -eq $player.Left.fingers -and `
                    $_.R2 -eq $player.Right.fingers
                }

                $action = $state.result

                if ([String]::IsNullOrEmpty($Action))
                {
                    $src = @("L","R","S")[(Get-Random) % 3]   
                    $dest = @("L","R")[(Get-Random) % 2]   
                }
                else 
                {
                    $src = $action[0]
                    $dest = $action[1]    
                }
                
            }
        }
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

    $history += [Move]::new($premoveL1, $premoveR1, $premoveL2, $premoveR2, $turn+1, "$src$dest")
    if($turnplayer -eq $cpu) {Start-sleep 1}
    $turn = -not $turn
    $turnplayer = $players[$turn]
    $moves++
    
}

if ($p1.dead())
{
    Clear-Host
    Write-Host "`n`nWINNER!." -ForegroundColor $p2.colour
    $history += [Move]::new($p1.Left.fingers, $p1.Right.fingers, $p2.Left.fingers, $p2.Right.fingers, "", 2)
    $p1.print()
    $p2.print()

    $history | format-table
}
elseif ($p2.dead())
{
    Clear-Host
    Write-Host "`n`nWINNER!." -ForegroundColor $p1.colour
    $history += [Move]::new($p1.Left.fingers, $p1.Right.fingers, $p2.Left.fingers, $p2.Right.fingers, "", 1)
    $p1.print()
    $p2.print()

    $history | format-table
}