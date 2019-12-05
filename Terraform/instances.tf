resource "google_compute_network" "ansible_network" {
  name                    = "ansible-vpc"
  auto_create_subnetworks = true
}

resource "google_compute_firewall" "allow_incoming" {
  name    = "allow-ssh-http"
  network = google_compute_network.ansible_network.name

  allow {
    protocol = "icmp"
  }

  allow {
    protocol = "tcp"
    ports    = ["80", "22"]
  }

  source_ranges = ["0.0.0.0/0"]
}

resource "google_compute_address" "static" {
  count = 3
  name  = "ipv4-address-i${count.index}"
}

resource "google_compute_instance" "nodes" {
  count = 3

  name         = "ansible-node-i${count.index}"
  machine_type = "n1-standard-1"

  boot_disk {
    initialize_params {
      image = "ubuntu-os-cloud/ubuntu-1804-lts"
    }
  }

  network_interface {
    network = google_compute_network.ansible_network.id
    access_config {
      nat_ip = google_compute_address.static[count.index].address
    }
  }

  metadata = {
    ssh-keys = "ubuntu:${var.public_ssh_key}"
  }
}
