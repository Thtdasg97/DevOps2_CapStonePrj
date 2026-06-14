terraform {
  required_providers {
    digitalocean = {
      source  = "digitalocean/digitalocean"
      version = "~> 2.40"   # pin version để tránh breaking changes
    }
  }
  required_version = ">= 1.5.0"
}

# ── Provider ──────────────────────────────────────────────────────
provider "digitalocean" {
  token = var.do_token   # đọc từ terraform.tfvars, không hardcode
}

# ── SSH Key (tham chiếu key đã đăng ký trên DigitalOcean) ─────────
data "digitalocean_ssh_key" "capstone_key" {
  name = var.ssh_key_name   # đọc từ variable, không hardcode
}

# ── Droplet ───────────────────────────────────────────────────────
resource "digitalocean_droplet" "capstone_vps" {
  name   = var.droplet_name
  region = var.droplet_region
  size   = var.droplet_size
  image  = var.droplet_image

  ssh_keys = [data.digitalocean_ssh_key.capstone_key.id]

  tags = ["capstone", "devops"]
}

# ── Firewall ──────────────────────────────────────────────────────
resource "digitalocean_firewall" "capstone_firewall" {
  name = "${var.droplet_name}-firewall"

  droplet_ids = [digitalocean_droplet.capstone_vps.id]

  # ── Inbound rules ─────────────────────────────────────────────
  inbound_rule {
    protocol         = "tcp"
    port_range       = "22"
    source_addresses = ["0.0.0.0/0", "::/0"]   # SSH
  }
  inbound_rule {
    protocol         = "tcp"
    port_range       = "80"
    source_addresses = ["0.0.0.0/0", "::/0"]   # HTTP
  }
  inbound_rule {
    protocol         = "tcp"
    port_range       = "443"
    source_addresses = ["0.0.0.0/0", "::/0"]   # HTTPS
  }
  inbound_rule {
    protocol         = "tcp"
    port_range       = "3000"
    source_addresses = ["0.0.0.0/0", "::/0"]   # Frontend
  }
  inbound_rule {
    protocol         = "tcp"
    port_range       = "8000"
    source_addresses = ["0.0.0.0/0", "::/0"]   # Backend API
  }
  inbound_rule {
    protocol         = "tcp"
    port_range       = "8080"
    source_addresses = ["0.0.0.0/0", "::/0"]   # Jenkins
  }
  inbound_rule {
    protocol         = "tcp"
    port_range       = "9090"
    source_addresses = ["0.0.0.0/0", "::/0"]   # Prometheus
  }
  inbound_rule {
    protocol         = "tcp"
    port_range       = "3001"
    source_addresses = ["0.0.0.0/0", "::/0"]   # Grafana
  }

  # ── Outbound rules — cho phép tất cả ─────────────────────────
  outbound_rule {
    protocol              = "tcp"
    port_range            = "1-65535"
    destination_addresses = ["0.0.0.0/0", "::/0"]
  }
  outbound_rule {
    protocol              = "udp"
    port_range            = "1-65535"
    destination_addresses = ["0.0.0.0/0", "::/0"]
  }
  outbound_rule {
    protocol              = "icmp"
    destination_addresses = ["0.0.0.0/0", "::/0"]
  }
}