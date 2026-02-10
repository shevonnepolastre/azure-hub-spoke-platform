
# Hub and Spoke VNet Biceps

**The hub** (`10.0.0.0/16`) hosts shared services:

* VPN gateway subnet for remote access
* Firewall subnet (reserved, not yet deployed)
* Bastion subnet for secure VM access
* Management subnet for jump boxes and monitoring

**Three spokes** support different workloads:

* **Public app spoke** (`10.1.0.0/16`): Customer-facing web applications
* **Internal spoke** (`10.2.0.0/16`): Employee tools and file shares
* **AI spoke** (`10.3.0.0/16`): Machine learning training and experimentation

Everything is isolated by default. Any traffic between spokes must traverse the hub, allowing centralized inspection and control.

---

## Folder Structure

```
infra/
├── globals/
│   └── naming.bicep              # Centralized naming standards
├── modules/
│   └── network/
│       └── vnet.bicep            # Reusable VNet module
├── stacks/
│   ├── hub/
│   │   ├── main.bicep            # Hub deployment
│   │   └── hub.bicepparam        # Hub parameters
│   └── spokes/
│       ├── main.bicep            # Spoke template (reused)
│       ├── spoke1.bicepparam     # Public app parameters
│       ├── spoke2.bicepparam     # Internal parameters
│       └── spoke3.bicepparam     # AI parameters
└── scripts/
    └── deploy-hub.sh             # Deployment automation
```

---

## Why I Built It This Way

### One Template, Three Spokes

Rather than deploying all spokes from a single template, I deploy the same spokes/main.bicep file three times using different parameter files. I spent a significant amount of time researching this approach and even posted the question on the Azure Discord to gather feedback. The responses were helpful and reinforced that the choice between a single main Bicep file and multiple main Bicep files (for example, separate hub and spoke templates) largely depends on whether the infrastructure is managed by one network team or multiple teams.

Initially, I planned to use a single main Bicep file, assuming a centralized network team model. However, after further consideration, I chose this approach because it better supports scenarios where different teams manage and deploy the hub and each of the three spokes independently. That said, it’s important to emphasize that both approaches are valid—the right choice ultimately depends on how your organization is structured and operates.

**Other Reasons for this Approach**

* You can test `spoke1` before deploying `spoke2` - This helped so if something went wrong with spoke1, I could go back and fix it before deploying the other two spokes. 
* New spokes can be added without redeploying existing ones

At a previous company, the network team owned and deployed all spokes together. That approach can work well depending on team structure. I chose a modular design to demonstrate familiarity with both patterns.

### One Subscription

This project runs in a single Azure subscription, with `dev` included in all resource names. The reason for this is because I'm the only one working on this, and it helps me keep track of the work in one area.  However, in a real-life scenario, it would typically be three separate subscriptions -- Dev, Test, and Prod. This helps in cost management and enforcing different security controls.  I would even have AI be in its own subscription being that it's new and it would probably have additional compliance it has to adhere to. 

## How to Deploy

**Deploy the hub first:**

```powershell
New-AzSubscriptionDeployment `
  -Name hub-deployment `
  -Location eastus `
  -TemplateFile ./infra/stacks/hub/main.bicep `
  -TemplateParameterFile ./infra/stacks/hub/hub.bicepparam
```

**Then deploy each spoke:**

```powershell
New-AzSubscriptionDeployment `
  -Name spoke1-deployment `
  -Location eastus `
  -TemplateFile ./infra/stacks/spokes/main.bicep `
  -TemplateParameterFile ./infra/stacks/spokes/spoke1.bicepparam
```

Repeat for `spoke2` and `spoke3`.

---

## What’s Still Missing

This is the foundation. Planned next steps include:

1. **VNet peering** – Connect spokes to the hub
2. **NSGs** – Restrict and define allowed traffic flows
3. **Bastion** – Deploy secure VM access
4. **Test VMs** – Validate end-to-end connectivity
5. **Firewall** – Add Azure Firewall for centralized inspection (budget permitting)


## What I Learned

* **Bicep modules are worth the upfront effort.** Writing `vnet.bicep` once and reusing it four times was far cleaner than copy-pasting similar code.
* **Naming matters more than you expect.** During an interview demo six months from now, I don’t want to guess which environment a resource belongs to.
* **Infrastructure should be boring.** The goal isn’t clever code—it’s reliable, repeatable deployments that others can understand and extend.

---

## Resources I Used

* [Microsoft hub-and-spoke guidance](https://learn.microsoft.com/en-us/azure/cloud-adoption-framework/ready/azure-best-practices/hub-spoke-network-topology)
* [Bicep modules documentation](https://learn.microsoft.com/en-us/azure/azure-resource-manager/bicep/modules)
* [Azure naming best practices](https://learn.microsoft.com/en-us/azure/cloud-adoption-framework/ready/azure-best-practices/resource-naming)
