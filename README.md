# Azure Infrastructure Operations Project: Deploying a scalable IaaS web server in Azure

### Introduction
For this project, you will write a Packer template and a Terraform template to deploy a customizable, scalable web server in Azure.

### Getting Started
1. Clone this repository

2. Create your infrastructure as code

3. Update this README to reflect how someone would use your code.

### Dependencies
1. Create an [Azure Account](https://portal.azure.com) 
2. Install the [Azure command line interface](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli?view=azure-cli-latest)
3. Install [Packer](https://www.packer.io/downloads)
4. Install [Terraform](https://www.terraform.io/downloads.html)

### Instructions
#### Step 1: Clone the repo to your local
#### Step 2: Building the Custom VM Image with Packer
 - Ensure you have created a Service Principal (SPN) in Azure and have the following details:
   - client_id: Application (client) ID
   - client_secret: Client secret
   - subscription_id: Azure Subscription ID
- Grant the Service Principal Access to the Subscription:
  - Assign the Contributor role to the Service Principal at the subscription level:
    ```sh
    az role assignment create --assignee "{assignee}" --role "{roleNameOrId}" --scope "/subscriptions/{subscriptionId}"
    ``` 
- Modify the Packer Template:
  - Open the server.json file and update the required fields with your own SPN details
- Build the image:
  - Run the following command to build the VM image with Packer:
    ```
    packer build server.json
    ``` 
### Step 3: Deploying the Infrastructure with Terrafor
  - Initialize Terraform:
    - Navigate to the Terraform directory and initialize Terraform:
      ```terraform
      terraform init
      ```
    - Customize the vars.tf file:
    - Open the vars.tf file and modify the variables to suit your needs. Key variables include resource_group_name, location, vm_count, admin_password and admin_username
  - Plan Terraform:
    ``` terraform
    terraform plan -out solution.plan
    ```
  - Apply the Terraform Configuration:
    ```terraform
    terraform apply
    ```
## Customization
### Customizing the Packer Template
- Base Image: Change the source_image_reference in the builders section of server.json to use a different base image.
- Resource Group: Update the resource_group_name variable in the variables section.
- Software Installation: Modify the provisioners section to include additional software installations or configurations as needed.
### Customizing the Terraform Template
- Variables: Edit the vars.tf file to change default values for:
  - resource_group_name: The name of the Azure Resource Group.
  - location: The Azure region for the resources.
  - vm_count: The number of VM instances to create.

### Output

Upon successful execution of the Packer and Terraform templates, you will have:

 - A custom VM image stored in Azure.
 - A set of infrastructure resources deployed in Azure, including:
   - A Virtual Network (VNet).
   - Network Security Groups (NSGs).
   - A Load Balancer.
   - One or more Virtual Machines (VMs) based on the custom image, all tagged with the project name.
   - Network interfaces on the same subnet, with subnet_id specified by assignment from the created azurerm_subnet.
 
These resources form a scalable web server infrastructure that you can further customize and expand according to your requirements.

By following these instructions, you should be able to set up and deploy a scalable web server infrastructure in Azure with ease. For any issues or further customization, refer to the official documentation of [Packer](https://www.packer.io/) and [Terraform](https://www.terraform.io/).
