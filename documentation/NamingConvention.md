Here's the rewrite in your voice:

```markdown
# Azure Resource Naming Convention

## Why It Matters

It's 2 AM, something is down, and you're trying to figure out which VM is actually 
your production web server among a list of 50. Is it `VM-prod-01`? `webserver-1`? 
Or that thing called `test-machine` that somehow ended up in production?

A good naming convention tells you **what a resource is**, **what environment it 
belongs to**, and **what it does** just by looking at the name. I picked this up as 
a Technical Writer and I use naming conventions even when I'm the only person using 
the system — I even have one for my Minecraft schematics. It might sound excessive, 
but it saves time and prevents headaches.

---

## What You Get Out of It

* **Instant context** — see `az-pola-prod-eastus-vm-web-01` in a log and you 
  immediately know the project, environment, region, and that it's the first web 
  server. No guessing.

* **Reliable automation** — consistent naming makes scripts and pipelines simpler 
  and more predictable.

* **Faster onboarding** — new team members don't need a map to understand what's 
  what.

---

## The Pattern

```
{prefix}-{environment}-{location}-{resource-type}-{identifier}
```

**Example:** `az-pola-dev-eastus-vnet-hub`

| Part | Description | Examples |
|------|-------------|---------|
| prefix | Project / organization code | `az-pola` |
| environment | Lifecycle stage | `dev`, `test`, `prod` |
| location | Azure region | `eastus`, `westus2` |
| resource type | Standardized abbreviation | `vnet`, `vm`, `nsg` |
| identifier | Specific instance or purpose | `hub`, `01`, `app` |

---

## Special Cases

### Storage Accounts

Azure Storage Account names have extra constraints — no hyphens, lowercase only, 
3–24 characters, and globally unique. So the pattern changes slightly:

```
{prefix}{environment}st{identifier}
```

**Example:** `azpoladevst001`

### Virtual Machines

Windows has a 15-character NetBIOS name limit. To avoid truncation issues when 
joining Active Directory, keep identifiers short.

**Example:** `az-pola-dev-eastus-vm-web`

---

## Resource Type Abbreviations

| Resource | Abbreviation | Example |
|----------|-------------|---------|
| Resource Group | `rg` | `az-pola-dev-eastus-rg-hub` |
| Virtual Network | `vnet` | `az-pola-dev-eastus-vnet-hub` |
| Subnet | `snet` | `az-pola-dev-eastus-snet-management` |
| Network Security Group | `nsg` | `az-pola-dev-eastus-nsg-web` |
| Virtual Machine | `vm` | `az-pola-dev-eastus-vm-web-01` |
| Network Interface | `nic` | `az-pola-dev-eastus-nic-web-01` |
| Public IP | `pip` | `az-pola-dev-eastus-pip-bastion` |
| Log Analytics Workspace | `law` | `az-pola-dev-eastus-law-shared` |
| Azure Firewall | `fw` | `az-pola-dev-eastus-fw-hub` |
| Storage Account | `st` | `azpoladevst001` |

---

## How It Works in Code

Naming is defined once in `globals/naming.bicep` and imported wherever standardized 
names are needed. No copy-paste, no drift.

```bicep
module naming '../../globals/naming.bicep' = {
  params: {
    prefix: 'az-pola'
    environment: 'dev'
    locationCode: 'eastus'
  }
}

resource hubVnet 'Microsoft.Network/virtualNetworks@2023-11-01' = {
  name: '${naming.outputs.naming.vnet}-hub'
  // ...
}
```

If you need a resource type that isn't listed here, follow the pattern and add it 
to this document.

---

## One More Thing

This project runs in a single subscription with environment differentiation handled 
through naming. In a real enterprise setup you'd use separate subscriptions per 
environment for isolated billing, cleaner RBAC boundaries, compliance requirements, 
and blast-radius containment — dev mistakes shouldn't be able to touch prod. The 
naming pattern stays the same either way, you're just deploying to different 
subscriptions.
