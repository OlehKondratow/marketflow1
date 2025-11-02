resource "helm_release" "ingress_nginx_dev" {
  name             = "ingress-nginx-dev"
  repository       = "https://kubernetes.github.io/ingress-nginx"
  chart            = "ingress-nginx"
  namespace        = "ingress-dev"
  create_namespace = true
  timeout = 900
  force_update = true
  replace = true

  set = [
    {
      name  = "controller.ingressClassResource.name"
      value = "nginx-dev"
    },
    {
      name  = "controller.service.loadBalancerIP"
      value = var.dev_ingress_ip
    },
    {
      name  = "controller.service.annotations.service\\.beta\\.kubernetes\\.io/azure-load-balancer-resource-group"
      value = var.resource_group_name
    }
  ]
}
