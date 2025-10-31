# Terraform

All infrastructure is managed using Terraform. The exception is the bucket backing the terraform state `gs://marrow-terraform-state`. It was created by running locally the command `gsutil mb -p compute-cluster-476800 -l northamerica-northeast2 gs://marrow-terraform-state`.

## Default Configuration

* Use project ID `compute-cluster-476800`
* Use region `northamerica-northeast2`

## Changing the Infrastructure

### 1. Local Validation

1. Authorize with `gcloud auth application-default login`.
2. Run `terraform init` to gather necessary dependencies.
3. Run `terraform plan` and inspect the output.
4. If needed, push to a non-main branch and obtain a PR review before merging into main.

### 2. Authorize GitHub Actions Terraform

The GitHub Action in `.github/workflows/terraform.yaml` applies the HEAD commit to the project.
The identity of the GitHub action runner is used to authenticate with Google Cloud.
In order to authorize the runner, we must first add an IAM policy binding to the target resource locally and then wait up to two minutes for the change to propagate.
See details in [Direct Workload Identity Federation](https://github.com/google-github-actions/auth?tab=readme-ov-file#preferred-direct-workload-identity-federation).

#### Example: Artifact Registry

The following declaration materialized an Artifact Registry repository named `marrow` in the `northamerica-northeast2` region of the `compute-cluster-476800` project.

```terraform
module "artifact_registry" {
  source = "GoogleCloudPlatform/artifact-registry/google"

  project_id    = "compute-cluster-476800"
  location      = "northamerica-northeast2"
  format        = "DOCKER"
  repository_id = "marrow"
}
```

The corresponding IAM policy binding follows:

```bash
~/marrow/terraform> gcloud artifacts repositories add-iam-policy-binding marrow --location=northamerica-northeast2 --project=compute-cluster-476800 --role=roles/artifactregistry.admin --member=principalSet://iam.googleapis.com/projects/22128417358/locations/global/workloadIdentityPools/github/attribute.repository/Marrow-Biosciences/marrow
Updated IAM policy for repository [marrow].
bindings:
- members:
  - principalSet://iam.googleapis.com/projects/22128417358/locations/global/workloadIdentityPools/github/attribute.repository/Marrow-Biosciences/marrow
  role: roles/artifactregistry.admin
etag: BwZCerNgLrg=
version: 1
```

#### Example: Terraform State Storage

The following IAM policy binding authorizes Terraform to administer the Terraform state storage bucket `gs://marrow-terraform-state`:

```bash
~/marrow/terraform> gcloud storage buckets add-iam-policy-binding gs://marrow-terraform-state --project=compute-cluster-476800 --role=roles/storage.objectAdmin --member=principalSet://iam.googleapis.com/projects/22128417358/locations/global/workloadIdentityPools/github/attribute.repository/Marrow-Biosciences/marrow
bindings:
- members:
  - projectEditor:compute-cluster-476800
  - projectOwner:compute-cluster-476800
  role: roles/storage.legacyBucketOwner
- members:
  - projectViewer:compute-cluster-476800
  role: roles/storage.legacyBucketReader
- members:
  - projectEditor:compute-cluster-476800
  - projectOwner:compute-cluster-476800
  role: roles/storage.legacyObjectOwner
- members:
  - projectViewer:compute-cluster-476800
  role: roles/storage.legacyObjectReader
- members:
  - principalSet://iam.googleapis.com/projects/22128417358/locations/global/workloadIdentityPools/github/attribute.repository/Marrow-Biosciences/marrow
  role: roles/storage.objectAdmin
etag: CAI=
kind: storage#policy
resourceId: projects/_/buckets/marrow-terraform-state
version: 1
```
