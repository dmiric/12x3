terraform {
  required_providers {
    neon = {
      source = "kislerdm/neon"
    }

    neosync = {
      source  = "nucleuscloud/neosync"
      version = "~> 0.1"
    }

    render = {
        source = "render-oss/render"
    }

    random = {
        source = "hashicorp/random"
    }

    upstash = {
        source = "upstash/upstash"
        version = "1.5.3"
    }
  }
}

provider "render" {
  api_key = var.render_api_key    // Uses env.RENDER_API_KEY, if not supplied
  owner_id = var.render_owner_id // Uses env.RENDER_EMAIL, if not supplied
}

provider "neon" {
  api_key = var.neon_api_key
}

provider "random" {}

provider "upstash" {
  email = var.upstash_email
  api_key = var.upstash_api_key
}

## REDIS
resource "upstash_redis_database" "redis" {
   database_name = "Medusa 1"
   region = "eu-west-1"
   tls = "true"
 }

## DATABASE
# https://registry.terraform.io/providers/kislerdm/neon/latest/docs/resources/project
resource "neon_project" "db" {
  name = "medusa 3"
  region_id = "aws-eu-central-1"
  branch {
    name          = "main"
    database_name = "medusa"
    role_name     = "owner"
  }
}

# grant project access to the user with the email foo@bar.qux
resource "neon_project_permission" "share" {
  project_id = neon_project.db.id
  grantee    = var.upstash_email
}


## BACKEND DEPLOY

resource "random_string" "JWT_SECRET" {
  length  = 32
  special = false
  upper   = true
  lower   = true
  numeric  = true
}

resource "random_string" "COOKIE_SECRET" {
  length  = 32
  special = false
  upper   = true
  lower   = true
  numeric  = true
}

output "random_string_value" {
  value = random_string.JWT_SECRET.result
}

output "random_string_value2" {
  value = random_string.COOKIE_SECRET.result
}

resource "render_web_service" "web" {
  name               = "terraform-web-service"
  plan               = "starter"
  region             = "oregon"
  start_command      = "npm start"
  pre_deploy_command = "echo 'hello world'"

  runtime_source = {
    native_runtime = {
      auto_deploy   = true
      branch        = "main"
      build_command = "npm install"
      build_filter = {
        paths         = ["src/**"]
        ignored_paths = ["tests/**"]
      }
      repo_url = "https://github.com/dmiric/12x3"
      runtime  = "node"
    }
  }

  disk = {
    name       = "some-disk"
    size_gb    = 1
    mount_path = "/data"
  }

  env_vars = {
    "JWT_SECRET" = { value = random_string.JWT_SECRET.result },
    "COOKIE_SECRET" = { value = random_string.COOKIE_SECRET.result },
    "REDIS_URL" = { value = "rediss://default:${upstash_redis_database.redis.password}@${upstash_redis_database.redis.endpoint}:${upstash_redis_database.redis.port}" }
    "DB_URL" = { value = neon_project.db.connection_uri }
    "DATABASE_TYPE" = { value= "postgres"}
  }
#   secret_files = {
#     "file1" = { content = "content1" },
#     "file2" = { content = "content2" },
#   }
#   custom_domains = [
#     { name : "terraform-provider-1.db.com" },
#     { name : "terraform-provider-2.db.com" },
#   ]

#   notification_override = {
#     preview_notifications_enabled = "false"
#     notifications_to_send         = "failure"
#   }
}

