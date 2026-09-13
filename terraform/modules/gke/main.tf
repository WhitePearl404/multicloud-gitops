resource "google_compute_network" "this" {
  project                 = var.project_id
  name                    = "${var.name}-vpc"
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "this" {
  project                  = var.project_id
  name                     = "${var.name}-subnet"
  region                   = var.region
  network                  = google_compute_network.this.id
  ip_cidr_range            = var.subnetwork_cidr
  private_ip_google_access = true
}

resource "google_container_cluster" "this" {
  project  = var.project_id
  name     = var.name
  location = var.location

  min_master_version = var.min_version
  network            = google_compute_network.this.id
  subnetwork         = google_compute_subnetwork.this.id

  remove_default_node_pool = true
  initial_node_count       = 1

  network_policy {
    enabled  = var.enable_network_policy
    provider = "CALICO"
  }

  workload_identity_config {
    workload_pool = "${var.project_id}.svc.id.goog"
  }

  release_channel {
    channel = var.release_channel
  }

  deletion_protection = var.deletion_protection
}

resource "google_container_node_pool" "this" {
  for_each = {
    for pool in var.node_pools : pool.name => pool
  }

  project    = var.project_id
  name       = "${var.name}-${each.value.name}"
  location   = var.location
  cluster    = google_container_cluster.this.name
  node_count = each.value.initial_count

  management {
    auto_repair  = true
    auto_upgrade = true
  }

  autoscaling {
    min_node_count = each.value.min_count
    max_node_count = each.value.max_count
  }

  node_config {
    machine_type = each.value.machine_type
    disk_size_gb = each.value.disk_size_gb
    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform",
    ]

    workload_metadata_config {
      mode = "GKE_METADATA"
    }

    labels = {
      environment = var.environment
      pool        = each.value.name
    }
  }
}

resource "google_service_account" "workload_identity" {
  project      = var.project_id
  account_id   = "${var.name}-workloads"
  display_name = "Workload Identity service account for ${var.name}"
}

resource "google_project_iam_member" "workload_identity_roles" {
  for_each = toset(var.workload_identity_roles)

  project = var.project_id
  role    = each.value
  member  = "serviceAccount:${google_service_account.workload_identity.email}"
}
