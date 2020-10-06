provider "helm" {
  kubernetes {
    load_config_file       = false
    cluster_ca_certificate = base64decode(var.kubernetes_cluster_cert_data)
    host                   = var.kubernetes_cluster_endpoint
    exec {
      api_version = "client.authentication.k8s.io/v1alpha1"
      command     = "aws-iam-authenticator"
      args        = ["token", "-i", "${var.kubernetes_cluster_name}"]
    }
  }
}

/*
provider "aws" {
  region = var.aws_region
}
*/

# helm repo add traefik https://helm.traefik.io/traefik
# helm install traefik traefik/traefik

resource "helm_release" "traefik-ingress" {
  name       = "ms-traefik-ingress"
  chart      = "traefik"
  repository = "https://helm.traefik.io/traefik"
  values = [<<EOF
  service:
    annotations:
      service.beta.kubernetes.io/aws-load-balancer-type: nlb
      externalTrafficPolicy: Local
  EOF
  ]

  # Don't install until the EKS cluser nodegroup has started
  # depends_on = [kubernetes_namespace.argo-ns]
}

#resource "aws_api_gateway_vpc_link" "ingress-link" {
#  name = "${var.env_name}-ingress-link"
#}