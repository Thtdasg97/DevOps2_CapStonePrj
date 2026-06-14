variable "do_token" {
  description = "DigitalOcean API token"
  type        = string
  sensitive   = true   # ẩn giá trị khỏi logs khi plan/apply
}

variable "droplet_name" {
  description = "Tên Droplet"
  type        = string
  default     = "capstone-vps"
}

variable "droplet_region" {
  description = "DigitalOcean region"
  type        = string
  default     = "sgp1"   # Singapore — gần nhất với Việt Nam
}

variable "droplet_size" {
  description = "Droplet size slug"
  type        = string
  default     = "s-2vcpu-4gb"   # 2 vCPU, 4GB RAM
}

variable "droplet_image" {
  description = "OS image cho Droplet"
  type        = string
  default     = "ubuntu-22-04-x64"
}

variable "ssh_key_name" {
  description = "Tên SSH key đã đăng ký trên DigitalOcean"
  type        = string
  default     = "github-actions-deploy"
}