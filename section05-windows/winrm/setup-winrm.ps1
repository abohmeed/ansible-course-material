# Lecture: Setting up a Windows host and enabling WinRM (Section 5)
# Run on the Windows server in PowerShell **as Administrator** (RDP as Administrator first).
# Define Variables
$dnsName = "paste-machine-hostname"

# Generate Self-Signed Certificate
$cert = New-SelfSignedCertificate -CertStoreLocation Cert:\LocalMachine\My `
    -DnsName $dnsName `
    -KeyLength 2048 `
    -NotAfter (Get-Date).AddYears(5) `
    -FriendlyName "WinRM HTTPS Certificate"
$certThumbprint = $cert.Thumbprint
Write-Output "Certificate Thumbprint: $certThumbprint"

# Create HTTPS Listener
winrm create winrm/config/Listener?Address=*+Transport=HTTPS "@{Hostname=`"$dnsName`";CertificateThumbprint=`"$certThumbprint`"}"

# Verify Listener (we should have two listeners: HTTP and HTTPS)
winrm enumerate winrm/config/Listener

# Configure Firewall Rules
New-NetFirewallRule -DisplayName "Allow WinRM over HTTP" `
    -Direction Inbound -Protocol TCP -LocalPort 5985 -Action Allow

New-NetFirewallRule -DisplayName "Allow WinRM over HTTPS" `
    -Direction Inbound -Protocol TCP -LocalPort 5986 -Action Allow

# Enable and Start WinRM Service
Enable-PSRemoting -Force
Set-Service -Name WinRM -StartupType Automatic
Start-Service WinRM

# Enable Compatibility for HTTPS Listener
Set-Item WSMan:\localhost\Service\EnableCompatibilityHttpsListener -Value $true
