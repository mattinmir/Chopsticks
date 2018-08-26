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
           __ 
        _ /  \ __ 
       / \|  |/  \
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
           __ 
        _ /  | __ 
     __/ \|  |/  |
    /  |  |  |   |
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
    [System.ConsoleColor] $colour

    Player([System.ConsoleColor] $_colour)
    {
        $this.left = [Hand]::new()
        $this.right = [Hand]::new()

        $this.colour = $_colour
    }

    [int32] GetFingers([String] $hand)
    {
        if ($Hand -eq "L")
        {
            return $this.Left.fingers
        }

        elseif ($Hand -eq "R")
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
        if ($Hand -eq "L" -and $this.Left.fingers -ne 0)
        {
            $this.Left.Add($value)
            return $this.Left.fingers
        }

        elseif ($Hand -eq "R" -and $this.Right.fingers -ne 0)
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

        If (-not (Compare-Object -ReferenceObject $fingers -DifferenceObject (0,2)))
        {
            $this.left.fingers = 1
            $this.right.fingers = 1
            Return $true
        }
        ElseIf (-not (Compare-Object -ReferenceObject $fingers -DifferenceObject (0,4)))
        {
            $this.left.fingers = 2
            $this.right.fingers = 2
            Return $true
        }
        ElseIf (-not (Compare-Object -ReferenceObject $fingers -DifferenceObject (1,3)))
        {
            $this.left.fingers = 2
            $this.right.fingers = 2
            Return $true
        }
        ElseIf (-not (Compare-Object -ReferenceObject $fingers -DifferenceObject (2,4)))
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
        [String] $out = ""
        foreach ($i in 0..14)
        {
            $paddingLength = 30 - ($l[$i].trim("`r")).length
            $out += $l[$i].trim("`r")
            $out += " " * $paddingLength
            $out += $r[$i].trim("`r")
            $out += "`n`r"
        }

        Write-Host $out + "`n`n" -foregroundColor $this.colour
        
    }

    [Bool] Dead()
    {
        return -not ($this.Left.fingers + $this.Right.fingers)
    }
}