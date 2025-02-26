resource "kubernetes_manifest" "cilium_lb_pool" {
  manifest = {
    "apiVersion" = "cilium.io/v2"
    "kind"       = "CiliumLoadBalancerIPPool"
    "metadata" = {
      "name" = "main-pool"
    }
    "spec" = {
      "blocks" : [
        {
          "cidr" = "10.0.2.0/24" # This will be the external ip range for the load balancer
        }
      ]
      serviceSelector = {
        "matchLabels" = {
          "lb-pool" = "main-pool"
        }
      }
    }
  }
}

resource "kubernetes_manifest" "cilium_l2_announcement" {
  manifest = {
    "apiVersion" = "cilium.io/v2alpha1"
    "kind"       = "CiliumL2AnnouncementPolicy"
    "metadata" = {
      "name" = "main-pool-l2-announcement"
    }
    "spec" = {
      "externalIPs"     = true
      "loadBalancerIPs" = true
    }
  }
}
