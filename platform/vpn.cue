bundle: {
	apiVersion: "v1alpha1"
	name:       "vpn"
	instances: {
		"wireguard": {
			module: url: "oci://ghcr.io/stefanprodan/modules/flux-helm-release"
			namespace: "wireguard"
			values: {
				repository: url: "https://bjw-s.github.io/helm-charts"
				chart: {
					name:    "app-template"
					version: "3.1.0"
				}
				helmValues: {
					controllers: main: containers: app: {
						image: {
							repository: "lscr.io/linuxserver/wireguard"
							tag:        "latest"
						}
						env: {
							// TODO better way to do this?
							// Currently have to run wg genkey manually
							PRIVATE_KEY: string @timoni(runtime:string:wireguard_private_key)
						}
						securityContext: capabilities: add: [
							"NET_ADMIN",
						]
					}
					// TODO how to sync this between peers?
					// TODO set address dynamically from env
					// TODO separate dev and prod
					configMaps: config: data: "wg0.conf": """
						[Interface]
						Address = 10.13.13.1
						ListenPort = 51820
						PostUp = wg set %i private-key <(echo ${PRIVATE_KEY}); iptables -A FORWARD -i %i -j ACCEPT; iptables -A FORWARD -o %i -j ACCEPT; iptables -t nat -A POSTROUTING -o eth+ -j MASQUERADE
						PostDown = iptables -D FORWARD -i %i -j ACCEPT; iptables -D FORWARD -o %i -j ACCEPT; iptables -t nat -D POSTROUTING -o eth+ -j MASQUERADE

						[Peer]
						# Horus
						PublicKey = +0Ke3rl5BDa3a/dk9Vv18a1bnT9rIX8kmcpONwcSM1U=
						AllowedIPs = 10.13.13.1/32

						[Peer]
						# Test device
						PublicKey = 7lFchoAJ8BOazhTNnRfF20kmpEaGGFus782FGFhnEgs=
						AllowedIPs = 10.13.13.2/32
						"""
					persistence: config: {
						type:       "configMap"
						identifier: "config"
						globalMounts: [{
							path:    "/config/wg_confs/wg0.conf"
							subPath: "wg0.conf"
						}]
					}
					service: main: {
						controller: "main"
						type:       "LoadBalancer"
						ports: wireguard: {
							port:     51820
							protocol: "UDP"
						}
					}
				}
			}
		}
	}
}
