bundle: {
    apiVersion: "v1alpha1"
    name:       "addons"
    instances: {
        "flux": {
            module: url: "oci://ghcr.io/stefanprodan/modules/flux-aio"
            namespace: "flux-system"
            values: {
                controllers: {
                    notification: enabled: false
                }
            }
        }
        "cert-manager": {
            module: url: "oci://ghcr.io/stefanprodan/modules/flux-helm-release"
            namespace: "cert-manager"
            values: {
                repository: url: "https://charts.jetstack.io"
                chart: {
                    name:    "cert-manager"
                    version: "1.x"
                }
                helmValues: {
                    installCRDs: true
                }
            }
        }
    }
}
