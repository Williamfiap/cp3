resource "azurerm_resource_group" "rg" {
    name     = "rg-staticsite-lb-multicloud-tf-williamiaciac"
    location = "brazilsouth"
}

resource "azurerm_virtual_network" "vnet10" {
  name                = "vnet10"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}

resource "azurerm_virtual_network" "vnet20" {
  name                = "vnet20"
  address_space       = ["10.1.0.0/16"]
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}


resource "azurerm_subnet" "subnet1a_vnet10" {
    name                 = "subnet1a"
    resource_group_name  = azurerm_resource_group.rg.name
    virtual_network_name = azurerm_virtual_network.vnet10.name
    address_prefixes     = ["10.0.5.0/24"]
}

resource "azurerm_subnet" "subnet1c_vnet10" {
    name                 = "subnet1a"
    resource_group_name  = azurerm_resource_group.rg.name
    virtual_network_name = azurerm_virtual_network.vnet10.name
    address_prefixes     = ["10.0.6.0/24"]
}

resource "azurerm_subnet" "subnet1a_vnet20" {
    name                 = "subnet1a"
    resource_group_name  = azurerm_resource_group.rg.name
    virtual_network_name = azurerm_virtual_network.vnet20.name
    address_prefixes     = ["10.1.5.0/24"]
}

resource "azurerm_subnet" "subnet1c_vnet20" {
    name                 = "subnet1c"
    resource_group_name  = azurerm_resource_group.rg.name
    virtual_network_name = azurerm_virtual_network.vnet20.name
    address_prefixes     = ["10.1.6.0/24"]
}

resource "azurerm_subnet_network_security_group_association" "nsgsubnet1a_vnet10" {
    subnet_id                 = azurerm_subnet.subnet1a_vnet10.id
    network_security_group_id = azurerm_network_security_group.nsgvm.id
}

resource "azurerm_subnet_network_security_group_association" "nsgsubnet1c_vnet10" {
    subnet_id                 = azurerm_subnet.subnet1c_vnet10.id
    network_security_group_id = azurerm_network_security_group.nsgvm.id
}

resource "azurerm_subnet_network_security_group_association" "nsgsubnet1a_vnet20" {
    subnet_id                 = azurerm_subnet.subnet1a_vnet20.id
    network_security_group_id = azurerm_network_security_group.nsgvm.id  
}

resource "azurerm_subnet_network_security_group_association" "nsgsubnet1c_vnet20" {
    subnet_id                 = azurerm_subnet.subnet1c_vnet20.id
    network_security_group_id = azurerm_network_security_group.nsgvm.id
}

resource "azurerm_virtual_network_peering" "vnet10-to-vnet20" {
  name                      = "vnet10-to-vnet20"
  resource_group_name       = azurerm_resource_group.rg.name
  virtual_network_name      = azurerm_virtual_network.vnet10.name
  remote_virtual_network_id = azurerm_virtual_network.vnet20.id
  allow_virtual_network_access = true
  allow_forwarded_traffic      = true
  allow_gateway_transit        = false
  use_remote_gateways          = false
}

resource "azurerm_virtual_network_peering" "vnet20-to-vnet10" {
  name                      = "vnet20-to-vnet10"
  resource_group_name       = azurerm_resource_group.rg.name
  virtual_network_name      = azurerm_virtual_network.vnet20.name
  remote_virtual_network_id = azurerm_virtual_network.vnet10.id
  allow_virtual_network_access = true
  allow_forwarded_traffic      = true
  allow_gateway_transit        = false
  use_remote_gateways          = false
}



resource "azurerm_network_security_group" "nsgvm" {
    name                = "nsgvm"
    location            = azurerm_resource_group.rg.location
    resource_group_name = azurerm_resource_group.rg.name
    security_rule {
        name                       = "HTTP"
        priority                   = 1001
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "80"
        source_address_prefix      = "*"
        destination_address_prefix = "*"
    }
    security_rule {
        name                       = "FTP"
        priority                   = 1011
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "22"
        source_address_prefix      = "*"
        destination_address_prefix = "*"
    }
}









