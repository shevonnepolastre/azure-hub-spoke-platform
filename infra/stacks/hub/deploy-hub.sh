New-AzSubscriptionDeployment `
  -Name hub-deploy `
  -Location eastus `
  -TemplateFile ./infra/stacks/hub/hubmain.bicep `
  -TemplateParameterFile ./infra/stacks/hub/hub.bicepparam

