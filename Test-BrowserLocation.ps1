function Test-BrowserLocation
{
    <#
    .Synopsis
        Tests if the browser is at a specific page.
    .Description
        Tests if the browser is at a specific URL or page name.
    .Example
        Open-Browser -Url http://start-automating.com | 
            Test-BrowserLocation -Name Start-Automating
    .Link
        Set-BrowserLocation
    .Link
        Open-Browser
    #>
    [CmdletBinding(DefaultParameterSetName='LocationUrl')]    
    [OutputType([Boolean])]
    param(
    # The Browser Object.
    [Parameter(Mandatory=$true,
        ValueFromPipeline=$true,
        ValueFromPipelineByPropertyName=$true)]
    [ValidateScript({
        if ($_.psobject.typenames -notcontains 'System.__ComObject' -and -not $_.Quit) {
            throw "Not IE"
        }
        $true
    })]
    $IE,

    # The Expected URL
    [Parameter(Mandatory=$true, ParameterSetName="LocationUrl", Position =0)]    
    [Uri]$Url,
    
    # The Expected Name
    [Parameter(Mandatory=$true, ParameterSetName="LocationName", Position =0)]    
    [string]$Name,
    
    # If set, will perform a wildcard match on the location name or URL
    [switch]$Like,
    # If set, will perform a regular expression match on the location name or URL
    [switch]$Match,
    
    # This script will be executed when the location is determined to be correct
    [ScriptBlock]$On_True,    
    # This script will be executed when the location is determined to be incorrect
    [ScriptBlock]$On_False,
    
    # If set, will try again
    [switch]$TryAgain
    )
    
    process { 
        $triedOnce = $false
        while (-not $triedOnce) {       
            $problem = $false
            if ($psCmdlet.ParameterSetName -eq 'LocationUrl') {
                if ($like) {
                    if ($ie.LocationUrl -notlike $Url) {
                        $problem = $true
                    }
                } elseif ($match ) {
                    if ($ie.LocationUrl -notmatch $Url) {
                        $problem = $true
                    }
                } else {
                    if ($ie.LocationUrl -ne $Url) {
                        $problem = $true                    
                    }                
                }
            } elseif ($psCmdlet.ParameterSetName -eq 'LocationName') {
                if ($like) {
                    if ($ie.LocationName -notlike $name) {
                        $problem = $true
                    }
                } elseif ($match ) {
                    if ($ie.LocationName -notmatch $name) {
                        $problem = $true
                    }
                } else {
                    if ($ie.LocationName -ne $name) {
                        $problem = $true                    
                    }                
                }
            } 
        
            if (-not $problem) {
                if ($psBoundParameters.On_True) 
                {
                    $ie = $ie
                    $sb = [scriptBlock]::Create('param($ie)' + $psBoundParameters.On_True)
                    $null = . $sb $ie
                }                
                $triedOnce = $true
                continue
            } else {
                
                if ($psBoundParameters.On_False) {
                    $ie = $ie
                    $sb = [scriptBlock]::Create('param($ie)' + $psBoundParameters.On_False)
                    $null = . $sb $ie                    
                    if ($TryAgain -and -not $triedOnce) {
                        $triedOnce = $true
                        continue                   
                    } else {
                        break
                    }
                } else {
                    $triedOnce = $true                    
                }
            }
        }
        
        $problem
    }
} 
