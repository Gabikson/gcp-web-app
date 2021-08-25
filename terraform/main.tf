terraform {
  required_providers {
    google = {
      source = "hashicorp/google"
      version = "3.77.0"
    }
  }

  backend "gcs" {
    bucket  = "home-312812-tf-state"
    prefix  = "terraform/state"
  }
}

provider "google" {
  project = var.project_id
  region  = var.project_region
  zone    = var.project_zone
}

provider "google-beta" {
  project = var.project_id
  region  = var.project_region
  zone    = var.project_zone
}

###### TF STATE BUCKET
# resource "google_storage_bucket" "tf_state_bucket" {
#   name          = "${var.project_id}-tf-state"
#   location      = var.project_region

#   bucket_policy_only = true
# }

resource "google_service_account" "db_sa" {
  account_id = var.db_access_sa_name
  display_name = var.db_access_sa_name
}

resource "google_service_account_key" "mykey" {
  service_account_id = google_service_account.db_sa.name
}

resource "google_project_iam_binding" "db_sa_iam" {
  project = var.project_id
  role               = "roles/cloudsql.client"

  members = [
    "serviceAccount:${google_service_account.db_sa.email}",
  ]

}

resource "google_compute_address" "static_address" {
  name = "cloud-x-static-ip"
  project = var.project_id
}

##### CLOUD SOURCE REPOSITORY
resource "google_sourcerepo_repository" "cloud_source_repository" {
  name = var.source-repository-name
}

##### CLOUD BUILD
resource "google_cloudbuild_trigger" "cloud-build-trigger" {
  depends_on = [google_sourcerepo_repository.cloud_source_repository]

  substitutions = {
    _APP_NAME = var.app-name
    _PROJECT = var.project_id
    _DB_ACCESS_SA = var.db_access_sa_name
    _REGION = var.project_region
    _GKE_CLUSTER_NAME = var.gke-cluster-name
    _DEPLOYER_IMAGE_NAME = var.deployer-image-name
    _DB_INSTANCE = var.cloud-sql-instance-name
    _ZONE = var.project_zone
    _STATIC_IP = google_compute_address.static_address.address

  }

  trigger_template {
    branch_name = "master"
    repo_name   = google_sourcerepo_repository.cloud_source_repository.name

  }

  filename = "terraform/meta/cloudbuild.yaml"
}

##### PRIVATE NETWORK
resource "google_compute_network" "private_network" {
  project = var.project_id
  name = "private-network"
}

resource "google_compute_global_address" "private_ip_address" {
  project = var.project_id
  name          = "private-ip-address"
  purpose       = "VPC_PEERING"
  address_type  = "INTERNAL"
  prefix_length = 16
  network       = google_compute_network.private_network.id
}

resource "google_service_networking_connection" "private_vpc_connection" {
  network                 = google_compute_network.private_network.id
  service                 = "servicenetworking.googleapis.com"
  reserved_peering_ranges = [google_compute_global_address.private_ip_address.name]
}

resource "google_compute_subnetwork" "private_subnetwork" {
  project = var.project_id
  name          = "private-subnetwork"
  ip_cidr_range = "10.2.0.0/16"
  region        = var.project_region
  network       = google_compute_network.private_network.id
}

##### GKE
resource "google_container_cluster" "primary" {
  project = var.project_id
  name               = var.gke-cluster-name
  location           = var.project_region
  initial_node_count = 1
  network = google_compute_network.private_network.id
  subnetwork = google_compute_subnetwork.private_subnetwork.id
  node_config {
    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform"
    ]
  }

  ip_allocation_policy {}

  timeouts {
    create = "30m"
    update = "40m"
  }
}

##### CLOUD SQL
resource "google_sql_database_instance" "sql_master_instance" {
  project = var.project_id
  name             = var.cloud-sql-instance-name
  database_version = "POSTGRES_11"
  region           = var.project_region

  depends_on = [google_service_networking_connection.private_vpc_connection]

  settings {
    tier = "db-f1-micro"
    ip_configuration {
      ipv4_enabled = false
      private_network = google_compute_network.private_network.id
    }
    database_flags {
      name = "max_connections"
      value = "100"
    }
  }
}

resource "google_secret_manager_secret" "secret-basic" {
  secret_id = "secret-version"

  replication {
    automatic = true
  }
}


resource "google_secret_manager_secret_version" "secret-version-basic" {
  secret = google_secret_manager_secret.secret-basic.id

  secret_data = base64decode(google_service_account_key.mykey.private_key)
}


//resource "google_compute_forwarding_rule" "default" {
//  name       = "cloud-x-forwarding-rule"
//  port_range = "80"
//  region = var.project_region
//  target = google_compute_target_pool.default.id
//  load_balancing_scheme = "EXTERNAL"
//
//  ip_address = google_compute_address.static_address.id
//
//  #   backend_service = google_compute_region_backend_service.backend.id
//}

# resource "google_compute_region_backend_service" "backend" {
#   provider              = google-beta
#   project = var.project_id
#   name                  = "cloud-x-backend"
#   region                = var.project_region
#   load_balancing_scheme = "EXTERNAL"
#   health_checks         = [google_compute_region_health_check.hc.id]

# }

//resource "google_compute_target_pool" "default" {
//  name = "cloud-x-target-pool"
//  region = var.project_region
//
//  instances = [

    #   "${var.project_zone}/gke-cloud-x-demo-cluster-default-pool-9106dfa9-7q8c",
//    "${var.project_zone}/gke-cloud-x-demo-cluster-default-pool-53d12bd3-dj0q",
    #   "${var.project_zone}/gke-cloud-x-demo-cluster-default-pool-8c83a210-49fx",
//  ]
//
//  health_checks = [ google_compute_http_health_check.hc.id ]
//}


//resource "google_compute_http_health_check" "hc" {
//  project = var.project_id
//  provider           = google-beta
//  name               = "check-cloud-x-hc"
//  check_interval_sec = 10
//  timeout_sec        = 10
//  port = 10256
//  request_path = "/healthz"
//}