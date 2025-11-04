resource "helm_release" "ingress_nginx_dev" {
  name             = "ingress-nginx-dev"
  repository       = "https://kubernetes.github.io/ingress-nginx"
  chart            = "ingress-nginx"
  namespace        = "ingress-dev"
  create_namespace = true

  timeout      = 900
  force_update = true
  replace      = true

  # ---- FIX ----
  set {
    name  = "controller.ingressClassResource.name"
    value = "nginx-dev"
  }

  set {
    name  = "controller.service.loadBalancerIP"
    value = var.dev_ingress_ip
  }

  set {
    name  = "controller.service.annotations.service\\.beta\\.kubernetes\\.io/azure-load-balancer-resource-group"
    value = data.terraform_remote_state.phase2_aks.outputs.aks_resource_group_name
  }
}
