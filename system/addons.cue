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
		"linkerd-crds": {
			module: url: "oci://ghcr.io/stefanprodan/modules/flux-helm-release"
			namespace: "linkerd"
			values: {
				repository: url: "https://helm.linkerd.io/edge"
				chart: {
					name:    "linkerd-crds"
					version: "2024.8.2" // Use edge release with corresponding stable release https://linkerd.io/releases
				}
			}
		}
		"linkerd-control-plane": {
			module: url: "oci://ghcr.io/stefanprodan/modules/flux-helm-release"
			namespace: "linkerd"
			values: {
				repository: url: "https://helm.linkerd.io/edge"
				chart: {
					name:    "linkerd-control-plane"
					version: "2024.8.2"
				}
				helmValues: {
					identityTrustAnchorsPEM: string @timoni(runtime:string:linkerd_ca_crt)
					identity: issuer: tls: {
						crtPEM: string @timoni(runtime:string:linkerd_issuer_crt)
						keyPEM: string @timoni(runtime:string:linkerd_issuer_key)
					}
				}
			}
		}
	}
}
