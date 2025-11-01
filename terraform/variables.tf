variable "project" {
  type    = string
  default = "compute-cluster-476800"
}

variable "region" {
  type    = string
  default = "northamerica-northeast2"
}

variable "repository" {
  type    = string
  default = "marrow"
}

variable "risingwave_metadata_dsn" {
  type      = string
  sensitive = true
}
