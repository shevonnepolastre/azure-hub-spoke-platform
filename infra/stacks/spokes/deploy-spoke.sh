New-AzSubscriptionDeployment `
  -Name spoke1-deploy `
  -Location eastus `
  -TemplateFile ./spokemain.bicep `
  -TemplateParameterFile ./spoke1.bicepparam
