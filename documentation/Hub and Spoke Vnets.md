
## Hub-and-Spoke Network Infrastructure

I built this Azure hub-and-spoke network as a portfolio project to demonstrate hands-on infrastructure skills. After managing Azure projects for years as a program manager, I wanted to prove I could design and implement the architecture—not just coordinate the teams building it.

---

## What This Is

A production-style network topology with one central hub and three isolated workload environments—the kind of setup you’d expect at a mid-to-large organization running Azure.

![Azure Hub and Spoke Architecture](./diagrams/hub-spoke-architecture.png)

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

Rather than deploying all spokes in a single template, I deploy the same `spokes/main.bicep` file three times using different parameter files.

**Why this approach?**

* You can test `spoke1` before deploying `spoke2`
* Application teams can update their spoke independently
* New spokes can be added without redeploying existing ones

At a previous company, the network team owned and deployed all spokes together. That approach can work well depending on team structure. I chose a modular design to demonstrate familiarity with both patterns.

---

### Centralized Naming

All resource names are generated from `naming.bicep`, ensuring consistent naming across deployments:

```
az-pola-dev-hubspoke-eastus-vnet-hub
az-pola-dev-hubspoke-eastus-vnet-spoke-app
```

I learned the hard way that when each deployment constructs names slightly differently, you end up with an unmanageable mess six months later. A single naming module prevents that drift.

---

### One Subscription

This project runs in a single Azure subscription, with `dev` included in all resource names.

In production, you’d typically separate dev, test, and prod into different subscriptions to isolate costs and enforce distinct security controls. The infrastructure code would remain the same—you’d simply deploy it to different subscriptions. I opted for a single subscription to keep costs down while job hunting.

---

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

I’m building this incrementally so each component can be tested in isolation. That’s how you avoid debugging a massive deployment that fails at step 47.

---

## What I Learned

* **Bicep modules are worth the upfront effort.** Writing `vnet.bicep` once and reusing it four times was far cleaner than copy-pasting similar code.
* **Naming matters more than you expect.** During an interview demo six months from now, I don’t want to guess which environment a resource belongs to.
* **Infrastructure should be boring.** The goal isn’t clever code—it’s reliable, repeatable deployments that others can understand and extend.

---

## Resources I Used

* [Microsoft hub-and-spoke guidance](https://learn.microsoft.com/en-us/azure/cloud-adoption-framework/ready/azure-best-practices/hub-spoke-network-topology)
* [Bicep modules documentation](https://learn.microsoft.com/en-us/azure/azure-resource-manager/bicep/modules)
* [Azure naming best practices](https://learn.microsoft.com/en-us/azure/cloud-adoption-framework/ready/azure-best-practices/resource-naming)
