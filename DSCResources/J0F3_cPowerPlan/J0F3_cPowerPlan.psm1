function Get-TargetResource
{
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]
    param
    (
        # Best practice for DSC resource which should be ony once specified in a configuration
        [parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [ValidateSet('Yes')]
        [System.String]
        $IsSingleInstance = 'Yes',

        [parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [ValidateSet('Balanced','High performance','Power saver')]
        [System.String]
        $PowerPlan

    )

    # Get the list of Power Plans
    $PowerCfg = (Invoke-Command { PowerCfg -l })
    $PowerCfg = $PowerCfg[3..$PowerCfg.Count]

    # Locate the name of the active plan
    $ActiveItem = ($PowerCfg | Select-String -Pattern "*" -CaseSensitive:$False -SimpleMatch).ToString()
    $IX0 = $ActiveItem.IndexOf(":")
    $IX1 = $ActiveItem.IndexOf(" ", $IX0+1)
    $IX2 = $ActiveItem.IndexOf(" ", $IX1+1)
    $ActiveGUID = $ActiveItem.SubString($IX1+1, $IX2-$IX1-1)

    $ActivePlan = ($PowerPlans.GetEnumerator() | Where-Object {$_.Value -eq [GUID]$ActiveGUID}).Name

    $PlanInfo = @{
        PowerPlan = $ActivePlan
        PowerPlanGUID = $ActiveGUID
        IsSingleInstance = $IsSingleInstance
    }

    return $PlanInfo
}

function Set-TargetResource
{
    [CmdletBinding()]
    param
    (

        [parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [ValidateSet("Yes")]
        [System.String]
        $IsSingleInstance = 'Yes',

        [parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [ValidateSet('Balanced','High performance','Power saver')]
        [System.String]
        $PowerPlan

    )

    Write-Verbose "Setting desired power plan ($PowerPlan)..."
    # Get GUID for disred plan
    $DesiredPlanGUID = $PowerPlans.Get_Item($PowerPlan)

    Invoke-Command {PowerCfg -s $DesiredPlanGUID}
}

function Test-TargetResource
{
    [CmdletBinding()]
    [OutputType([System.Boolean])]
    param
    (
        [parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [ValidateSet("Yes")]
        [System.String]
        $IsSingleInstance = 'Yes',

        [parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [ValidateSet('Balanced','High performance','Power saver')]
        [System.String]
        $PowerPlan

    )

    Write-Verbose -Message "Checking if the correct power plan is set..."

    $current = Get-TargetResource @PSBoundParameters

    Write-Debug "Current PowerPlan: $($current.PowerPlan)"
    Write-Debug "Desired PowerPlan: $PowerPlan"

    # Get GUIDs of the power plans
    $CurrentPlanGUID = $current.PowerPlanGUID
    $DesiredPlanGUID = $PowerPlans.{Get_Item}($PowerPlan)
    if($CurrentPlanGUID  -eq $DesiredPlanGUID)
    {
        Write-Verbose "OK. Desired Power plan is set ($($current.PowerPlan))"
        return $true
    }
    else
    {
        return $false
    }
}

# Hashtable to look up the GUID for a powerplan by its name
# The GUIDs are documented at https://msdn.microsoft.com/en-us/library/windows/desktop/aa373177(v=vs.85).aspx
$PowerPlans = @{
    'Balanced' = [GUID]'381b4222-f694-41f0-9685-ff5bb260df2e';
    'High performance' = [GUID]'8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c';
    'Power saver' = [GUID]'a1841308-3541-4fab-bc81-f71556f20b4a';
}

Export-ModuleMember -Function *-TargetResource

