#Test a TCP port's connnection status
    [System.Net.Sockets.TCPClient]::New('127.0.0.1',1234).Connected
#    -or for PowerShell v2.0-
    ([System.Activator]::CreateInstance([System.Net.Sockets.TcpClient],@('127.0.0.1',1234))).Connected

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

    $MainBlock.Invoke()

# Find the pointer for any variable in memory, not particularly useful for normal PowerShell, but interesting nonetheless
# This is from here https://stackoverflow.com/questions/4994277/memory-address-of-an-object-in-c-sharp
    Add-Type -TypeDefinition '
    using System;
    using System.Runtime.InteropServices;

    namespace Pointers{
        public static class AddressHelper
        {
            private static object mutualObject;
            private static ObjectReinterpreter reinterpreter;

            static AddressHelper()
            {
                AddressHelper.mutualObject = new object();
                AddressHelper.reinterpreter = new ObjectReinterpreter();
                AddressHelper.reinterpreter.AsObject = new ObjectWrapper();
            }

            public static IntPtr GetAddress(object obj)
            {
                lock (AddressHelper.mutualObject)
                {
                    AddressHelper.reinterpreter.AsObject.Object = obj;
                    IntPtr address = AddressHelper.reinterpreter.AsIntPtr.Value;
                    AddressHelper.reinterpreter.AsObject.Object = null;
                    return address;
                }
            }

            public static T GetInstance<T>(IntPtr address)
            {
                lock (AddressHelper.mutualObject)
                {
                    AddressHelper.reinterpreter.AsIntPtr.Value = address;
                    return (T)AddressHelper.reinterpreter.AsObject.Object;
                }
            }

            // I bet you thought C# was type-safe.
            [StructLayout(LayoutKind.Explicit)]
            private struct ObjectReinterpreter
            {
                [FieldOffset(0)] public ObjectWrapper AsObject;
                [FieldOffset(0)] public IntPtrWrapper AsIntPtr;
            }

            private class ObjectWrapper
            {
                public object Object;
            }

            private class IntPtrWrapper
            {
                public IntPtr Value;
            }
        }
    }
    '


# This one is super ugly, but you can convert a csv to ExpandoObject[]
$Arr = [System.Dynamic.ExpandoObject[]](
    (Import-Csv .\FILE.csv) | %{$Count = 0}{
        Set-Variable -Name ("tmp"+$Count) -Value ([System.Dynamic.ExpandoObject]::new())
        $_.PSObject.Properties | %{
            (Get-Variable ("tmp"+$Count) -ValueOnly).$($_.Name) = $_.Value
        }
        Get-Variable ("tmp"+$Count) -ValueOnly
        $Count++
    }
)
