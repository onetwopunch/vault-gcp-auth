# NOTE: This all assumes that the GKE cluster where Vault is hosted is assigned
# a Service Account with the following permissions from https://www.vaultproject.io/api/auth/gcp/index.html#parameters
#
#   iam.serviceAccounts.get
#   iam.serviceAccountKeys.get
#
# In our case we just added that to the terraform/gcp.tf file as a custom role

# Now we need to set up all the Service Accounts for authentication into GCP. Each
# SA will be bound to a policy in Vault.

# The Vault Admin SA will be used to authenticate Human Admins to vault.
# It will be granted root permissions so assign users to it with great prejudice.
provider "google" {
  region  = "${var.region}"
  project = "${var.project}"
}
resource "google_service_account" "vault-admin" {
  account_id   = "vault-admin-auth"
  display_name = "Vault Admin"
  project      = "${var.project}"
}

resource "google_project_iam_member" "vault-admin-membership" {
  count   = "${length(var.gcp_iam_auth_roles)}"
  project = "${var.project}"
  role    = "${element(var.gcp_iam_auth_roles, count.index)}"
  member  = "serviceAccount:${google_service_account.vault-admin.email}"
}

# The Vault User SA will authenticate to vault with minimal GCP permissions and
# generate short-lived SA's with actual access to GCP resource. This will allow human users
# take out a lease on certain SA
resource "google_service_account" "vault-user" {
  account_id   = "vault-user-auth"
  display_name = "Vault User"
  project      = "${var.project}"
}

resource "google_project_iam_member" "vault-user-membership" {
  count   = "${length(var.gcp_iam_auth_roles)}"
  project = "${var.project}"
  role    = "${element(var.gcp_iam_auth_roles, count.index)}"
  member  = "serviceAccount:${google_service_account.vault-user.email}"
}

# The Vault App Role SA will authenticate to vault with minimal GCP permissions and
# generate short-lived SA's with actual access to GCP resource. This will allow automated
# processes to take out a lease on certain SA
resource "google_service_account" "vault-app-role" {
  account_id   = "vault-app-role-auth"
  display_name = "Vault App Role"
  project      = "${var.project}"
}

resource "google_project_iam_member" "vault-app-role-membership" {
  count   = "${length(var.gcp_iam_auth_roles)}"
  project = "${var.project}"
  role    = "${element(var.gcp_iam_auth_roles, count.index)}"
  member  = "serviceAccount:${google_service_account.vault-app-role.email}"
}