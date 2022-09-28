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