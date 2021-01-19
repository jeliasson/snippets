#
# Configuration
# 

# You can change the addr to your ip config to listen to a specific address
$hostListeningAddress = '0.0.0.0';

#  All ports you want to forward separated (accepts string with dash as range, e.g. 8000-8010)
$hostPorts=@(8910, 8911);

# Firewall rule name
$hostWindowsFirewallRuleName = "WSL2 Port-Forwarding"

###########################################################################################################

# Get the IP address of WSL2 instance
$wslIPAddresses = bash.exe -c "ifconfig eth0 | grep 'inet '"
$wslIPAddressesRegMatch = $wslIPAddresses -match '\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}';

# Check if we got an IP address
if ($wslIPAddressesRegMatch) {
  #  Get first match
  $wslIPAddress = $matches[0];

  # Ask user to confirm before we proceed
  Write-Host "We identified IP address $wslIPAddress on WSL2."
  Read-Host -Prompt "Press any key to continue or CTRL+C to quit" 

} else {
  Write-Host "EXIT: IP-address of WSL2 could not be identified."
  exit;
}

# Implode all ports using comma as delimiter
$hostPortsImpoded = $hostPorts -join ","

# Remove Firewall Exception Rules
Invoke-Expression "Remove-NetFireWallRule -DisplayName '$hostWindowsFirewallRuleName' " | Out-Null

# Adding Firewall exception for inbound and outbound Rules
Invoke-Expression "New-NetFireWallRule -DisplayName '$hostWindowsFirewallRuleName' -Direction Outbound -LocalPort $hostPortsImpoded -Action Allow -Protocol TCP" | Out-Null
Invoke-Expression "New-NetFireWallRule -DisplayName '$hostWindowsFirewallRuleName' -Direction Inbound -LocalPort $hostPortsImpoded -Action Allow -Protocol TCP" | Out-Null

# Delete all current v4tov4 rules
$prevRoutePorts = Invoke-Expression "netsh interface portproxy show v4tov4" | Out-Null | Select-String '(\d{2,5}$)' -AllMatches | Foreach {$_.Matches} | Foreach{$_.Value};
foreach ($port in $prevRoutePorts) {
  $command = "netsh interface portproxy delete v4tov4 listenport=$port listenaddress=$hostListeningAddress"
  Invoke-Expression $command
  Write-Host "Command: $command"
  Write-Host "Done"
}


# add port forward rules
function addPortForward($listenPort) {
  $command = "netsh interface portproxy add v4tov4 listenport=$listenPort connectport=$listenPort connectaddress=$wslIPAddress"
  Invoke-Expression $command
  Write-Host "Command: $command"
  Write-Host "Done"
}

# Loop thru all ports that are to be exposed
for( $i = 0; $i -lt $hostPorts.length; $i++ ){
  $port = $hostPorts[$i];

  # If port is int
  if ($port.GetType() -Eq [int]) {

    # Port-forward
    addPortForward($port);

  # If port is string with range
  } elseif ($port.GetType() -Eq [string]) {
    $delimiterIndex = $port.IndexOf('-');
    if ($delimiterIndex -ge 0) {
      
      # Define ports
      $hostPortRange = $port.Split("{-}");
      $hostPortFrom = [int]$hostPortRange[0];
      $hostPortTo = [int]$hostPortRange[$hostPortRange.length-1];

      for ($port = $hostPortFrom; $port -le $hostPortTo; $port++){

        # Port-forward
        addPortForward($port);
      }
    }
  }
}

