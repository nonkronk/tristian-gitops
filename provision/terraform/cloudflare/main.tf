terraform {

  required_providers {
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "4.3.0"
    }
    http = {
      source  = "hashicorp/http"
      version = "3.2.1"
    }
    sops = {
      source  = "carlpett/sops"
      version = "0.7.2"
    }
  }
}

data "sops_file" "cloudflare_secrets" {
  source_file = "secret.sops.yaml"
}

provider "cloudflare" {
  email   = data.sops_file.cloudflare_secrets.data["cloudflare_email"]
  api_key = data.sops_file.cloudflare_secrets.data["cloudflare_apikey"]
}

data "cloudflare_zones" "domain" {
  filter {
    name = data.sops_file.cloudflare_secrets.data["cloudflare_domain"]
  }
}

resource "cloudflare_zone_settings_override" "cloudflare_settings" {
  zone_id = lookup(data.cloudflare_zones.domain.zones[0], "id")
  settings {
    # /ssl-tls
    ssl = "full"
    # /ssl-tls/edge-certificates
    always_use_https         = "on"
    min_tls_version          = "1.0"
    opportunistic_encryption = "on"
    tls_1_3                  = "zrt"
    automatic_https_rewrites = "on"
    universal_ssl            = "on"
    # /firewall/settings
    browser_check  = "on"
    challenge_ttl  = 1800
    privacy_pass   = "on"
    security_level = "medium"
    # /speed/optimization
    brotli = "on"
    minify {
      css  = "on"
      js   = "on"
      html = "on"
    }
    rocket_loader = "off"
    # /caching/configuration
    always_online    = "off"
    development_mode = "off"
    # /network
    http3               = "on"
    zero_rtt            = "on"
    ipv6                = "on"
    websockets          = "on"
    opportunistic_onion = "on"
    pseudo_ipv4         = "off"
    ip_geolocation      = "on"
    # /content-protection
    email_obfuscation   = "on"
    server_side_exclude = "on"
    hotlink_protection  = "off"
    # /workers
    security_header {
      enabled = false
    }
  }
}

data "http" "ipv4" {
  url = "http://ipv4.icanhazip.com"
}

resource "cloudflare_record" "cname_home" {
  name    = data.sops_file.cloudflare_secrets.data["cname_home"]
  zone_id = lookup(data.cloudflare_zones.domain.zones[0], "id")
  value   = chomp(data.http.ipv4.response_body)
  proxied = true
  type    = "A"
  ttl     = 1
}

resource "cloudflare_record" "cname_oracle" {
  name    = data.sops_file.cloudflare_secrets.data["cname_oracle"]
  zone_id = lookup(data.cloudflare_zones.domain.zones[0], "id")
  value   = data.sops_file.cloudflare_secrets.data["oracle_ip"]
  proxied = true
  type    = "A"
  ttl     = 1
}

resource "cloudflare_record" "root" {
  name    = data.sops_file.cloudflare_secrets.data["cloudflare_domain"]
  zone_id = lookup(data.cloudflare_zones.domain.zones[0], "id")
  value   = data.sops_file.cloudflare_secrets.data["cname_home_domain"]
  proxied = true
  type    = "CNAME"
  ttl     = 1
}

resource "cloudflare_record" "vcs_subdomain" {
  name    = data.sops_file.cloudflare_secrets.data["vcs_subdomain"]
  zone_id = lookup(data.cloudflare_zones.domain.zones[0], "id")
  value   = data.sops_file.cloudflare_secrets.data["cname_home_domain"]
  proxied = true
  type    = "CNAME"
  ttl     = 1
}

resource "cloudflare_record" "hosting_subdomain" {
  name    = data.sops_file.cloudflare_secrets.data["hosting_subdomain"]
  zone_id = lookup(data.cloudflare_zones.domain.zones[0], "id")
  value   = data.sops_file.cloudflare_secrets.data["cname_home_domain"]
  proxied = true
  type    = "CNAME"
  ttl     = 1
}

resource "cloudflare_record" "short_subdomain" {
  name    = data.sops_file.cloudflare_secrets.data["short_subdomain"]
  zone_id = lookup(data.cloudflare_zones.domain.zones[0], "id")
  value   = data.sops_file.cloudflare_secrets.data["cname_home_domain"]
  proxied = true
  type    = "CNAME"
  ttl     = 1
}

resource "cloudflare_record" "oracle_pass_subdomain" {
  name    = data.sops_file.cloudflare_secrets.data["oracle_pass_subdomain"]
  zone_id = lookup(data.cloudflare_zones.domain.zones[0], "id")
  value   = data.sops_file.cloudflare_secrets.data["cname_oracle_domain"]
  proxied = true
  type    = "CNAME"
  ttl     = 1
}

resource "cloudflare_record" "oracle_gpt_subdomain" {
  name    = data.sops_file.cloudflare_secrets.data["oracle_gpt_subdomain"]
  zone_id = lookup(data.cloudflare_zones.domain.zones[0], "id")
  value   = data.sops_file.cloudflare_secrets.data["cname_oracle_domain"]
  proxied = true
  type    = "CNAME"
  ttl     = 1
}

