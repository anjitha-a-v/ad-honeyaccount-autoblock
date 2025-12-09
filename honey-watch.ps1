# ================================
# Honey User Watcher + Auto-Disable
# ================================

Import-Module ActiveDirectory   # so we can manage AD accounts

# 1) BASIC SETTINGS -------------------------
$HoneyUser  = "honey.admin"                     # decoy account
$LogFile    = "C:\SecurityLogs\honey_alerts.txt"
$LookbackMinutes = 10                           # how far back to look first time
$global:LastRecordId = 0                       # remember last processed event

function Write-HoneyAlert {
    param([string]$Message)

    $timestamp = Get-Date -Format "yyyy-MM-ddTHH:mm:ss"
    $line = "$timestamp - $Message"

    Write-Host $line
    Add-Content -Path $LogFile -Value $line
}

function Get-NewHoneyEvents {
    $startTime = (Get-Date).AddMinutes(-$LookbackMinutes)

    $filter = @{
        LogName   = 'Security'
        Id        = 4625          # failed logon
        StartTime = $startTime
    }

    $events = Get-WinEvent -FilterHashtable $filter -ErrorAction SilentlyContinue |
              Where-Object { $_.RecordId -gt $global:LastRecordId } |
              Sort-Object RecordId

    return $events
}

Write-HoneyAlert "===== Honey watcher (AUTO-DISABLE) started for '$HoneyUser' ====="

while ($true) {

    try {
        $newEvents = Get-NewHoneyEvents

        foreach ($ev in $newEvents) {

            if ($ev.RecordId -gt $global:LastRecordId) {
                $global:LastRecordId = $ev.RecordId
            }

            # Parse event XML to get fields
            $xml = [xml]$ev.ToXml()
            $data = @{}
            foreach ($d in $xml.Event.EventData.Data) {
                $data[$d.Name] = $d.'#text'
            }

            $targetUser = $data["TargetUserName"]

            # Only care about our honey user
            if ($targetUser -and ($targetUser.ToLower() -eq $HoneyUser.ToLower())) {

                $ip     = $data["IpAddress"]
                $reason = $data["FailureReason"]
                if (-not $ip)     { $ip = "UNKNOWN" }
                if (-not $reason) { $reason = "Unknown reason" }

                Write-HoneyAlert "FAILED logon on HONEY USER '$targetUser' from IP $ip. Reason: $reason. RecordId=$($ev.RecordId)"

                # Check if honey user is already disabled
                $userObj = Get-ADUser -Identity $HoneyUser -Properties Enabled

                if ($userObj.Enabled -eq $true) {
                    # Disable the honey account
                    Disable-ADAccount -Identity $HoneyUser
                    Write-HoneyAlert "AUTO-ACTION: Disabled honey user account '$HoneyUser'."
                }
                else {
                    Write-HoneyAlert "Honey user '$HoneyUser' is already disabled. No further action."
                }
            }
        }
    }
    catch {
        Write-HoneyAlert "ERROR in watcher loop: $_"
    }

    Start-Sleep -Seconds 5    # small pause before checking again
}
