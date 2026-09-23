# Network for service communication
resource "docker_network" "app_network" {
  name   = "app-network"
  driver = "bridge"
}

# Volumes for data persistence
resource "docker_volume" "mysql_data" {
  name = "mysql-data"
}

resource "docker_volume" "redis_data" {
  name = "redis-data"
}

# MySQL Container
resource "docker_container" "mysql" {
  name  = "mysql"
  image = var.mysql_image

  ports {
    internal = 3306
    external = var.mysql_port
  }

  env = [
    "MYSQL_ROOT_PASSWORD=${var.mysql_root_password}",
    "MYSQL_DATABASE=${var.mysql_database}",
    "MYSQL_USER=${var.mysql_user}",
    "MYSQL_PASSWORD=${var.mysql_password}"
  ]

  volumes {
    volume_name    = docker_volume.mysql_data.name
    container_path = "/var/lib/mysql"
  }

  networks_advanced {
    name = docker_network.app_network.name
  }

  healthcheck {
    test     = ["CMD", "mysqladmin", "ping", "-h", "localhost"]
    interval = "5s"
    timeout  = "3s"
    retries  = 10
  }

  restart = "unless-stopped"
}

# Redis Container
resource "docker_container" "redis" {
  name  = "redis"
  image = var.redis_image

  ports {
    internal = 6379
    external = var.redis_port
  }

  volumes {
    volume_name    = docker_volume.redis_data.name
    container_path = "/data"
  }

  networks_advanced {
    name = docker_network.app_network.name
  }

  healthcheck {
    test     = ["CMD", "redis-cli", "ping"]
    interval = "5s"
    timeout  = "3s"
    retries  = 10
  }

  restart = "unless-stopped"

  depends_on = [docker_network.app_network]
}

# Java API Container
resource "docker_container" "api" {
  name  = "java-api"
  image = var.api_image

  ports {
    internal = 8080
    external = var.api_port
  }

  env = [
    "SPRING_DATASOURCE_URL=jdbc:mysql://mysql:3306/${var.mysql_database}",
    "SPRING_DATASOURCE_USERNAME=${var.mysql_user}",
    "SPRING_DATASOURCE_PASSWORD=${var.mysql_password}",
    "SPRING_REDIS_HOST=redis",
    "SPRING_REDIS_PORT=6379"
  ]

  networks_advanced {
    name = docker_network.app_network.name
  }

  restart = "unless-stopped"

  depends_on = [
    docker_container.mysql,
    docker_container.redis
  ]
}
