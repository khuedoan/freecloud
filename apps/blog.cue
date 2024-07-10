bundle: {
    apiVersion: "v1alpha1"
    name:       "blog"
    instances: {
        "blog": {
            module: url: "oci://ghcr.io/stefanprodan/modules/flux-helm-release"
            namespace: "blog"
            values: {
                repository: url: "https://bjw-s.github.io/helm-charts"
                chart: {
                    name:    "app-template"
                    version: "3.1.0"
                }
                helmValues: {
                    controllers: main: containers: app: {
                        image: {
                            // TODO
                            repository: "stefanprodan/podinfo"
                            tag: "latest"
                        }
                        env: {
                            TESTFOO: string @timoni(runtime:string:testfoo)
                        }
                    }
                    service: main: {
                        controller: "main"
                        ports: http: {
                            // TODO
                            port: 9898
                            protocol: "HTTP"
                        }
                    }
                    ingress: main: {
                        hosts: [{
                            // TODO domain from runtime
                            host: "blog.127-0-0-1.nip.io"
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
