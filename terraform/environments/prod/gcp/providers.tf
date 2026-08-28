provider "google" {
  project = var.project_id
  region = var.region
}
data "google_client_config" "this" {}
provider "kubernetes" {
  alias = "gke"
  host = "https://${module.gke.endpoint}"
  cluster_ca_certificate = base64decode(module.gke.cluster_ca_certificate)
  token = data.google_client_config.this.access_token
}
provider "helm" {
  alias = "gke"
  kubernetes {
    host = "https://${module.gke.endpoint}"
    cluster_ca_certificate = base64decode(module.gke.cluster_ca_certificate)
    token = data.google_client_config.this.access_token
  }
}
provider "kubectl" {
  alias = "gke"
  host = "https://${module.gke.endpoint}"
  cluster_ca_certificate = base64decode(module.gke.cluster_ca_certificate)
  token = data.google_client_config.this.access_token
  load_config_file = false
  apply_retry_count = 5
}
