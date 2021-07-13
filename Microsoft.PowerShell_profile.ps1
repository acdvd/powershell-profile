function mygreprecursive($patt) {
  $excludeList = @("*.jar", "*.bin", "*.class", "*.xaml", "*.dll", "*.exe", "*.pdb")
  Get-ChildItem -Path . -R -Exclude $excludeList | Select-String -Pattern $patt
}
 
New-Alias gr mygreprecursive
function mycurl {
  param(
    [Parameter(Mandatory = $true, ValueFromRemainingArguments = $true)]
    [psobject[]]$InputObject
  )
  $myargs = ""
  foreach ($value in $InputObject) {
    $myargs += $value + " "
  }
  Write-Host "sending: " "/C curl.exe $myargs & pause"
  start-process cmd "/C curl.exe $myargs & pause"
}

function mycurl2 {
  Write-Host $args
  $myargs = ""
  foreach ($value in $args) {
    
    if ($value.Substring(0, 1) -eq '-') {
      Write-Host "is option: " $value
    }
    else {
      Write-Host "is not option: " $value
      if (($value.Substring(0, 1) -ne '''') -and ($value.Substring(0, 1) -ne '"') ) {
        Write-Host "does NOT begin with single or double quote: " $value
        $value = """" + $value + """" # add double quotes to end
      }
      else {
        if (($value.Substring(0, 1) -eq '''')) {
          Write-Host "Does begin with single quote"
          # TODO: if wrapped in single quotes, transform to double quote
        }
        if ($value.Substring(0, 1) -eq '"') {
          Write-Host "Does begin with double quote"
        }
      }
      
    }
    # fix inner quotes
    if($value.Length -gt 3){
      if(($value.Substring(0, 1) -eq '"') -and ($value.Substring($value.Length-1, 1) -eq '"')){
        # if wrapped in quotes fix inner quotes
        Write-Host "corrected sent" $value.Substring(1, $value.Length -2)
        $corrected = correctInnerQuotes($value.Substring(1, $value.Length -2))
        Write-Host "corrected received" $corrected
        $value = $value.Substring(0, 1) + $corrected + $value.Substring($value.Length-1, 1)
      }
    }


    $myargs += $value + " "
  }
  Write-Host "sending: " "/C curl.exe $myargs & pause"
  start-process cmd "/C curl.exe $myargs & pause"
}

# usage in powershell curl1 '-option1 value1 -option2 ...'
# be sure to enclose argument list in single quotes
New-Alias curl1 mycurl2
New-Alias curl2 mycurl2

function testFunc {

  Write-Host $args
  $myargs = ""
  foreach ($value in $args) {
    $myargs += $value + " "
    Write-Host $value
  }
  Write-Host "my args:" $myargs
}

function correctInnerQuotes($mystring) {
  #$mystring = """hat \""my quote"" dat"
  $newString = ""

  #Write-Host $mystring
  foreach ($mychar in $mystring.ToCharArray()) {
    #Write-Host $mychar + " *"
  }

  $before = ""
  for (($i = 0); $i -lt $mystring.Length; $i++) {
    if ($i -eq 0) {
      # if 0th is ", 1 case
      # has no before so will insert \ backslash before
      if ($mystring.Substring($i, 1) -eq '"') {
        $newString += ("\" + $mystring.Substring($i, 1))
      }
      else{
        $newString += $mystring.Substring($i, 1)
      }
    }
    else {
      # if ith is ", 2 cases
      # 2 cases: 
      # has before of "\", will skip
      # does not have a before of "\" will insert it.
      if ($mystring.Substring($i, 1) -eq '"') {
        if ($before -ne "\") {
          $newString += ("\" + $mystring.Substring($i, 1))
        }
        else {
          $newString += $mystring.Substring($i, 1)
        }
      }
      else {
        $newString += $mystring.Substring($i, 1)
      }
    }
    $before = $mystring.Substring($i, 1)

    #Write-Host $i $mystring.Substring($i, 1) " $"
  }
  #Write-Host $newString
  return $newString
}

New-Alias test1 testFunc