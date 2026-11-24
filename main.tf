terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 4.2.0"
    }
  }
}

provider "docker" {}

resource "docker_image" "nginx" {
  name         = "nginx:latest"
  keep_locally = false
}

resource "docker_container" "nginx_1" {
  image = docker_image.nginx.image_id
  name  = "my-nginx-1"
  ports {
    internal = 80
    external = 8080
  }

  networks_advanced {
    name = docker_network.app_net.name
  }

  volumes {
    volume_name    = docker_volume.nginx_data.name
    container_path = "/usr/share/nginx/html/data"
  }
}

resource "docker_container" "nginx_2" {
  image = docker_image.nginx.image_id
  name  = "my-nginx-2"
  ports {
    internal = 80
    external = 8082
  }
  networks_advanced {
    name = docker_network.app_net.name
  }

  volumes {
    volume_name    = docker_volume.nginx_data.name
    container_path = "/usr/share/nginx/html/data"
  }
}

resource "docker_network" "app_net" {
  name = "usf-app-net"
}

resource "docker_volume" "nginx_data" {
  name = "nginx-data"
}

# Flask + Redis

resource "docker_image" "redis" {
  name         = "redis:7-alpine"
  keep_locally = true
}

# named volume
resource "docker_volume" "redis_data" {
  name = "redis-data"
}

resource "docker_container" "redis" {
  name  = "redis"
  image = docker_image.redis.image_id

  # append-only persistence
  command = [
    "redis-server",
    "--appendonly",
    "yes",
    "--appendfsync",
    "always"
  ]

  volumes {
    volume_name    = docker_volume.redis_data.name
    container_path = "/data"
  }

  networks_advanced {
    name = docker_network.app_net.name
  }

  restart = "unless-stopped"
}

resource "docker_image" "flask" {
  name         = "flask-redis-app:latest"
  keep_locally = true

  build {
    context = "${path.module}/flask-app"
  }

  triggers = {
    app_files = sha1(join("", [
      for f in fileset("${path.module}/flask-app", "**") :
      filesha1("${path.module}/flask-app/${f}")
    ]))
  }
}

resource "docker_container" "flask" {
  name  = "flask-app"
  image = docker_image.flask.image_id

  env = [
    "REDIS_HOST=redis"
  ]

  ports {
    internal = 5000
    external = 5000
  }

  networks_advanced {
    name = docker_network.app_net.name
  }

  depends_on = [
    docker_container.redis
  ]

  restart = "unless-stopped"
}
