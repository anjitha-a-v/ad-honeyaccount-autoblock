# ================================
# Honey User Auto Block Script
# ================================

$LogFile = "C:\SecurityLogs\blocked_ips.log"

# Get latest failed logon for honey.admin
$event = Get-WinEvent -FilterHashtable @{
    LogName = 'Security'
    Id = 4625
} -MaxEvents 1

$eventText = $event.Message

# Extract Source Network Address safely
$ipLine = ($eventText | Select-String "Source Network Address").Line
$ip = $ipLine.Split(":")[-1].Trim()

# Validate IP (ignore empty & local)
if ($ip -match '^\d{1,3}(\.\d{1,3}){3}$' -and $ip -ne "127.0.0.1") {

    # Prevent duplicate firewall rules
    $exists = Get-NetFirewallRule | Where-Object {$_.DisplayName -like "*$ip*"}

    if (-not $exists) {

        New-NetFirewallRule `
            -DisplayName "HoneyBlock $ip" `
            -Direction Inbound `
            -RemoteAddress $ip `
            -Action Block

        Add-Content $LogFile "$(Get-Date) BLOCKED IP: $ip"

        Write-Output "? Blocked attacker IP: $ip"

    } else {
        Write-Output "?? IP already blocked: $ip"
    }

} else {
    Write-Output "?? No valid attacker IP found in latest log."
}
