bundle: {
    apiVersion: "v1alpha1"
    name:       "homelab-docs"
    instances: {
        "homelab-docs": {
            module: url: "oci://ghcr.io/stefanprodan/modules/flux-helm-release"
            namespace: "homelab-docs"
            values: {
                repository: url: "https://bjw-s.github.io/helm-charts"
                chart: {
                    name:    "app-template"
                    version: "3.1.0"
                }
                helmValues: {
                    controllers: main: containers: {
                        nginx: {
                            image: {
                                repository: "nginx"
                                tag: "latest"
                            }
                        }
                        build: {
                            image: {
                                repository: "nixos/nix"
                                tag: "latest"
                            }
                            workingDir: "/usr/local/src"
                            command: ["/bin/sh", "-c"]
                            // TODO better way to do this?
                            args: [
                                """
                                nix-shell -p git --command 'git clone https://github.com/khuedoan/homelab .'
                                while true; do
                                    nix-shell -p python311Packages.mkdocs-material --command 'mkdocs build'
                                    cp -RT ./site /usr/share/nginx/html
                                    sleep 120
                                    nix-shell -p git --command 'git fetch origin'
                                    nix-shell -p git --command 'git reset --hard origin/master'
                                done
                                """
                            ]
                        }
                    }
                    persistence: {
                        src: {
                            type: "emptyDir"
                            globalMounts: [{
                                path: "/usr/local/src"
                            }]
                        }
                        html: {
                            type: "emptyDir"
                            globalMounts: [{
                                path: "/usr/share/nginx/html"
                            }]
                        }
                    }
                    service: main: {
                        controller: "main"
                        ports: http: {
                            port: 80
                            protocol: "HTTP"
                        }
                    }
                    ingress: main: {
                        hosts: [{
                            // TODO domain from runtime
                            host: "homelab.127-0-0-1.nip.io"
                            paths: [{
                                path: "/"
                                pathType: "Prefix"
                                service: {
                                    identifier: "main"
                                }
                            }]
                        }]
                    }
                }
            }
        }
    }
}
