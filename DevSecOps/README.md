# Demystifying the basics of security embedded on CI/CD pipelines

This lab aims to shed some insights to reduce or eliminate the grey clouds once DevSecOps discussions are raised into the table.

Below you'll find the first basics steps to help you demystify and implement (initial stages) secure code best practices into CI/CD pipelines.

## Scenario
Here are the tasks we´re gonna pursue:

1. create a container running a web application;
2. put it behind a Web Application Firewall;
3. apply a change in our code and commit to main branch repository;
4. as result of the "git push", a "GitHub Action" will be triggered to perform a DAST (Dynamic Application Security Testing) against the web application.

I believe this diagram depicts better the idea ;-)

![Workflow](https://github.com/robertson-diasjr/security-labs/blob/main/DevSecOps/Diagram.jpg)

## Environment services and tools
1. DAST Tools
    * OWASP Zed Attack Proxy (ZAP)
    * Nikto Web Scanner
2. GitHub
    * GitHub Actions
3. Azure Platform
    * Azure Application Gateway
    * Azure Web Application Firewall
    * Azure Container Instance

## Requirements
1. Azure Tenant (i.e.: AWS account)
2. Azure CLI
3. GitHub

For "Azure CLI" instructions, please visit the URL: https://docs.microsoft.com/en-us/cli/azure/install-azure-cli

## Setup
1. Azure Platform
    - Option 1:
        - extract the Azure CLI commands within "build.ps1" and execute as you prefer
    - Option 2:
        - download the script "build.ps1" and run within a powershell. I.e.: `.\build.ps1`

2. GitHub Repository
    - Step 1: 
        - Update the file "actions.yaml" and insert the public IP created on previous step (it´s our target web server)
    - Step 2:
        - Inside main repo > click on **Actions** (top button) > click on **set up a workflow yourself** > replace the current content by the **actions.yaml** content > click on **Start commit** > click on **Commit new file**.
    - Step 3:
        - Since the previous step created a new file "main.yaml" within the ".github/workflows" directory, this action will immediately trigger the DAST scanning against the target web server.
    
From this moment, any modification (add/del/change) on main repo will trigger the action to scan the target web server :-)

## Next stage and ideas
1. Thus far the Web Application Firewall is on **mode "detection"**, which means no blocks are expected (even the web app under massive attack).

2. So now turn the Web Application Firewall to **mode "prevention"** and lets see how the results ;-)

3. Instead of running both scans simultaneously, you can wait the scan-1 completion (without issues) to initiate the scan-2. In a real world it would be similar like: "Run the tests and in case of no issues, then the approver will allow the code release into production. J

## Cleanup
1. Azure Platform
    - Option 1:
        - extract the Azure CLI commands within "destroy.ps1" and execute as you prefer
    - Option 2:
        - download the script "destroy.ps1" and run within a powershell. I.e.: .\destroy.ps1

2. GitHub Repository
    - Up to you decides delete the repo or just delete the ".github/workflows" directory. Any of them will disable the scans.

## Final considerations
As I mentioned early, it´s a pretty basic idea how to initiate on DevSecOps and integrate CI/CD pipelines with a minimum security embedded. I hope you enjoyed !!! :+1:
