. .\Hand.ps1

Class Player
{
    [Hand] $Left
    [Hand] $Right

    Player()
    {
        $this.left = [Hand]::new()
        $this.right = [Hand]::new()
    }

    [int32] GetFingers([String] $hand)
    {
        if ($Hand -eq "Left")
        {
            return $this.Left.fingers
        }

        elseif ($Hand -eq "Right")
        {
            return $this.Right.fingers
        }

        else
        {
            Return -1
        }
    }

    [int32] AddFingers([int32] $value, [String] $hand)
    {
        if ($Hand -eq "Left")
        {
            $Left.Add($value)
            return $this.Left.fingers
        }

        elseif ($Hand -eq "Right")
        {
            $Right.Add($value)
            return $this.Right.fingers
        }

        else
        {
            Return -1
        }
    }

    [bool] split()
    {
        $fingers = ($this.Left.fingers, $this.right.fingers)

        If (Compare-Object $fingers -DifferenceObject (0,2))
        {
            $this.left.fingers = 1
            $this.right.fingers = 1
            Return $true
        }
        ElseIf (Compare-Object $fingers -DifferenceObject (0,4))
        {
            $this.left.fingers = 2
            $this.right.fingers = 2
            Return $true
        }
        ElseIf (Compare-Object $fingers -DifferenceObject (1,3))
        {
            $this.left.fingers = 2
            $this.right.fingers = 2
            Return $true
        }
        ElseIf (Compare-Object $fingers -DifferenceObject (2,4))
        {
            $this.left.fingers = 3
            $this.right.fingers = 3
            Return $true
        }
        else
        {
            Return $false
        }
    }
}