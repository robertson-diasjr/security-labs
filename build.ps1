# Log in on Azure Portal
az login

# Define variables - Change as you need ;-)
$rgname = "myDemoRG"
$location = "brazilsouth"
$containername = "nginxdemos"
$containerimage = "nginxdemos/hello"
$containerIP = "10.0.3.4"
$containerPort = "80"

# Create Resource Group
az group create --name $rgname --location $location

# Create VNET and Subnets
az network vnet create --name myVNet --resource-group $rgname --location $location --address-prefix 10.0.0.0/16 --subnet-name myBackendSubnet --subnet-prefix 10.0.1.0/24
az network vnet subnet create --name myAGSubnet --resource-group $rgname --vnet-name myVNet --address-prefix 10.0.2.0/24
az network vnet subnet create --name myContainerSubnet --resource-group $rgname --vnet-name myVNet --address-prefix 10.0.3.0/24
az network public-ip create --resource-group $rgname --name myAGPublicIPAddress --allocation-method Static --sku Standard

# Create Container
az container create --resource-group $rgname --name $containername --image $containerimage --cpu 1 --memory 1 --ports $containerPort --restart-policy OnFailure --vnet myVNet --subnet myContainerSubnet

# Create Application Gateway
az network application-gateway create --name myAppGateway --location $location --resource-group $rgname --vnet-name myVNet --subnet myAGSubnet --capacity 2 --sku WAF_v2 --http-settings-cookie-based-affinity Disabled --frontend-port $containerPort --http-settings-port $containerPort --http-settings-protocol Http --public-ip-address myAGPublicIPAddress --servers $containerIP

# Create and Enable WAF
az network application-gateway waf-config set --enabled true --gateway-name myAppGateway --resource-group $rgname --firewall-mode Detection --rule-set-version 3.2

# Retrieve App Gateway Public IP to put on actions.yml as target IP
az network public-ip show --resource-group $rgname --name myAGPublicIPAddress --query [ipAddress] --output table
