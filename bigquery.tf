resource "google_bigquery_dataset" "ecomm" {
  dataset_id                  = "${var.project_name}_dataset"
  description                 = "Dataset for ${var.project_name} project"
  location                    = "US"
  project                     = var.project_id

  depends_on = [ google_project_service.project_service ]
}

# resource "google_bigquery_table" "admin_user" {
#   dataset_id = google_bigquery_dataset.ecomm.dataset_id
#   table_id   = "admin_user"
#   deletion_protection = false
#   project                     = var.project_id
#   schema = <<EOF
# [
#   {
#     "mode": "REQUIRED",
#     "name": "admin_user_id",
#     "type": "INTEGER"
#   },
#   {
#     "defaultValueExpression": "GENERATE_UUID()",
#     "mode": "REQUIRED",
#     "name": "uuid",
#     "type": "STRING"
#   },
#   {
#     "defaultValueExpression": "true",
#     "mode": "REQUIRED",
#     "name": "status",
#     "type": "BOOLEAN"
#   },
#   {
#     "mode": "REQUIRED",
#     "name": "email",
#     "type": "STRING"
#   },
#   {
#     "mode": "REQUIRED",
#     "name": "password",
#     "type": "STRING"
#   },
#   {
#     "name": "full_name",
#     "type": "STRING"
#   },
#   {
#     "defaultValueExpression": "CURRENT_TIMESTAMP",
#     "name": "created_at",
#     "type": "TIMESTAMP"
#   },
#   {
#     "defaultValueExpression": "CURRENT_TIMESTAMP",
#     "name": "updated_at",
#     "type": "TIMESTAMP"
#   }
# ]
# EOF

#   depends_on = [ google_bigquery_dataset.ecomm ]
# }

