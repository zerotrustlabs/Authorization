locals {
  adj              = jsondecode(file("./files/adjectives.json"))
  istio_charts_url = "https://istio-release.storage.googleapis.com/charts"
  # random_password = random_password.password.result
}