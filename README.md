# Active Directory Honey User Detection & Auto-Response System �️

This project is a Blue-Team / SOC-style defensive automation system built using **Windows Server 2019 Active Directory + PowerShell**.  

It detects **failed login attempts on a decoy (honey) admin account**, logs the activity, and **automatically disables the account** to prevent brute-force attacks.

---

## 🔥 What This Project Does

Creates a **Honey Admin User** inside Active Directory  
Enables **Security Auditing for failed logons**  
Continuously monitors **Event ID 4625 (Failed Logon)**  
Detects brute-force attempts on the honey user  
Automatically **disables the attacked account**  
Logs all:
 - Attacks
 - Blocked IPs
 - Auto-response actions

---

##  Tools & Technologies Used

- Windows Server 2019
- Active Directory Domain Services (AD DS)
- Group Policy Management (GPO)
- PowerShell Scripting
- Windows Event Viewer (Security Logs)
- VirtualBox Lab Environment

---

## 📂 Project Files

| File Name | Purpose |
|----------|----------|
| `honey-watch.ps1` | Monitors failed logons & disables honey user |
| `auto-block.ps1` | Reads attacker IP & blocks via firewall |
| `attack-log.txt` | Logs all detected brute-force attempts |
| `blocked_ips.txt` | Logs blocked attacker IPs |

---

##  Detection Logic

- Watches for **Event ID 4625**
- Matches login attempts on `honey.admin`
- Extracts:
  - Source IP
  - Username
  - Timestamp
- Triggers:
  - Account disable
  - Firewall IP block
  - Log storage

---

##  Blue-Team Use Case

This project simulates how **real SOC teams detect and automatically respond to brute-force attacks** on Active Directory environments.

---

##  Skills Demonstrated

- Active Directory Administration  
- Event Log Analysis  
- PowerShell Security Automation  
- Account Lockout Defense  
- Real-Time Incident Response  
- SOC Detection Engineering

---

##  Author

**Anjitha**  
Aspiring SOC / Blue-Team / Cybersecurity Analyst  
