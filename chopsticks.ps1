Using Module .\Player.psm1 
Using Module .\Move.psm1
Using Module .\Game.psm1

# Turnplayer 1 or 2
function Get-Action ($currentstate, $statemap_obj)
{
    $c = $currentstate
    $state = $statemap_obj | Where-Object {
        $_.L1 -eq $c.L1 -and `
        $_.R1 -eq $c.R1 -and `
        $_.L2 -eq $c.L2 -and `
        $_.R2 -eq $c.R2
    }
    return $state.result 
}

$headless = $true
if ($headless) {$iterations = 100000} else {$iterations = 1}
$CPU = 0
$HUMAN = 1

$difficulty = 1
$csv = ".\statemap.csv"
$states = import-csv -Path $csv

$games = @()
foreach ($i in 0..($iterations-1))
{
    $turn = (Get-Random) % 2
    [Game] $game = [Game]::new($turn, $headless)

    :startturn while (-not ($game.p1.dead() -or $game.p2.dead()))
    {
        $turnplayer = $game.players[$turn]
        if (-not $headless -and $turn -ne $CPU)
        {
            Write-Host "Enter source and dest hands..." -ForegroundColor $turnplayer.colour
            Write-Host "Left (L or [), Right (R or ]), Split (S or #)" -ForegroundColor $turnplayer.colour
            $choice = Read-Host 
            $src = $choice[0]
            if ($src -eq '[') {$src = 'L'} 
            elseif ($src -eq ']') {$src = 'R'}
            elseif ($src -eq '#') {$src = 'S'}

            if ($src -ne "S")
            {  
                $dest = $choice[1]  
                if ($dest -eq '[') {$dest = 'L'} 
                elseif ($dest -eq ']') {$dest = 'R'}
                elseif ($dest -eq '#') {$dest = 'S'}
            }
        }
        else 
        {
            if ($headless -and $turn -eq $cpu)
            {
                $_difficulty = 0
            }
            else 
            {
                $_difficulty = $difficulty
            }
            Switch ($_difficulty)
            {
                0
                {
                    $src = @("L","R","S")[(Get-Random) % 3]   
                    $dest = @("L","R")[(Get-Random) % 2]   
                }

                1
                {   
                    $action = Get-Action -currentstate ($game.currentState($turn)) -statemap_obj $states

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

        if (-not $game.legalMove($turn, $src, $dest))
        {
            Continue :startturn
        }
        else 
        {
            $game.move($turn, $src, $dest)
        }
        
        $turn = -not $turn    
    }

    if (-not $headless)
    {
        if ($game.p1.dead())
        {
            Clear-Host
            Write-Host "`n`nWINNER!." -ForegroundColor $game.p2.colour
        }
        elseif ($game.p2.dead())
        {
            Clear-Host
            Write-Host "`n`nWINNER!." -ForegroundColor $game.p1.colour
        }
        $game.history | format-table
    }
    $game.winner = $game.history[-1].turn
    $games += $game
}

$grouped = $games.winner | group
$p1wins = $grouped | where {$_.name -eq 1} | select -ExpandProperty count
$p2wins = $grouped | where {$_.name -eq 2} | select -ExpandProperty count

Write-Host "P1 Wins:$P1Wins`nP2 Wins:$P2Wins"