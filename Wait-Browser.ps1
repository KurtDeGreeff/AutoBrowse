function Wait-Browser
{
    <#
    .Synopsis
        Waits for a browser to finish loading 
    .Description
        Waits for a browser to finish loading all elements
    .Example        
        Open-Browser -Url http://Start-Automating.com -DoNotWait | 
            Wait-Browser
    .Link
        Open-Browser
    .Link
        Close-Browser
    #>
    [OutputType([PSObject])]
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
    
    # The timeout to wait for the page to reload after an action 
    [Timespan]$Timeout = "0:0:30",
    
    # The timeout to sleep in between each check to see if the page has reloaded
    [Timespan]$SleepTime = "0:0:0.01"
    )
    
    process {
        $start = Get-Date
        
        #region Wait Loop
        while ($Start + $timeout -ge (Get-Date)) {
            if ($ie.Busy) {
                Start-Sleep -Milliseconds $sleepTime.TotalMilliseconds
            }
            
            if ($ie.Document.ReadyState -ne 'Complete') {
                Start-Sleep -Milliseconds $sleepTime.TotalMilliseconds
                continue
            }
            
            $childNodesNotCompleted = $ie.Document.'IHTMLDOMNode_childNodes' | 
                Where-Object {
                    $_.ReadyState -and $_.ReadyState -ne 'Complete'
                }
                
            if ($childNodesNotCompleted) { 
                Start-Sleep -Milliseconds $sleepTime.TotalMilliseconds
                continue
            }
            
            break
        }
        #endregion Wait Loop
        
        #region Did we time out?
        if ($Start + $timeout -lt (Get-Date)) {
            $timedOut = (New-Object TimeoutException)
            Write-Error -Exception $timedOut -ErrorId 'WaitBrowser.Timeout'                        
        }
        #endregion Did we time out?
        $ie                
    }
}