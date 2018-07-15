class Hand
{

    [int32] $fingers

    Hand()
    {
        $this.fingers = 1
    }

    [int32] Add([Int32] $Value)
    {
        $This.fingers += $Value
        If ($this.fingers -ge 5)
        {
            $this.fingers = 0
        }

        Return $this.fingers
    }
}

