data "yandex_compute_image" "ubuntu_image" {
  family = "ubuntu-2204-lts"
}

resource "yandex_compute_instance" "vpn" {        
    name        = "vpn"  
    zone        = "ru-central1-a"

    resources {
        cores   = 2                                            
        memory  = 2                                           
    }

    boot_disk {
        initialize_params {
            image_id = data.yandex_compute_image.ubuntu_image.id
            size     = 20
        }
    }

    network_interface {
        subnet_id   = "e9b9iosa2umis05ld5gu"    
        nat         = true
    }

    scheduling_policy {
      preemptible = true                                    
    }

    metadata = {
        ssh-keys = "ubuntu:${file("~/.ssh/id_rsa.pub")}"     
    }
}

data "template_file" "inventory" {
    template = file("./_templates/inventory.tpl")
  
    vars = {
        user = "ubuntu"
        host = join("", [yandex_compute_instance.vpn.name, " ansible_host=", yandex_compute_instance.vpn.network_interface.0.nat_ip_address])
    }
}

resource "local_file" "save_inventory" {
   content  = data.template_file.inventory.rendered
   filename = "../ansible/inventories/yandexcloud/hosts"
}