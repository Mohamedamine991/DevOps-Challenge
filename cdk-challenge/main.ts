import { Construct } from 'constructs';
import { App, TerraformStack } from 'cdktf';
import { VirtualMachine } from '@cdktf/provider-azurerm/lib/virtual-machine';
import { NetworkInterface } from '@cdktf/provider-azurerm/lib/network-interface';
import { PublicIp } from '@cdktf/provider-azurerm/lib/public-ip';
import { Subnet } from '@cdktf/provider-azurerm/lib/subnet';
import { VirtualNetwork } from '@cdktf/provider-azurerm/lib/virtual-network';
import { ResourceGroup } from '@cdktf/provider-azurerm/lib/resource-group';
import { AzurermProvider } from '@cdktf/provider-azurerm/lib/provider';
import * as fs from 'fs';
import * as path from 'path';

class AzureVmStack extends TerraformStack {
  constructor(scope: Construct, id: string) {
    super(scope, id);

    new AzurermProvider(this, 'azurerm', { features: {},
    clientId: "10032000F5AA1A44",
  clientSecret: "votre-client-secret",
  subscriptionId: "votre-id-de-souscription",
  tenantId: "votre-id-de-locataire",});

    const rg = new ResourceGroup(this, 'resourceGroup', {
      name: 'devops_challenge',
      location: 'East US',
    });

    const vnet = new VirtualNetwork(this, 'vnet', {
      name: 'myVNet',
      addressSpace: ['10.0.0.0/16'],
      location: rg.location,
      resourceGroupName: rg.name,
    });

    const subnet = new Subnet(this, 'subnet', {
      name: 'internal',
      resourceGroupName: rg.name,
      virtualNetworkName: vnet.name,
      addressPrefixes: ['10.0.1.0/24'],
    });

    const publicIp = new PublicIp(this, 'publicIp', {
      name: 'myPublicIp',
      location: rg.location,
      resourceGroupName: rg.name,
      allocationMethod: 'Dynamic',
    });

    const networkInterface = new NetworkInterface(this, 'nic', {
      name: 'myNic',
      location: rg.location,
      resourceGroupName: rg.name,
      ipConfiguration: [{
        name: 'internal',
        subnetId: subnet.id,
        privateIpAddressAllocation: 'Dynamic',
        publicIpAddressId: publicIp.id,
      }],
    });

    const scriptPath = path.resolve(__dirname, 'init-script.sh');
    const scriptContent = fs.readFileSync(scriptPath, 'utf-8');
    const encodedScript = Buffer.from(scriptContent).toString('base64');
    const vm = new VirtualMachine(this, 'vm', {
      name: 'myVm',
      location: rg.location,
      resourceGroupName: rg.name,
      networkInterfaceIds: [networkInterface.id],
      vmSize: 'Standard_DS1_v2',
      storageOsDisk: {
        createOption: 'FromImage',
        name: 'myOsDisk',
      },
      storageImageReference: {
        publisher: 'Canonical',
        offer: 'UbuntuServer',
        sku: '18.04-LTS',
        version: 'latest',
      },
      osProfile: {
        computerName: 'myVm',
        adminUsername: 'adminuser',
        adminPassword: 'Password1234!',
      },
      osProfileLinuxConfig: {
        disablePasswordAuthentication: false,
        customData: encodedScript,
      },
    });
  }
}

const app = new App();
new AzureVmStack(app, 'azure-vm');
app.synth();
