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

    [bool] legalAddition([int32] $value, [String] $hand)
    {
        $isLegal = $true
        if (($Hand -eq "L" -and $this.Left.fingers -eq 0) -or ($Hand -eq "R" -and $this.Right.fingers -eq 0))
        {
            $isLegal = $false
        }
        return $isLegal
    }

    [bool] legalSplit()
    {
        $validFingerStates = @()
        $validFingerStates += [tuple]::Create(0,2)
        $validFingerStates += [tuple]::Create(0,4)
        $validFingerStates += [tuple]::Create(1,3)
        $validFingerStates += [tuple]::Create(2,4)

        $fingers = ($this.Left.fingers, $this.right.fingers) | Sort-Object
        
        return [tuple]::Create($fingers[0], $fingers[1]) -in $validFingerStates
    }

    [int] AddFingers([int32] $value, [String] $hand)
    {
        $result = -1
        if ($this.legalAddition($value, $hand))
        {
            if ($Hand -eq "L")
            {
                $this.Left.Add($value)
                $result = $this.Left.fingers
            }
            elseif ($Hand -eq "R")
            {
                $this.Right.Add($value)
                $result = $this.Right.fingers
            }
        }
        return $result
    }

    [bool] Split()
    {
        $result = $false
        if ($this.legalSplit())
        {
            $fingers = ($this.Left.fingers, $this.right.fingers) | Sort-Object
            $map = @{
                [tuple]::Create(0,2) = (1,1)
                [tuple]::Create(0,4) = (2,2)
                [tuple]::Create(1,3) = (2,2)
                [tuple]::Create(2,4) = (3,3)
            } 
            $splitFingers = $map[[tuple]::Create($fingers[0], $fingers[1])]

            $this.left.fingers = $splitFingers[0]
            $this.right.fingers = $splitFingers[1]

            $result = $true
        }

        return $result
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