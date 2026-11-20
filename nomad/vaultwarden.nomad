
job "vaultwarden" {
  datacenters = ["dc1"]
  type        = "service"

  group "vaultwarden" {
    count = 1

    network {
      port "http" {
        static = 8080
        to     = 80
      }
    }

    volume "vaultwarden-data" {
      type      = "host"
      source    = "vaultwarden-data"
      read_only = false
    }

    task "vaultwarden" {
      driver = "docker"

      config {
        image = "vaultwarden/server@sha256:4fe17f415f90087377d37c755e0ea3cf189dcc6794e49cdd2a9adbb4937d9e1f"
        ports = ["http"]
      }

      env {
        DOMAIN            = "https://vaultwarden.local"
        SIGNUPS_ALLOWED   = "false"
        INVITATIONS_ALLOWED = "false"
        ROCKET_ADDRESS    = "0.0.0.0"
        ROCKET_PORT       = "80"
        WEBSOCKET_ENABLED = "true"
        LOG_LEVEL         = "info"
      }


      template {
  data = <<-EOF
{{ with nomadVar "vaultwarden/admin" }}
ADMIN_TOKEN={{ .ADMIN_TOKEN }}
{{ end }}
EOF

  destination = "secrets/admin_token.env"
  env         = true
  change_mode = "restart"
}

      

      volume_mount {
        volume      = "vaultwarden-data"
        destination = "/data"
        read_only   = false
      }

      resources {
        cpu    = 300
        memory = 512
      }
    }
  }
}
