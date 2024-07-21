terraform {

terraform {
  cloud {
    organization = "DMTIT"
    workspaces {
      name = "medusa"
    }
  }

variable "terraform_credentials" {
  type = string
}

credentials "app.terraform.io" {
  token = var.terraform_credentials
}



  required_providers {
    neon = {
      source = "terraform-community-providers/neon"
      version = "0.1.6"
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

variable "upstash_email" {
  type = string
}

variable "upstash_api_key" {
  type = string
}

variable "render_api_key" {
  type = string
}

variable "render_owner_id" {
  type = string
}

variable "neon_api_key" {
  type = string
}

provider "render" {
  api_key = var.render_api_key    // Uses env.RENDER_API_KEY, if not supplied
  owner_id = var.render_owner_id // Uses env.RENDER_EMAIL, if not supplied
}

provider "neon" {
    token = var.neon_api_key
}

provider "random" {}

provider "upstash" {
  email = var.upstash_email
  api_key  = var.upstash_api_key
}

## REDIS

resource "upstash_redis_database" "redis" {
  database_name = "Medusa 1"
  region = "eu-west-1"
  tls = "true"
}

output "redis_url_concat" {
  value = "redis://default:${upstash_redis_database.redis.password}${upstash_redis_database.redis.endpoint}:${upstash_redis_database.redis.port}"
  sensitive = true
}

## DATABASE

resource "neon_project" "db" {
  name = "medusa 2"
  region_id = "aws-eu-central-1"
}

resource "neon_endpoint" "db" {
  branch_id  = neon_project.db.branch.id
  project_id = neon_project.db.id
}

resource "neon_branch" "db" {
  parent_id  = neon_project.db.branch.id
  project_id = neon_project.db.id
  name       = "main"
}

resource "neon_role" "db" {
  branch_id  = neon_project.db.branch.id
  project_id = neon_project.db.id
  name       = "owner"
}

resource "neon_database" "db" {
  owner_name = neon_role.db.name
  branch_id  = neon_project.db.branch.id
  project_id = neon_project.db.id
  name       = "db"
}

### BACKEND DEPLOY

# resource "random_string" "JWT_SECRET" {
#   length  = 32
#   special = false
#   upper   = true
#   lower   = true
#   numeric  = true
# }

# resource "random_string" "COOKIE_SECRET" {
#   length  = 32
#   special = false
#   upper   = true
#   lower   = true
#   numeric  = true
# }

# output "random_string_value" {
#   value = random_string.JWT_SECRET.result
# }

# output "random_string_value2" {
#   value = random_string.COOKIE_SECRET.result
# }

# resource "render_web_service" "web" {
#   name               = "terraform-web-service"
#   plan               = "starter"
#   region             = "oregon"
#   start_command      = "npm start"
#   pre_deploy_command = "echo 'hello world'"

#   runtime_source = {
#     native_runtime = {
#       auto_deploy   = true
#       branch        = "main"
#       build_command = "npm install"
#       build_filter = {
#         paths         = ["src/**"]
#         ignored_paths = ["tests/**"]
#       }
#       repo_url = "https://github.com/render-examples/express-hello-world"
#       runtime  = "node"
#     }
#   }

#   disk = {
#     name       = "some-disk"
#     size_gb    = 1
#     mount_path = "/data"
#   }

#   env_vars = {
#     "JWT_SECRET" = { value = random_string.JWT_SECRET.result },
#     "COOKIE_SECRET" = { value = random_string.COOKIE_SECRET.result },
#   }
# #   secret_files = {
# #     "file1" = { content = "content1" },
# #     "file2" = { content = "content2" },
# #   }
# #   custom_domains = [
# #     { name : "terraform-provider-1.db.com" },
# #     { name : "terraform-provider-2.db.com" },
# #   ]

# #   notification_override = {
# #     preview_notifications_enabled = "false"
# #     notifications_to_send         = "failure"
# #   }
# }

