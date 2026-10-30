work

## Connect to the instance and enable WinRM

Open the Remote Desktop Session to the instance using the downloaded file. The username is Administrator and the password is the one we copied.

Open PowerShell as admin and run the following code:

x

```
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

# Verify Listener (we should have two listensers HTTP and HTTPS)
winrm enumerate winrm/config/Listener

# Configure Firewall Rule
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

```

### Test the connection from a local Windows machine

Test the connection from a local Windows machine through PowerShell:

x

```
$dnsName = "paste-machine-hostname"

# Add EC2 Host to Trusted Hosts (on Remote Machine)
Set-Item WSMan:\localhost\Client\TrustedHosts -Value $dnsName

# Test WinRM Over HTTPS (with self-signed certificate)
$sessionOption = New-PSSessionOption -SkipCACheck -SkipCNCheck -SkipRevocationCheck
Enter-PSSession -ComputerName $dnsName -Credential (Get-Credential) -UseSSL -SessionOption $sessionOption
```

