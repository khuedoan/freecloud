bundle: {
	apiVersion: "v1alpha1"
	name:       "monitoring"
	instances: {
		"grafana": {
			module: url: "oci://ghcr.io/stefanprodan/modules/flux-helm-release"
			namespace: "monitoring"
			values: {
				repository: url: "https://grafana.github.io/helm-charts"
				chart: {
					name:    "grafana"
					version: "8.6.0"
				}
				helmValues: {
					podAnnotations: {
						"linkerd.io/inject": "enabled"
					}
				}
			}
		}
	}
}
