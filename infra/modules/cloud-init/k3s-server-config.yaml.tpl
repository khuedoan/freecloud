%{ if server_address == "" }
cluster-init: true
%{ else }
server: https://${server_address}:6443
%{ endif }
node-taint:
- node-role.kubernetes.io/master=true:NoSchedule
disable-cloud-controller: true
disable:
- local-storage
- servicelb
- traefik
token: ${token}
