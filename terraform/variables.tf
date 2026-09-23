variable "app_name" {
  description = "Application name"
  type        = string
  default     = "my-corretto-app"
}

variable "api_port" {
  description = "API port mapping"
  type        = number
  default     = 8080
}

variable "mysql_port" {
  description = "MySQL port mapping"
  type        = number
  default     = 3306
}

variable "redis_port" {
  description = "Redis port mapping"
  type        = number
  default     = 6379
}

variable "mysql_root_password" {
  description = "MySQL root password"
  type        = string
  sensitive   = true
  default     = "rootpassword"
}

variable "mysql_database" {
  description = "MySQL database name"
  type        = string
  default     = "myapp"
}

variable "mysql_user" {
  description = "MySQL user"
  type        = string
  default     = "appuser"
}

variable "mysql_password" {
  description = "MySQL user password"
  type        = string
  sensitive   = true
  default     = "apppassword"
}

variable "api_image" {
  description = "API Docker image"
  type        = string
  default     = "my-corretto-app:optimized"
}

variable "mysql_image" {
  description = "MySQL Docker image"
  type        = string
  default     = "mysql:8.0"
}

variable "redis_image" {
  description = "Redis Docker image"
  type        = string
  default     = "redis:7-alpine"
}
