az vm extension set `
  --resource-group rg-ha-web `
  --vm-name webvm01 `
  --name CustomScriptExtension `
  --publisher Microsoft.Compute `
  --settings '{"commandToExecute":"powershell Add-WindowsFeature Web-Server"}'
