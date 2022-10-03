Using Module .\Player.psm1 
Using Module .\Move.psm1
Using Module .\Game.psm1

# Turnplayer 1 or 2
function Get-Action ($currentstate, $statemap_obj)
{
    $c = $currentstate
    return $statemap_obj[("{0}{1}{2}{3}" -f $c.l1, $c.r1, $c.l2, $c.r2)]
}

$headless = $true
if ($headless) {$iterations = 1000} else {$iterations = 1}
if ($headless) {$rounds = 1} else {$rounds = 1}


$CPU = 0
$HUMAN = 1

$difficulty = 1
$states = @{}

$stable = "v1.0"
$experimentalMajor = "v2"
$experimentalMinor = 0
if (Get-ChildItem ".\statemaps\$experimentalMajor.$($experimentalMinor + 1).csv" -ErrorAction SilentlyContinue)
{
    throw "Current config will overwrite existing versions"
}

if (-not $headless)
{
    $hashstatesStable = @{}
    import-csv -Path ".\statemaps\$stable.csv" | foreach {$hashstatesStable.add(("{0}{1}{2}{3}" -f $_.l1,$_.r1,$_.l2,$_.r2), $_.result)}
    $states.Add(0,$hashstatesStable)
}
else 
{
    $hashstatesEmpty = @{}
    import-csv -Path ".\statemaps\v0.csv" | foreach {$hashstatesEmpty.add("{0}{1}{2}{3}" -f ($_.l1,$_.r1,$_.l2,$_.r2), $_.result)}
    $states.Add(0,$hashstatesEmpty)

    $hashstatesExp = @{}
    import-csv -Path ".\statemaps\$experimentalMajor.$experimentalMinor.csv" | foreach {$hashstatesExp.add(("{0}{1}{2}{3}" -f $_.l1,$_.r1,$_.l2,$_.r2), $_.result)}
    $states.Add(1,$hashstatesExp)
}



foreach ($round in 1..$rounds)
{
    
    Write-Host "`nRound: $round"
    $games = @()
    $roundStartTime = (get-date)
    foreach ($i in 0..($iterations-1))
    {
        $draw = $false
        $turn = (Get-Random) % 2
        [Game] $game = [Game]::new($turn, $headless)
        :startturn while (-not ($game.p1.dead() -or $game.p2.dead() -or $draw))
        {
            # Draw if timeout
            if ($game.moves -gt 60)
            {
                $draw = $true
                $game.winner = 0
                continue :startturn
            }

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
                Switch ($difficulty)
                {
                    0
                    {
                        $src = @("L","R","S")[(Get-Random) % 3] 
                        $dest = ""
                        if ($src -ne "S")
                        {
                            $dest = @("L","R")[(Get-Random) % 2]
                        }   
                    }

                    1
                    {   
                        $action = Get-Action -currentstate ($game.currentState($turn)) -statemap_obj $states[[int]($turn)]
                        if ([String]::IsNullOrWhiteSpace($Action))
                        {
                            $src = @("L","R","S")[(Get-Random) % 3]  
                            $dest = ""
                            if ($src -ne "S")
                            { 
                                $dest = @("L","R")[(Get-Random) % 2]   
                            }
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

    if ($headless)
    {
        $grouped = $games.winner | group
        $p1wins = $grouped | where {$_.name -eq 1} | select -ExpandProperty count
        $p2wins = $grouped | where {$_.name -eq 2} | select -ExpandProperty count

        Write-Host "P1 Wins:$P1Wins`nP2 Wins:$P2Wins"
        Write-Host "Round Time: $(((get-date) - $roundStartTime).totalseconds)"

        $winningMoves = @()
        foreach ($R2 in 0..4)
        {
            foreach ($L2 in 0..4)
            {
                foreach ($R1 in 0..4)
                {
                    foreach ($L1 in 0..4)
                    {
                        $winningMoves += [WinningMove]::new($L1, $R1, $L2, $R2)
                    }
                }
            }
        }

        Foreach ($game in $games)
        {
            $history = $game.history
            $WinnerMoves = $history | where {$_.turn -eq $game.winner}

            Foreach ($move in $WinnerMoves)
            {
                if ($game.winner -eq 1)
                {
                    $winningmove = $winningMoves | where {
                        $_.L1 -eq $move.L1 -and `
                        $_.R1 -eq $move.R1 -and `
                        $_.L2 -eq $move.L2 -and `
                        $_.R2 -eq $move.R2 
                    }
                }
                elseif ($game.winner -eq 2)
                {
                    $winningmove = $winningMoves | where {
                        $_.L1 -eq $move.L2 -and `
                        $_.R1 -eq $move.R2 -and `
                        $_.L2 -eq $move.L1 -and `
                        $_.R2 -eq $move.R1 
                    }
                }

                $winningmove.add($move.result)
            }
        }

        $newStates = Import-Csv .\AllStatesEmpty.csv
        foreach ($wm in $winningMoves)
        {
            $newState = $newStates | where {
                $_.L1 -eq $wm.L1 -and `
                $_.R1 -eq $wm.R1 -and `
                $_.L2 -eq $wm.L2 -and `
                $_.R2 -eq $wm.R2 
            }

            $result = $wm.GenerateWinningResult()

            if (-not [String]::IsNullOrEmpty($result))
            {
                $newState.result = $result
            }
        }

        for ($i = 0; $i -le $newStates.length; $i++)
        {
            $ns = $newStates[$i]
            if ($ns.result -eq "")
            {
                $oldState = $states[1][("{0}{1}{2}{3}" -f $ns.l1, $ns.r1, $ns.l2, $ns.r2)]
                $newStates[$i].result = $oldState.result
            }
        }

        
        $experimentalMinor++
        $newStates | Export-Csv -Path ".\statemaps\$experimentalMajor.$experimentalMinor.csv" -UseQuotes Never
        $states[(($round-1) % 2)] = (import-csv -Path ".\statemaps\$experimentalMajor.$experimentalMinor.csv")
    }
}