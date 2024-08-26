provider "azurerm" {
    features {
      
    }
}

resource "azurerm_resource_group" "vulnlabavchowdhury" {
    name = "vulnlabavchowdhury"
    location = "West US"
}

resource "azurerm_virtual_network" "vullabnetwork" {
    name = "vulnlabnetwork"
    address_space = ["10.0.0.0/16"]
    location = azurerm_resource_group.vulnlabavchowdhury.location
    resource_group_name = azurerm_resource_group.vulnlabavchowdhury.name
}

resource "azurerm_subnet" "vulnlabsubnet" {
    name = "vulnlabsubnet1"
    resource_group_name = azurerm_resource_group.vulnlabavchowdhury.name
    virtual_network_name = azurerm_virtual_network.vullabnetwork.name
    address_prefixes = ["10.0.2.0/24"]
}

resource "azurerm_public_ip" "vulnlabpublicip" {
    name = "vulnlabpublicip"
    resource_group_name = azurerm_resource_group.vulnlabavchowdhury.name
    location = azurerm_resource_group.vulnlabavchowdhury.location
    allocation_method = "Static"
}

resource "azurerm_network_interface" "vulnlabnic" {
    name = "vulnlannic"
    location = azurerm_resource_group.vulnlabavchowdhury.location
    resource_group_name = azurerm_resource_group.vulnlabavchowdhury.name
    ip_configuration {
      name = "vulnlabprivateip"
      subnet_id = azurerm_subnet.vulnlabsubnet.id
      private_ip_address_allocation = "Dynamic"
      public_ip_address_id = azurerm_public_ip.vulnlabpublicip.id
    }
  
}

resource "azurerm_network_security_group" "vulnlabnsg" {
    name = "vulnlabnsg"
    location = azurerm_resource_group.vulnlabavchowdhury.location
    resource_group_name = azurerm_resource_group.vulnlabavchowdhury.name

    security_rule {
        name                       = "RDP"
        priority                   = 1000
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "*"
        source_port_range          = "*"
        destination_port_range     = "3389"
        source_address_prefix      = "<YOUR-PUBLIC-IP>/32"
        destination_address_prefix = "*"
    }
  
}

resource "azurerm_network_interface_security_group_association" "vulnlabnsgassociation" {
    network_interface_id = azurerm_network_interface.vulnlabnic.id
    network_security_group_id = azurerm_network_security_group.vulnlabnsg.id

} 

resource "azurerm_windows_virtual_machine" "vulnlabwinvm" {
    name = "vulnlabwinvm"
    resource_group_name = azurerm_resource_group.vulnlabavchowdhury.name
    location = azurerm_resource_group.vulnlabavchowdhury.location
    size = "Standard_D4s_v3"
    admin_username = "<REF TO KEY VAULT>"
    admin_password = "<REF TO KEY VAULT>"
    network_interface_ids = [
        azurerm_network_interface.vulnlabnic.id
    ]
    depends_on = [ 
        azurerm_network_interface_security_group_association.vulnlabnsgassociation 
    ]
    os_disk {
      caching = "ReadWrite"
      storage_account_type = "Standard_LRS"
    }
    source_image_reference {
      publisher="MicrosoftWindowsDesktop"
      offer="windows-11"
      sku="win11-21h2-avd"
      version = "latest"
    }
  
}