resource "google_bigquery_dataset" "ecomm" {
  dataset_id                  = "${var.project_name}_dataset"
  description                 = "Dataset for ${var.project_name} project"
  location                    = "US"
  project                     = var.project_id

  depends_on = [ google_project_service.project_service ]
}

module "schemas" {
    source = "./tables"
    project_id = var.project_id
    dataset_id = google_bigquery_dataset.ecomm.dataset_id

    depends_on = [ google_bigquery_dataset.ecomm ]
}

data "external" "build_graphql_schema" {
  program = ["${path.module}/scripts/build_graphql_schema.sh", "${var.common_project_id}"]

  depends_on = [ module.schemas ]
}