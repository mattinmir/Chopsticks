Using Module .\Player.psm1
Using Module .\Move.psm1

class Game
{
    [Player] $p1
    [Player] $p2
    [Array] $players
    [Int] $moves
    [Array] $history

    Game([Int]$turn)
    {
        $this.p1 = [Player]::new([System.ConsoleColor]::Green)
        $this.p2 = [Player]::new([System.ConsoleColor]::Blue)
        $this.players = @($this.p1, $this.p2)
        $this.moves = 1
        $this.history = @()

        $this.print($turn)
    }

    [void] print($turn)
    {
        $turnplayer = $this.players[$turn]

        Clear-Host
    
        Write-Host "Move $this.moves" -ForegroundColor Yellow
        Write-Host "Turn: Player $($this.turn + 1)" -ForegroundColor $turnplayer.colour

        $this.p1.print()
        $this.p2.print()
    }

    [PSCustomObject] currentState($turn)
    {
        return [PSCustomObject]@{
            L1 = $this.players[$turn].GetFingers("L")
            R1 = $this.players[$turn].GetFingers("R")
            L2 = $this.players[-not $turn].GetFingers("L")
            R2 = $this.players[-not $turn].GetFingers("R")
        }
    }

    [bool] legalMove($turn, $src, $dest)
    {
        $turnplayer = $this.players[$turn]
        $isLegal = $true
        Switch ($src)
        {
            "S"
            {
                # If split returns false, split was invalid so don't change turns
                if(-not $turnplayer.legalSplit())
                {
                    $isLegal = $false
                }
            }
    
            "L"
            {
                # Can't fight with a dead hand or
                if (($turnplayer.GetFingers("L") -eq 0) -or (-not ($this.players[-not $turn].legalAddition($turnplayer.GetFingers("L"), $dest))))
                {
                    $isLegal = $false
                }
            }
    
            "R"
            {
                # Can't fight with a dead hand    
                if (($turnplayer.GetFingers("R") -eq 0) -or (-not ($this.players[-not $turn].legalAddition($turnplayer.GetFingers("R"), $dest))))
                {
                    $isLegal = $false
                }
            }
    
            default
            {
                $isLegal = $false
            }  
        }  
        return $isLegal   
    }

    [void] move($turn, $src, $dest)
    {
        $premoveL1 = $this.p1.GetFingers("L")
        $premoveR1 = $this.p1.GetFingers("R")
        $premoveL2 = $this.p2.GetFingers("L")
        $premoveR2 = $this.p2.GetFingers("R")

        $turnplayer = $this.players[$turn]

        Switch ($src)
        {
            "S"
            {
                $turnplayer.Split()
            }
    
            "L"
            {
                $this.players[-not $turn].AddFingers($turnplayer.GetFingers("L"), $dest)
            }
    
            "R"
            {
                $this.players[-not $turn].AddFingers($turnplayer.GetFingers("R"), $dest)
            }  
        } 

        # If CPU turn, wait a second to simulate thinking
        if ($turn -eq "0") {Start-Sleep 1}

        $this.moves++
        $this.print($turn)
        $this.history += [Move]::new($premoveL1, $premoveR1, $premoveL2, $premoveR2, $turn+1, "$src$dest")
    }
}