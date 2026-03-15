# Connectivity Testing

## What This Is
After deploying the hub-spoke topology and NSGs, I needed to validate that the VNet 
peering was actually working — that traffic could flow between the hub and spoke1 
as expected. I did this by deploying temporary test VMs in each environment and 
attempting to connect across the peering.

## What I Was Testing
- Hub ManagementSubnet → Spoke1 WebSubnet connectivity via VNet peering
- That the NSG rules on WebSubnet allowed the expected traffic
- That the peering established in Bicep works end to end, not just shows as 
  "Connected" in the portal

## Test VM Setup

Two temporary VMs were deployed using a separate `test-vms.bicep` file:

| VM | Resource Group | Subnet | Private IP |
|----|---------------|--------|------------|
| hub-test-vm | az-pola-dev-hubspoke-eastus-rg-hub | ManagementSubnet | 10.0.3.4 |
| spoke1-test-vm | az-pola-dev-hubspoke-eastus-rg-spoke-public | WebSubnet | 10.1.0.4 |

Both VMs use SSH key authentication. No passwords.

A temporary NSG rule (`Test-SSH`) was added manually to the WebSubnet NSG to allow 
inbound SSH on port 22 during testing. This rule is not part of the permanent NSG 
design and was removed after testing.

A temporary public IP (`hub-test-vm-pip`) was attached to the hub VM's primary NIC 
to allow SSH access from outside Azure. This was also removed after testing.

## Lessons Learned
- Private IPs are not reachable from outside Azure — you need a public IP or Bastion 
  to get in from your local machine
- Source port ranges in NSG rules should always be `*` — port numbers like 22 go in 
  the destination port, not the source
- The hub ManagementSubnet has no NSG by design — shared services subnets are 
  controlled at the spoke level
- A VM showing `ProvisioningState: Succeeded` in a Bicep deployment doesn't 
  automatically mean it has a public IP — that has to be explicitly configured

## Cleanup
After testing, remove all temporary resources to avoid unnecessary costs:

### Remove public IPs
```powershell
# Detach public IP from hub VM NIC
$nic = Get-AzNetworkInterface `
  -Name "hub-test-vm-nic" `
  -ResourceGroupName "az-pola-dev-hubspoke-eastus-rg-hub"
$nic.IpConfigurations[0].PublicIpAddress = $null
Set-AzNetworkInterface -NetworkInterface $nic

# Delete the public IP resource
Remove-AzPublicIpAddress `
  -Name "hub-test-vm-pip" `
  -ResourceGroupName "az-pola-dev-hubspoke-eastus-rg-hub" `
  -Force
```

### Remove test VMs and associated resources
```powershell
# Delete hub test VM
Remove-AzVM `
  -Name "hub-test-vm" `
  -ResourceGroupName "az-pola-dev-hubspoke-eastus-rg-hub" `
  -Force

# Delete spoke1 test VM
Remove-AzVM `
  -Name "spoke1-test-vm" `
  -ResourceGroupName "az-pola-dev-hubspoke-eastus-rg-spoke-public" `
  -Force

# Delete NICs
Remove-AzNetworkInterface `
  -Name "hub-test-vm-nic" `
  -ResourceGroupName "az-pola-dev-hubspoke-eastus-rg-hub" `
  -Force

Remove-AzNetworkInterface `
  -Name "spoke1-test-vm-nic" `
  -ResourceGroupName "az-pola-dev-hubspoke-eastus-rg-spoke-public" `
  -Force

# Delete OS disks
Remove-AzDisk `
  -ResourceGroupName "az-pola-dev-hubspoke-eastus-rg-hub" `
  -DiskName "hub-test-vm-osdisk" `
  -Force

Remove-AzDisk `
  -ResourceGroupName "az-pola-dev-hubspoke-eastus-rg-spoke-public" `
  -DiskName "spoke1-test-vm-osdisk" `
  -Force
```

### Remove temporary NSG rule
Go to the portal → WebSubnet NSG → Inbound rules → delete `Test-SSH`.

Or via PowerShell:
```powershell
$nsg = Get-AzNetworkSecurityGroup `
  -Name "az-pola-dev-hubspoke-eastus-nsg-web-public" `
  -ResourceGroupName "az-pola-dev-hubspoke-eastus-rg-spoke-public"

Remove-AzNetworkSecurityRuleConfig `
  -Name "Test-SSH" `
  -NetworkSecurityGroup $nsg

Set-AzNetworkSecurityGroup -NetworkSecurityGroup $nsg
```

## Cost Note
Test VMs and public IPs accrue charges while running. Always clean up after 
connectivity testing in lab environments.