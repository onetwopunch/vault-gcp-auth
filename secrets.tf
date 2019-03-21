# GCP Secrets backend configuration

resource "vault_gcp_secret_backend" "gcp" {}


# NOTE: Once https://github.com/terraform-providers/terraform-provider-vault/pull/312
# is merged, we can actually use the roleset resource instead of local-exec
# Also cannot use JSON here either as the AST seems broken. Relevant PR here:
# https://github.com/hashicorp/vault-plugin-secrets-gcp/pull/30

# NOTE: This demo was initially designed for BigQuery instead of GCS, but since bigquery API uses a legacy API format, dynamically creating a Service Account in Vault with
# access to bigquery is not possible using their plugin: see: https://github.com/hashicorp/vault-plugin-secrets-gcp/issues/24

data "template_file" "gcs-editor-roleset-doc" {
  template = "${file("${path.module}/roleset.hcl.tmpl")}"
  vars = {
    bucket = "${var.bucket}"
    role = "storage.admin"
  }
}

data "template_file" "gcs-viewer-roleset-doc" {
  template = "${file("${path.module}/roleset.hcl.tmpl")}"
  vars = {
    bucket = "${var.bucket}"
    role = "storage.objectAdmin"
  }
}

resource "local_file" "gcs-editor-roleset-doc-rendered" {
    content     = "${data.template_file.gcs-editor-roleset-doc.rendered}"
    filename = "${path.module}/bindings/gcs_editor.hcl"
}
resource "local_file" "gcs-viewer-roleset-doc-rendered" {
    content     = "${data.template_file.gcs-viewer-roleset-doc.rendered}"
    filename = "${path.module}/bindings/gcs_viewer.hcl"
}

resource "null_resource" "gcs-viewer-roleset" {
    provisioner "local-exec" {
        command = "vault write gcp/roleset/gcs-viewer project=${var.project} secret_type=service_account_key bindings=@bindings/gcs_viewer.hcl"
    }
    depends_on = ["vault_gcp_secret_backend.gcp", "local_file.gcs-viewer-roleset-doc-rendered"]
}
resource "null_resource" "gcs-editor-roleset" {
    provisioner "local-exec" {
        command = "vault write gcp/roleset/gcs-editor project=${var.project} secret_type=service_account_key bindings=@bindings/gcs_editor.hcl"
    }
    depends_on = ["vault_gcp_secret_backend.gcp", "local_file.gcs-editor-roleset-doc-rendered"]
}