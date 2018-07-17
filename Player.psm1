using module .\Hand.psm1


$global:rhands = @(

@"
              ___ __
        __.--|   \   |
     __/  \   \   |  |
    /  \   |   |  |  \
    |   |  |   |  |   |
    |\  |  |   |  |   |
    | '-\__'__/--'   |
    \               /
     \             /
      |            |
"@,
@"
              __
             /  \
             |   |
             |   |
             |   |
             |   |
        __.---.  |
     __/  \  __\_|___
    /  \   |/        \
    |   |  |______    |
    |\  |  |   |      |
    | '-\__'__/      |
    \         (     /
     \             /
      |            |
"@,
@"
           __ __
          /  V  \
          |  |   |
          |  |   |
          |  |   |
          |  |   |
        __|  |   |
     __/  \  |___|___
    /  \   |/        \
    |   |  |______    |
    |\  |  |          |
    | '-\__'   /     |
    \         (     /
     \             /
      |            |
"@,
@"
           __ __
        _ /  V  \
       / \|  |   |
       |  |  |   |
       |  |  |   |
       |  |  |   |
       |  |  |   |
     __|  |  |___|___
    /  \    /        \
    |   |  |______    |
    |\  |             |
    | '-'      /     |
    \         (     /
     \             /
      |            |
"@,
@"
           __ __
      _ _ /  V  \
     / V \|  |   |
    |  |  |  |   |
    |  |  |  |   |
    |  |  |  |   |
    |  |  |  |   |
    |  |  |  |___|___
    |  |    /        \
    |      |______    |
    |                 |
    |          /     |
    \         (     /
     \             /
      |            |
"@
)
$global:lhands = @(
@"
   __ ___
  |   /   |--.__
  |  |   /   /  \__
  /  |  |   |   /  \
 |   |  |   |  |   |
 |   |  |   |  |  /|
  |   '--\__'__/-' |
   \               /
    \             /
    |            |
"@,
@"
        __
       /  \
      |   |
      |   |
      |   |
      |   |
      |  .---.__
   ___|_/__  /  \__
  /        \|   /  \
 |    ______|  |   |
 |      |   |  |  /|
  |      \__'__/-' |
   \     )         /
    \             /
    |            |

"@,
@"
        __ __
       /  V  \
      |   |  |
      |   |  |
      |   |  |
      |   |  |
      |   |  |__
   ___|___|  /  \__
  /        \|   /  \
 |    ______|  |   |
 |          |  |  /|
  |     \   '__/-' |
   \     )         /
    \             /
    |            |
"@,
@"
        __ __
       /  V  \ _
      |   |  |/ \
      |   |  |  |
      |   |  |  |
      |   |  |  |
      |   |  |  |
   ___|___|  |  |__
  /        \    /  \
 |    ______|  |   |
 |             |  /|
  |     \      '-' |
   \     )         /
    \             /
    |            |
"@,
@"
        __ __
       /  V  \ _ _
      |   |  |/ V \
      |   |  |  |  |
      |   |  |  |  |
      |   |  |  |  |
      |   |  |  |  |
   ___|___|  |  |  |
  /        \    |  |
 |    ______|      |
 |                 |
  |     \          |
   \     )         /
    \             /
    |            |
"@
)


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
            $this.Left.Add($value)
            return $this.Left.fingers
        }

        elseif ($Hand -eq "Right")
        {
            $this.Right.Add($value)
            return $this.Right.fingers
        }

        else
        {
            Return -1
        }
    }

    [bool] Split()
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

    [Void] Print()
    {
        $r = $global:rhands[$this.Right.fingers].split("`n")
        $l = $global:lhands[$this.Left.fingers].split("`n")
        foreach ($i in 0..15)
        {
            Write-Host -NoNewline $l.split("`n")[$i]
            Write-Host -NoNewline ",,,,,,,,,,,,,,,,,,"
            Write-Host $r.split("`n")[$i]
        }
    }

    [Bool] Dead()
    {
        return $this.Left.fingers + $this.Right.fingers
    }
}