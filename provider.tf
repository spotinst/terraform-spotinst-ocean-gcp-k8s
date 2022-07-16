provider "restapi" {
  alias = "restapi_programmatic"
  uri                  = "https://api.spotinst.io"
  write_returns_object = true
  debug                = true

  headers = {
    "Authorization": "Bearer ${var.spotinst_token}"
    "Content-Type" = "application/json"
  }

  create_method  = "POST"
  update_method  = "PUT"
  destroy_method = "DELETE"
}