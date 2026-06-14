output "droplet_ip" {
  description = "Public IP address của VPS vừa tạo"
  value       = digitalocean_droplet.capstone_vps.ipv4_address
}

output "droplet_id" {
  description = "ID của Droplet trên DigitalOcean"
  value       = digitalocean_droplet.capstone_vps.id
}

output "droplet_name" {
  description = "Tên Droplet"
  value       = digitalocean_droplet.capstone_vps.name
}

output "ssh_command" {
  description = "Lệnh SSH để kết nối vào VPS"
  value       = "ssh -i ~/.ssh/github_actions_deploy root@${digitalocean_droplet.capstone_vps.ipv4_address}"
}