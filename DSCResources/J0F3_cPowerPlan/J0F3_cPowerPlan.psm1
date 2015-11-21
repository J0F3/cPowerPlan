function Get-TargetResource
{
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]
    param
    (
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

    $CurrentPlan = Get-CimInstance -Namespace root\cimv2\power -ClassName win32_PowerPlan | Where-Object { $_.isActive -eq $true}

    $PlanInfo = @{
        PowerPlan = $CurrentPlan.ElementName
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

    Write-Verbose "Setting correct power plan..."
    $newplan = Get-CimInstance -Namespace root\cimv2\power -ClassName win32_PowerPlan | Where-Object {$_.ElementName -eq $PowerPlan}
    $null = Invoke-CimMethod -InputObject $newplan -MethodName Activate
    
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
    if($current.PowerPlan -eq $PowerPlan)
    {
        Write-Verbose "OK. Correct power plan is set. ($($current.PowerPlan))"
        return $true
    }
    else
    {
        return $false       
    }



    
}


Export-ModuleMember -Function *-TargetResource

