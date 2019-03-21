# Vault GCP Authentication

This tutorial is meant to show how to configure Vault using Terraform. This uses:

* [GCP Auth Backend](https://www.vaultproject.io/docs/auth/gcp.html)
* [GCP Secrets Backend](https://www.vaultproject.io/docs/secrets/gcp/index.html)
* [Google Terraform Provider](https://www.terraform.io/docs/providers/google/index.html)
* [Vault Terraform Provider](https://www.terraform.io/docs/providers/vault/index.html)

To run first set your project then apply with:

```
export TF_VAR_project="MY-PROJECT"
terraform apply
```

_NOTE: This assumes you have already setup Vault with the correct permissions to GCP and are logged in as a root user_

There also is a wrapper script that allows you to pass in your project to authenticate:

```
./bin/auth MY-PROJECT
```