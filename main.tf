terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "3.113.0"
    }
  }
}

provider "azurerm" {
  features {}
}

data "azurerm_image" "packerimage" {
  name                = "myPackerImage"
  resource_group_name = var.resource_group_name
}

output "image_id" {
  value = data.azurerm_image.packerimage.id
}

resource "azurerm_virtual_network" "my_vnet" {
  name                = "my-vnet"
  address_space       = ["10.0.0.0/16"]
  location            = var.location
  resource_group_name = var.resource_group_name
}

resource "azurerm_subnet" "my_subnet" {
  name                 = "my-subnet"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.my_vnet.name
  address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_network_security_group" "my_nsg" {
  name                = "my-nsg"
  location            = var.location
  resource_group_name = var.resource_group_name
}

resource "azurerm_network_security_rule" "inbound_rule" {
  name                        = "my-nsg-rule-inbound"
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "80"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = var.resource_group_name
  network_security_group_name = azurerm_network_security_group.my_nsg.name
}

resource "azurerm_network_security_rule" "outbound_rule" {
  name                        = "my-nsg-rule-outbound"
  priority                    = 100
  direction                   = "Outbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "80"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = var.resource_group_name
  network_security_group_name = azurerm_network_security_group.my_nsg.name
}

resource "azurerm_network_interface" "my_nic" {
  count               = var.vm_count
  name                = "my-nic-${count.index}"
  location            = var.location
  resource_group_name = var.resource_group_name

  ip_configuration {
    name                          = "my-nic-ipconfig"
    subnet_id                     = azurerm_subnet.my_subnet.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_public_ip" "my_public_ip" {
  name                = "my-public-ip"
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = "Dynamic"
}

resource "azurerm_lb" "my_lb" {
  name                = "my-lb"
  location            = var.location
  resource_group_name = var.resource_group_name

  frontend_ip_configuration {
    name                 = "my-lb-frontend"
    public_ip_address_id = azurerm_public_ip.my_public_ip.id
  }
}

resource "azurerm_lb_backend_address_pool" "my_lb_backend_pool" {
  loadbalancer_id = azurerm_lb.my_lb.id
  name            = "my-lb-backend-pool"
}

resource "azurerm_lb_probe" "my_lb_probe" {
  loadbalancer_id = azurerm_lb.my_lb.id
  name            = "my-lb-probe"
  protocol        = "Tcp"
  port            = 80
}

resource "azurerm_availability_set" "my_availability_set" {
  name                = "my-availability-set"
  location            = var.location
  resource_group_name = var.resource_group_name
}

resource "azurerm_virtual_machine" "my_vm" {
  count                 = var.vm_count
  name                  = "VM-${count.index}"
  location              = var.location
  resource_group_name   = var.resource_group_name
  availability_set_id   = azurerm_availability_set.my_availability_set.id
  network_interface_ids = [azurerm_network_interface.my_nic[count.index].id]
  vm_size               = "Standard_DS1_v2"

  storage_image_reference {
    id = data.azurerm_image.packerimage.id
  }

  storage_os_disk {
    name              = "VMOSDisk-${count.index}"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  os_profile {
    computer_name  = "VM-${count.index}"
    admin_username = "azureuser"
    admin_password = "UdacityProject1234!"
  }

  os_profile_linux_config {
    disable_password_authentication = false
  }

  tags = {
    project_name = "udacity"
  }
}
