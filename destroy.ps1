# Log in on Azure Portal
az login

# Define variables - Change as you need ;-)
$rgname = "myDemoRG"

# Destroy
az group delete --name $rgname