param vmName string
param location string = 'uksouth'
param vmSize string = 'Standard_B2s'
param adminUsername string

@secure()
param adminPassword string

param imagePublisher string = 'MicrosoftWindowsServer'
param imageOffer string = 'WindowsServer'
param imageSku string = '2022-datacenter'
param publicIpEnabled bool = true

var vnetName = '${vmName}-vnet'
var subnetName = '${vmName}-subnet'
var nsgName = '${vmName}-nsg'
var nicName = '${vmName}-nic'
var pipName = '${vmName}-pip'

//
// VNet + Subnet
//
resource vnet 'Microsoft.Network/virtualNetworks@2023-09-01' = {
  name: vnetName
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        '10.10.0.0/16'
      ]
    }
    subnets: [
      {
        name: subnetName
        properties: {
          addressPrefix: '10.10.1.0/24'
        }
      }
    ]
  }
}

//
// NSG
//
resource nsg 'Microsoft.Network/networkSecurityGroups@2023-09-01' = {
  name: nsgName
  location: location
  properties: {
    securityRules: [
      {
        name: 'Allow-RDP'
        properties: {
          priority: 1000
          access: 'Allow'
          direction: 'Inbound'
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRange: '3389'
          sourceAddressPrefix: '*'
          destinationAddressPrefix: '*'
        }
      }
      {
        name: 'Allow-SSH'
        properties: {
          priority: 1001
          access: 'Allow'
          direction: 'Inbound'
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRange: '22'
          sourceAddressPrefix: '*'
          destinationAddressPrefix: '*'
        }
      }
    ]
  }
}

//
// Public IP (conditional)
//
resource pip 'Microsoft.Network/publicIPAddresses@2023-09-01' = if (publicIpEnabled) {
  name: pipName
  location: location
  sku: {
    name: 'Basic'
  }
  properties: {
    publicIPAllocationMethod: 'Dynamic'
  }
}

//
// NIC
//
resource nic 'Microsoft.Network/networkInterfaces@2023-09-01' = {
  name: nicName
  location: location
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          subnet: {
            id: vnet.properties.subnets[0].id
          }
          publicIPAddress: publicIpEnabled ? {
            id: pip.id
          } : null
        }
      }
    ]
    networkSecurityGroup: {
      id: nsg.id
    }
  }
}

//
// Virtual Machine
//
resource vm 'Microsoft.Compute/virtualMachines@2023-09-01' = {
  name: vmName
  location: location
  properties: {
    hardwareProfile: {
      vmSize: vmSize
    }
    osProfile: {
      computerName: vmName
      adminUsername: adminUsername
      adminPassword: adminPassword
    }
    storageProfile: {
      imageReference: {
        publisher: imagePublisher
        offer: imageOffer
        sku: imageSku
        version: 'latest'
      }
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: nic.id
        }
      ]
    }
  }
  tags: {
    Environment: 'Lab'
    DeployedBy: 'PowerShell'
    Automation: 'Bicep'
  }
}

//
// Outputs
//
output vmNameOut string = vmName
output publicIp string = publicIpEnabled ? pip.properties.ipAddress : 'No Public IP'
