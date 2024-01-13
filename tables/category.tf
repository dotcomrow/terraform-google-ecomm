[
  {
    "mode": "REQUIRED",
    "name": "category_id",
    "type": "INTEGER"
  },
  {
    "defaultValueExpression": "GENERATE_UUID()",
    "mode": "REQUIRED",
    "name": "uuid",
    "type": "STRING"
  },
  {
    "mode": "REQUIRED",
    "name": "status",
    "type": "BOOLEAN"
  },
  {
    "name": "parent_id",
    "type": "INTEGER"
  },
  {
    "mode": "REQUIRED",
    "name": "include_in_nav",
    "type": "BOOLEAN"
  },
  {
    "name": "position",
    "type": "INTEGER"
  },
  {
    "defaultValueExpression": "CURRENT_TIMESTAMP",
    "name": "created_at",
    "type": "TIMESTAMP"
  },
  {
    "defaultValueExpression": "CURRENT_TIMESTAMP",
    "name": "updated_at",
    "type": "TIMESTAMP"
  }
]
