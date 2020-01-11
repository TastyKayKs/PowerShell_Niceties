#Test a TCP port's connnection status
    [System.Net.Sockets.TCPClient]::New('127.0.0.1',1234).Connected
    -or for PowerShell v2.0-
    (New-Object System.Net.Sockets.TCPClient -ArgumentList ('127.0.0.1',1234)).Connected

#Always know your script location regardless of version
    If(!$PSScriptRoot){$PSScriptRoot = (Split-Path -Parent $MyInvocation.MyCommand.Defenition)}

#The shortest and fastest way I know of to add a procname to the end of a netstat in powershell
    $X=@{};PS|%{$X[$_.Id]=$_.Name};Netstat -ano|Select -Skip 4|%{"$_"+[Char]9+$X.[Int]$_.Substring(71)}

#Circumvent the Set-ExecutionPolicy
    Powershell.exe -Command "[ScriptBlock]::Create((Get-Content 'PATHTOSCRIPT.ps1')).Invoke()"

#True Press any key to continue (essentially PAUSE from CMD). This won't work in ISE.
    Write-Host 'Press any key to continue...';[Void]$Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown')

#Make any powershell code that uses cmdlets backwards compatible
    $MainBlock = {
        # Code goes here
    }

    If($(Try{[Void][PSObject]::New()}Catch{$True})){
        $MainBlock = ($MainBlock.toString().Split([System.Environment]::NewLine) | %{
            $FlipFlop = $True
        }{
            If($FlipFLop){$_}
            $FlipFlop = !$FlipFlop
        } | %{
            If($_ -match '::New\('){
                (($_.Split('[')[0]+'(New-Object '+$_.Split('[')[-1]+')') -replace ']::New',' -ArgumentList ').Replace(' -ArgumentList ()','')
            }Else{
                $_
            }
        }) -join [System.Environment]::NewLine
    }
    $MainBlock = [ScriptBlock]::Create($MainBlock)

    $MainBlock.Invoke($Macro)
