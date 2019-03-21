provider "vault" {
    # Needs address and token values set here, unless already set in
    # VAULT_ADDR and VAULT_TOKEN respectively
}

# Identity/Authentication
resource "vault_auth_backend" "gcp" {
    path = "gcp"
    type = "gcp"
}

resource "vault_gcp_auth_backend_role" "admin" {
    role                   = "admin-auth-role"
    type                   = "iam"
    backend                = "${vault_auth_backend.gcp.path}"
    project_id             = "${var.project}"
    bound_service_accounts = ["${google_service_account.vault-admin.email}"]
    policies               = ["root"]
}

# Human users can only have editor permissions on Big Query
resource "vault_gcp_auth_backend_role" "user" {
    role                   = "user-auth-role"
    type                   = "iam"
    backend                = "${vault_auth_backend.gcp.path}"
    project_id             = "${var.project}"
    bound_service_accounts = ["${google_service_account.vault-user.email}"]
    policies               = ["${vault_policy.gcs-editor-policy.name}"]
}

# Automated users can only read from Big Query
resource "vault_gcp_auth_backend_role" "app" {
    role                   = "app-auth-role"
    type                   = "gce"
    backend                = "${vault_auth_backend.gcp.path}"
    project_id             = "${var.project}"
    bound_service_accounts = ["${google_service_account.vault-app-role.email}"]
    policies               = ["${vault_policy.gcs-viewer-policy.name}"]
}

# Permissions/Authorizations

# Grants access to lease out SA keys for viewing GCS Bucket
resource "vault_policy" "gcs-viewer-policy" {
  name = "gcs-viewer"

  policy = <<EOT
path "gcp/key/gcs-viewer" {
  policy = "read"
}
EOT
}

# Grants access to lease out SA keys for editing GCS Bucket
resource "vault_policy" "gcs-editor-policy" {
  name = "gcs-editor"

  policy = <<EOT
path "gcp/key/gcs-editor" {
  policy = "read"
}
EOT
}