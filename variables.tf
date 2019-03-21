variable "project" {}
variable "bucket" {}

variable "gcp_iam_auth_roles" {
  default = [
      "roles/iam.serviceAccountTokenCreator"
  ]
}

variable "region" {
  default = "us-west1"
}