#-------------------------------------------------------------------------------#
/*
resource "azurerm_network_interface" "vm01" {
    name                = "vm01"
    location            = azurerm_resource_group.rg.location
    resource_group_name = azurerm_resource_group.rg.name
    ip_configuration {
        name                          = "vm01"
        subnet_id                     = azurerm_subnet.subnet1a.id
        private_ip_address_allocation = "Dynamic"
    }
}

resource "azurerm_network_interface" "vm02" {
    name                = "vm02"
    location            = azurerm_resource_group.rg.location
    resource_group_name = azurerm_resource_group.rg.name
    ip_configuration {
        name                          = "vm02"
        subnet_id                     = azurerm_subnet.subnet1a.id
        private_ip_address_allocation = "Dynamic"
    }
}

resource "azurerm_network_interface" "vm03" {
    name                = "vm03"
    location            = azurerm_resource_group.rg.location
    resource_group_name = azurerm_resource_group.rg.name
    ip_configuration {
        name                          = "vm03"
        subnet_id                     = azurerm_subnet.subnet1c.id
        private_ip_address_allocation = "Dynamic"
    }
}

# 123

resource "azurerm_network_interface" "vm04" {
    name                = "vm04"
    location            = azurerm_resource_group.rg.location
    resource_group_name = azurerm_resource_group.rg.name
    ip_configuration {
        name                          = "vm04"
        subnet_id                     = azurerm_subnet.subnet1c.id
        private_ip_address_allocation = "Dynamic"
    }
}

resource "azurerm_availability_set" "asvm" {
    name                = "asvm"
    location            = azurerm_resource_group.rg.location
    resource_group_name = azurerm_resource_group.rg.name
}

resource "azurerm_virtual_machine" "vm01" {
    name                             = "vm01"
    location                         = azurerm_resource_group.rg.location
    resource_group_name              = azurerm_resource_group.rg.name
    network_interface_ids            = [azurerm_network_interface.vm01.id]
    availability_set_id              = azurerm_availability_set.asvm.id
    vm_size                          = "Standard_DS1_v2"
    delete_os_disk_on_termination    = true
    delete_data_disks_on_termination = true
    storage_image_reference {
        publisher = "Canonical"
        offer     = "0001-com-ubuntu-server-jammy"
        sku       = "22_04-lts"
        version   = "latest"
    }
    storage_os_disk {
        name              = "vm01"
        caching           = "ReadWrite"
        create_option     = "FromImage"
        managed_disk_type = "Standard_LRS"
    }
    os_profile {
        computer_name  = "vm01"
        admin_username = "vmuser"
        admin_password = "Password1234!"
        custom_data    = <<CUSTOM_DATA
#!/bin/bash
sudo apt update
sudo apt install apache2 -y
echo "staticsite-lb-multi-cloud - Azure - instance01" > /var/www/html/index.html
CUSTOM_DATA
    }
    os_profile_linux_config {
        disable_password_authentication = false
    }
}

resource "azurerm_virtual_machine" "vm02" {
    name                             = "vm02"
    location                         = azurerm_resource_group.rg.location
    resource_group_name              = azurerm_resource_group.rg.name
    network_interface_ids            = [azurerm_network_interface.vm02.id]
    availability_set_id              = azurerm_availability_set.asvm.id
    vm_size                          = "Standard_DS1_v2"
    delete_os_disk_on_termination    = true
    delete_data_disks_on_termination = true
    storage_image_reference {
        publisher = "Canonical"
        offer     = "0001-com-ubuntu-server-jammy"
        sku       = "22_04-lts"
        version   = "latest"
    }
    storage_os_disk {
        name              = "vm02"
        caching           = "ReadWrite"
        create_option     = "FromImage"
        managed_disk_type = "Standard_LRS"
    }
    os_profile {
        computer_name  = "vm02"
        admin_username = "vmuser"
        admin_password = "Password1234!"
        custom_data    = <<CUSTOM_DATA
#!/bin/bash
sudo apt update
sudo apt install apache2 -y
echo "staticsite-lb-multi-cloud - Azure - instance02" > /var/www/html/index.html
CUSTOM_DATA
    }
    os_profile_linux_config {
        disable_password_authentication = false
    }
}

resource "azurerm_virtual_machine" "vm03" {
    name                             = "vm03"
    location                         = azurerm_resource_group.rg.location
    resource_group_name              = azurerm_resource_group.rg.name
    network_interface_ids            = [azurerm_network_interface.vm03.id]
    availability_set_id              = azurerm_availability_set.asvm.id
    vm_size                          = "Standard_DS1_v2"
    delete_os_disk_on_termination    = true
    delete_data_disks_on_termination = true
    storage_image_reference {
        publisher = "Canonical"
        offer     = "0001-com-ubuntu-server-jammy"
        sku       = "22_04-lts"
        version   = "latest"
    }
    storage_os_disk {
        name              = "vm03"
        caching           = "ReadWrite"
        create_option     = "FromImage"
        managed_disk_type = "Standard_LRS"
    }
    os_profile {
        computer_name  = "vm03"
        admin_username = "vmuser"
        admin_password = "Password1234!"
        custom_data    = <<CUSTOM_DATA
#!/bin/bash
sudo apt update
sudo apt install apache2 -y
echo "staticsite-lb-multi-cloud - Azure - instance03" > /var/www/html/index.html
CUSTOM_DATA
    }
    os_profile_linux_config {
        disable_password_authentication = false
    }
}

resource "azurerm_virtual_machine" "vm04" {
    name                             = "vm04"
    location                         = azurerm_resource_group.rg.location
    resource_group_name              = azurerm_resource_group.rg.name
    network_interface_ids            = [azurerm_network_interface.vm04.id]
    availability_set_id              = azurerm_availability_set.asvm.id
    vm_size                          = "Standard_DS1_v2"
    delete_os_disk_on_termination    = true
    delete_data_disks_on_termination = true
    storage_image_reference {
        publisher = "Canonical"
        offer     = "0001-com-ubuntu-server-jammy"
        sku       = "22_04-lts"
        version   = "latest"
    }
    storage_os_disk {
        name              = "vm04"
        caching           = "ReadWrite"
        create_option     = "FromImage"
        managed_disk_type = "Standard_LRS"
    }
    os_profile {
        computer_name  = "vm04"
        admin_username = "vmuser"
        admin_password = "Password1234!"
        custom_data    = <<CUSTOM_DATA
#!/bin/bash
sudo apt update
sudo apt install apache2 -y
echo "staticsite-lb-multi-cloud - Azure - instance04" > /var/www/html/index.html
CUSTOM_DATA
    }
    os_profile_linux_config {
        disable_password_authentication = false
    }
}

resource "azurerm_public_ip" "lb" {
    name                = "lb"
    location            = azurerm_resource_group.rg.location
    resource_group_name = azurerm_resource_group.rg.name
    allocation_method   = "Static"
    domain_name_label   = "staticsitelbtfwilliamiac"
}

resource "azurerm_lb" "lb" {
    name                = "lb"
    location            = azurerm_resource_group.rg.location
    resource_group_name = azurerm_resource_group.rg.name
    frontend_ip_configuration {
        name                 = "lb"
        public_ip_address_id = azurerm_public_ip.lb.id
    }
}

resource "azurerm_lb_backend_address_pool" "lb" {
    name            = "lb"
    loadbalancer_id = azurerm_lb.lb.id
}

resource "azurerm_lb_rule" "lb" {
    name                           = "HTTP"
    loadbalancer_id                = azurerm_lb.lb.id
    protocol                       = "Tcp"
    frontend_port                  = 80
    backend_port                   = 80
    frontend_ip_configuration_name = "lb"
    backend_address_pool_ids       = [azurerm_lb_backend_address_pool.lb.id]
    load_distribution              = "Default"
}

resource "azurerm_network_interface_backend_address_pool_association" "vm01" {
    ip_configuration_name   = "vm01"
    network_interface_id    = azurerm_network_interface.vm01.id
    backend_address_pool_id = azurerm_lb_backend_address_pool.lb.id
}

resource "azurerm_network_interface_backend_address_pool_association" "vm02" {
    ip_configuration_name   = "vm02"
    network_interface_id    = azurerm_network_interface.vm02.id
    backend_address_pool_id = azurerm_lb_backend_address_pool.lb.id
}

resource "azurerm_network_interface_backend_address_pool_association" "vm03" {
    ip_configuration_name   = "vm03"
    network_interface_id    = azurerm_network_interface.vm03.id
    backend_address_pool_id = azurerm_lb_backend_address_pool.lb.id
}

resource "azurerm_network_interface_backend_address_pool_association" "vm04" {
    ip_configuration_name   = "vm04"
    network_interface_id    = azurerm_network_interface.vm04.id
    backend_address_pool_id = azurerm_lb_backend_address_pool.lb.id
}

output "lb_fqdn" {
    value = azurerm_public_ip.lb.fqdn
}

*/