

Function RiskTest
{
    [CmdletBinding(SupportsShouldProcess,ConfirmImpact = "High")]
    param($ProcessName)

    $p = Get-Process $ProcessName
    if($PSCmdlet.ShouldProcess("ProcessName ($($p.Id))", "Stopping the process"))
    {
        Write-Host "Stopped process $ProcessName ($($p.Id))" -ForegroundColor Red
    }

}