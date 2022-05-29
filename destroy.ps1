# Log in on Azure Portal
az login

# Define variables
$rgname = "DevSecOps"

# Destroy
az group delete --name $rgname