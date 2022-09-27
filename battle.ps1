Using Module .\Player.psm1 
Using Module .\move.psm1

class WinningMove
{
    [uint32]$L1
    [uint32]$R1
    [uint32]$L2
    [uint32]$R2
    [String[]]$results
    [String]$winningresult

    WinningMove([uint32]$_L1,[uint32]$_R1,[uint32]$_L2,[uint32]$_R2)
    {
        $this.L1 = $_L1
        $this.R1 = $_R1
        $this.L2 = $_L2
        $this.R2 = $_R2
    }

    [Void] add([String] $result)
    {
        $this.results += $result
        #$this.winningresult = $this.results | Group-Object | Sort-Object Count -descending | Select-Object -First 1 -ExpandProperty Name
    }

    [String] GenerateWinningResult()
    {
        $this.winningresult = $this.results | Group-Object | Sort-Object Count -descending | Select-Object -First 1 -ExpandProperty Name
        return $this.winningresult
    }

}

function Set-State ($L1,$R1,$L2,$R2,$turnval,[ref]$turn)
{
    $p1.Left.fingers = $L1
    $p1.Right.fingers = $R1
    $p2.Left.fingers = $L2
    $p2.Right.fingers = $R2

    $turn.Value = ($turnval-1)
}

# Turnplayer 1 or 2
function Get-Action ($turnplayer, $currentstate, $statemap_obj)
{
    $c = $currentstate
    if ($turnplayer -eq 1)
    {
        $state = $statemap_obj | Where-Object {
            $_.L1 -eq $c.L1 -and `
            $_.R1 -eq $c.R1 -and `
            $_.L2 -eq $c.L2 -and `
            $_.R2 -eq $c.R2
        }
    }
    elseif ($turnplayer -eq 2)
    {
        $state = $statemap_obj | Where-Object {
            $_.L1 -eq $c.L2 -and `
            $_.R1 -eq $c.R2 -and `
            $_.L2 -eq $c.L1 -and `
            $_.R2 -eq $c.R1
        }
    }

    return $state.result 
}



$histories = @()

$csv = ".\statemap.csv"
$states = import-csv -Path $csv

$p1wins = 0
$p2wins = 0

$iterations = 500
foreach ($i in 0..($iterations-1))
{
    [Player] $p1 = [Player]::new([System.ConsoleColor]::Green)
    [Player] $p2 = [Player]::new([System.ConsoleColor]::Blue)

    $players = @($p1,$p2)
    $turn = (Get-Random) % 2
    $turnplayer = $players[$turn]
    $moves = 1

    # Set-State 1 1 1 1 1 ([ref]$turn)

    $history = @()
    #$history += [Move]::new($p1.Left.fingers, $p1.Right.fingers, $p2.Left.fingers, $p2.Right.fingers, $turn+1, "")
    #$history | ft

    :startturn while (-not ($p1.dead() -or $p2.dead()))
    {
        $premoveL1 = $p1.Left.fingers
        $premoveR1 = $p1.Right.fingers
        $premoveL2 = $p2.Left.fingers
        $premoveR2 = $p2.Right.fingers

        Switch ($turn+1)
        {
            2
            {
                $src = @("L","R","S")[(Get-Random) % 3]   
                $dest = @("L","R")[(Get-Random) % 2]   
            }

            1
            {   
                #$action = Get-Action -turnplayer $turn+1 -currentstate 

                $state = $states | Where {
                    $_.L1 -eq $p1.Left.fingers -and `
                    $_.R1 -eq $p1.Right.fingers -and `
                    $_.L2 -eq $p2.Left.fingers -and `
                    $_.R2 -eq $p2.Right.fingers
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
        
        Switch ($src)
        {
            "S"
            {
                # If split returns false, split was invalid so don't change turns
                if(-not $turnplayer.Split())
                {
                    Continue startturn
                }
                $dest = ""
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
        #$history | ft
        $turn = -not $turn
        $turnplayer = $players[$turn]
        $moves++
        
    }

    if ($p1.dead())
    {
        #Write-Host "`nWINNER: P2" -ForegroundColor $p2.colour
        $history += [Move]::new($p1.Left.fingers, $p1.Right.fingers, $p2.Left.fingers, $p2.Right.fingers, "", 2)
        $p2wins++
        #$history | Format-Table
    }
    elseif ($p2.dead())
    {
        #Write-Host "`n`nWINNER: P1" -ForegroundColor $p1.colour
        $history += [Move]::new($p1.Left.fingers, $p1.Right.fingers, $p2.Left.fingers, $p2.Right.fingers, "", 1)
        $p1wins++
        #$history | Format-Table
    }

    $histories += ,$history
}

Write-Host "P1 Wins:$P1Wins`nP2 Wins:$P2Wins"
$p2wingames = @()
$p2wingames += ,($histories | where {$_[-1].result -eq 2})
# $p2wingames | ft

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


Foreach ($h in $histories)
{
    $Winner = $h[-1].result
    $WinnerMoves = $h | where {$_.turn -eq $winner}

    Foreach ($move in $WinnerMoves)
    {
        if ($winner -eq 1)
        {
            $winningmove = $winningMoves | where {
                $_.L1 -eq $move.L1 -and `
                $_.R1 -eq $move.R1 -and `
                $_.L2 -eq $move.L2 -and `
                $_.R2 -eq $move.R2 
            }
        }
        else 
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

foreach ($wm in $winningMoves)
{
    $state = $states | where {
        $_.L1 -eq $wm.L1 -and `
        $_.R1 -eq $wm.R1 -and `
        $_.L2 -eq $wm.L2 -and `
        $_.R2 -eq $wm.R2 
    }

    $result = $wm.GenerateWinningResult()

    if (-not [String]::IsNullOrEmpty($result))
    {
        $state.result = $result
    }
}


$states | Export-Csv -path out.csv -NoTypeInformation -UseQuotes Never

