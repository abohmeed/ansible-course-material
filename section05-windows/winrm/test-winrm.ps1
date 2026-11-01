# Test WinRM over HTTPS from a local Windows machine (PowerShell)
$dnsName = "paste-machine-hostname"

# Add the server to Trusted Hosts (on the local machine)
Set-Item WSMan:\localhost\Client\TrustedHosts -Value $dnsName

# Test WinRM over HTTPS (self-signed certificate, so skip the checks)
$sessionOption = New-PSSessionOption -SkipCACheck -SkipCNCheck -SkipRevocationCheck
Enter-PSSession -ComputerName $dnsName -Credential (Get-Credential) -UseSSL -SessionOption $sessionOption