resource "cloudflare_record" "oracle_helm_subdomain" {
  name    = data.sops_file.cloudflare_secrets.data["oracle_helm_subdomain"]
  zone_id = lookup(data.cloudflare_zones.domain.zones[0], "id")
  value   = data.sops_file.cloudflare_secrets.data["cname_oracle_domain"]
  proxied = true
  type    = "CNAME"
  ttl     = 1
}

resource "cloudflare_record" "oracle_auth_subdomain" {
  name    = data.sops_file.cloudflare_secrets.data["oracle_auth_subdomain"]
  zone_id = lookup(data.cloudflare_zones.domain.zones[0], "id")
  value   = data.sops_file.cloudflare_secrets.data["cname_oracle_domain"]
  proxied = true
  type    = "CNAME"
  ttl     = 1
}

resource "cloudflare_record" "oracle_storage_subdomain" {
  name    = data.sops_file.cloudflare_secrets.data["oracle_storage_subdomain"]
  zone_id = lookup(data.cloudflare_zones.domain.zones[0], "id")
  value   = data.sops_file.cloudflare_secrets.data["cname_oracle_domain"]
  proxied = true
  type    = "CNAME"
  ttl     = 1
}

resource "cloudflare_record" "oracle_jenkins_subdomain" {
  name    = data.sops_file.cloudflare_secrets.data["oracle_jenkins_subdomain"]
  zone_id = lookup(data.cloudflare_zones.domain.zones[0], "id")
  value   = data.sops_file.cloudflare_secrets.data["cname_oracle_domain"]
  proxied = true
  type    = "CNAME"
  ttl     = 1
}

resource "cloudflare_record" "oracle_dns_subdomain" {
  name    = data.sops_file.cloudflare_secrets.data["oracle_dns_subdomain"]
  zone_id = lookup(data.cloudflare_zones.domain.zones[0], "id")
  value   = data.sops_file.cloudflare_secrets.data["cname_oracle_domain"]
  proxied = true
  type    = "CNAME"
  ttl     = 1
}

resource "cloudflare_record" "oracle_remote_subdomain" {
  name    = data.sops_file.cloudflare_secrets.data["oracle_remote_subdomain"]
  zone_id = lookup(data.cloudflare_zones.domain.zones[0], "id")
  value   = data.sops_file.cloudflare_secrets.data["cname_oracle_domain"]
  proxied = true
  type    = "CNAME"
  ttl     = 1
}

# resource "cloudflare_record" "home_subdomain" {
#   name    = data.sops_file.cloudflare_secrets.data["home_subdomain"]
#   zone_id = lookup(data.cloudflare_zones.domain.zones[0], "id")
#   value   = data.sops_file.cloudflare_secrets.data["cname_home_domain"]
#   proxied = true
#   type    = "CNAME"
#   ttl     = 1
# }

# resource "cloudflare_record" "weave_subdomain" {
#   name    = data.sops_file.cloudflare_secrets.data["weave_subdomain"]
#   zone_id = lookup(data.cloudflare_zones.domain.zones[0], "id")
#   value   = data.sops_file.cloudflare_secrets.data["cname_home_domain"]
#   proxied = true
#   type    = "CNAME"
#   ttl     = 1
# }

# resource "cloudflare_record" "dns_subdomain" {
#   name    = data.sops_file.cloudflare_secrets.data["dns_subdomain"]
#   zone_id = lookup(data.cloudflare_zones.domain.zones[0], "id")
#   value   = data.sops_file.cloudflare_secrets.data["cname_home_domain"]
#   proxied = true
#   type    = "CNAME"
#   ttl     = 1
# }

# resource "cloudflare_record" "dns2_subdomain" {
#   name    = data.sops_file.cloudflare_secrets.data["dns2_subdomain"]
#   zone_id = lookup(data.cloudflare_zones.domain.zones[0], "id")
#   value   = data.sops_file.cloudflare_secrets.data["cname_home_domain"]
#   proxied = true
#   type    = "CNAME"
#   ttl     = 1
# }

# resource "cloudflare_record" "proxy_subdomain" {
#   name    = data.sops_file.cloudflare_secrets.data["proxy_subdomain"]
#   zone_id = lookup(data.cloudflare_zones.domain.zones[0], "id")
#   value   = data.sops_file.cloudflare_secrets.data["cname_home_domain"]
#   proxied = true
#   type    = "CNAME"
#   ttl     = 1
# }

# resource "cloudflare_record" "storage_subdomain" {
#   name    = data.sops_file.cloudflare_secrets.data["storage_subdomain"]
#   zone_id = lookup(data.cloudflare_zones.domain.zones[0], "id")
#   value   = data.sops_file.cloudflare_secrets.data["cname_home_domain"]
#   proxied = true
#   type    = "CNAME"
#   ttl     = 1
# }
