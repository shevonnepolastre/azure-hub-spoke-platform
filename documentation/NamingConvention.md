# Azure Resource Naming Convention

## Why It’s Important

It’s 2 AM, something is down, and you’re trying to figure out which VM is actually your production web server among a list of 50. Is it `VM-prod-01`? `webserver-1`? Or that thing called `test-machine` that somehow ended up in production?

An effective naming convention lets you understand **what a resource is**, **what environment it belongs to**, and **what it does** just by looking at its name. This is a practice I picked up as a Technical Writer, and I use naming conventions even when I’m the only person using the system.

For example, I have a naming convention for my Minecraft schematics. It might sound excessive—but it saves time and prevents headaches in the long run.

---

## What This Gets Us

* **Instant context**
  See `az-pola-prod-eastus-vm-web-01` in a log? You immediately know the project, environment, region, and that it’s the first web server.

* **Reliable automation**
  Consistent naming makes automation simpler and more predictable.

* **Faster onboarding**
  New team members don’t need a map to understand what’s what.

---

## The Pattern

The pattern used in my hub-and-spoke architecture is:

```
{prefix}-{environment}-{location}-{resource-type}-{identifier}
```

**Example:** `az-pola-dev-eastus-vnet-hub`

| Part          | Description                  | Examples              |
| ------------- | ---------------------------- | --------------------- |
| prefix        | Project / organization code  | `az-pola`             |
| environment   | Lifecycle stage              | `dev`, `test`, `prod` |
| location      | Azure region                 | `eastus`, `westus2`   |
| resource type | Standardized abbreviation    | `vnet`, `vm`, `nsg`   |
| identifier    | Specific instance or purpose | `hub`, `01`, `app`    |

---

## Special Cases

### Storage Accounts

Azure Storage Account names have additional constraints:

* No hyphens allowed
* Lowercase only
* 3–24 characters
* Must be globally unique

**Pattern:**

```
{prefix}{environment}st{identifier}
```

**Example:** `azpoladevst001`

---

### Virtual Machines

Windows enforces a 15-character NetBIOS name limit. To avoid truncation issues when joining Active Directory, we keep identifiers short.

**Pattern:**
`az-pola-dev-eastus-vm-web`
(13 characters before the identifier)

---

## Resource Type Abbreviations

Common resources we use:

| Resource                | Abbreviation | Example                              |
| ----------------------- | ------------ | ------------------------------------ |
| Resource Group          | `rg`         | `az-pola-dev-eastus-rg-hub`          |
| Virtual Network         | `vnet`       | `az-pola-dev-eastus-vnet-hub`        |
| Subnet                  | `snet`       | `az-pola-dev-eastus-snet-management` |
| Network Security Group  | `nsg`        | `az-pola-dev-eastus-nsg-web`         |
| Virtual Machine         | `vm`         | `az-pola-dev-eastus-vm-web-01`       |
| Network Interface       | `nic`        | `az-pola-dev-eastus-nic-web-01`      |
| Public IP               | `pip`        | `az-pola-dev-eastus-pip-bastion`     |
| Log Analytics Workspace | `law`        | `az-pola-dev-eastus-law-shared`      |
| Azure Firewall          | `fw`         | `az-pola-dev-eastus-fw-hub`          |
| Storage Account         | `st`         | `azpoladevst001`                     |

---

## How This Works in Code

We define naming conventions once in `globals/naming.bicep` and import them wherever standardized names are required. No copy-paste, no drift.

```bicep
// The Hub VNet gets created with the correct name automatically
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

If you need to create a resource type that isn’t documented here, follow the pattern and add it to this document.

---

## Real-World Note

This project uses a single Azure subscription with environment differentiation handled through naming (`dev`, `test`, `prod`). In real enterprise environments, you’d typically use **separate subscriptions per environment** for:

* Isolated billing and cost tracking
* Clear RBAC boundaries
* Compliance requirements (production has stricter controls)
* Blast-radius containment (dev mistakes don’t affect prod)

The naming pattern stays the same—you simply deploy to different subscriptions using the same Bicep code.

