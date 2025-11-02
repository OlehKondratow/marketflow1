resource "kubernetes_namespace" "ingress_prod" {
  metadata {
    name = "ingress-prod"
  }
}

resource "helm_release" "ingress_nginx_prod" {
  name             = "ingress-nginx-prod"
  repository       = "https://kubernetes.github.io/ingress-nginx"
  chart            = "ingress-nginx"
  namespace        = kubernetes_namespace.ingress_prod.metadata[0].name
  create_namespace = true
  timeout          = 900
  force_update     = true
  replace          = true

  values = [
    yamlencode({
      controller = {
        replicaCount = 1
        ingressClass = "nginx-prod"
        watchIngressWithoutClass = false

        ingressClassResource = {
          name            = "nginx-prod"
          controllerValue = "k8s.io/nginx-prod"
        }

        service = {
          type           = "LoadBalancer"
          loadBalancerIP = var.prod_ingress_ip
          annotations = {
            "service.beta.kubernetes.io/azure-load-balancer-resource-group" = var.resource_group_name
          }
        }
      }
    })
  ]

  depends_on = [kubernetes_namespace.ingress_prod]
}

