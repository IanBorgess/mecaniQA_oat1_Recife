output "api_endpoint" {
  description = "API endpoint URL"
  value       = "http://localhost:${var.api_port}"
}

output "mysql_endpoint" {
  description = "MySQL connection endpoint"
  value       = "localhost:${var.mysql_port}"
}

output "redis_endpoint" {
  description = "Redis connection endpoint"
  value       = "localhost:${var.redis_port}"
}

output "api_container_id" {
  description = "Java API container ID"
  value       = docker_container.api.id
}

output "mysql_container_id" {
  description = "MySQL container ID"
  value       = docker_container.mysql.id
}

output "redis_container_id" {
  description = "Redis container ID"
  value       = docker_container.redis.id
}

output "network_id" {
  description = "Docker network ID"
  value       = docker_network.app_network.id
}
