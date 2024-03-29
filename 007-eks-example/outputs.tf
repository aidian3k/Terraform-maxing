locals {
  status = kubernetes_service.kube_service.status
}

output "kube_endpoint" {
  description = "The endpoint of the kubernetes service"
  value = try(
    "http://${local.status[0]["load_balancer"]["ingress"][0]["hostname"]}",
    "An error occured while parsing the status"
  )
}