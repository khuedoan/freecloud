bundle: {
	apiVersion: "v1alpha1"
	name:       "micropaas"
	instances: {
		"micropaas": {
			module: url: "oci://ghcr.io/stefanprodan/modules/flux-helm-release"
			namespace: "micropaas"
			values: {
				repository: url: "https://bjw-s.github.io/helm-charts"
				chart: {
					name:    "app-template"
					version: "3.1.0"
				}
				helmValues: {
					controllers: main: containers: {
						main: {
							image: {
								repository: "docker.io/khuedoan/micropaas"
								tag:        "dev"
							}
							env: {
								DOCKER_HOST: "tcp://127.0.0.1:2375"
								// TODO gen key in SOPS?
								SOFT_SERVE_INITIAL_ADMIN_KEYS: "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIN5ue4np7cF34f6dwqH1262fPjkowHQ8irfjVC156PCG"
								REGISTRY_HOST:                 "docker.io/khuedoan"
								GITOPS_REPO:                   "horus"
								GIT_USER_NAME:                 "Khue's Bot"
								GIT_USER_EMAIL:                "mail@khuedoan.com"
							}
						}
						docker: {
							image: {
								repository: "docker.io/library/docker"
								tag:        "27-dind"
							}
							command: [
								"dockerd",
								"--host=tcp://127.0.0.1:2375",
							]
							securityContext: privileged: true
						}
						nginx: image: {
							repository: "docker.io/library/nginx"
							tag:        "latest"
						}
					}
					service: main: {
						controller: "main"
						ports: {
							ssh: {
								port:     2222
								protocol: "TCP"
							}
							http: {
								port:     8080
								protocol: "TCP"
							}
							web: {
								port:     80
								protocol: "HTTP"
							}
						}
					}
					ingress: main: {
						enabled: true
						annotations: "cert-manager.io/cluster-issuer": "letsencrypt-prod"
						hosts: [{
							host: "code.khuedoan.com"
							paths: [{
								path:     "/"
								pathType: "Prefix"
								service: {
									identifier: "main"
									port:       80
								}
							}]
						}]
						tls: [{
							hosts: ["code.khuedoan.com"]
							secretName: "micropaas-tls-certificate"
						}]
					}
					persistence: {
						data: {
							accessMode: "ReadWriteOnce"
							size:       "10Gi"
							advancedMounts: main: {
								main: [{
									path:    "/var/lib/micropaas/repos"
									subPath: "repos"
								}, {
									path:    "/var/lib/micropaas/ssh"
									subPath: "ssh"
								}, {
									path:    "/var/lib/micropaas/web"
									subPath: "web"
								}, {
									// TODO avoid manual docker login?
									path:    "/root/.docker"
									subPath: "docker-config"
								}]
								nginx: [{
									path:    "/usr/share/nginx/html"
									subPath: "web"
								}]
							}
						}
						cache: {
							accessMode: "ReadWriteOnce"
							size:       "100Gi"
							advancedMounts: main: main: [{
								path:    "/var/cache/micropaas"
								subPath: "micropaas"
							}]
						}
					}
				}
			}
		}
	}
}
