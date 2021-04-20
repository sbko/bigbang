# Monitioring

## Overview
Monioring in Bibang is deployed using the upstream chart  [kube-prometheus-stack](https://github.com/prometheus-community/helm-charts/charts/kube-prometheus-stack)

## Contents

[Developer Guide](docs/developer-guide.md)

## Big Bang Touchpoints

### Dependency Packages

By default BigBang  installs additional, dependent charts:
* kubernetes/kube-state-metrics
* prometheus-community/prometheus-node-exporter
* grafana/grafana

### Storage
#### Alert Manager
Persistent storage values for Alert Manager can be set/modified  in the bigbang chart:

```yaml
alertmanager:
  storage:
    volumeClaimTemplate:
       spec:
          storageClassName: 
          accessModes: ["ReadWriteOnce"]
          resources:
            requests:
              storage: 50Gi
        selector: {}
```

#### Prometheus-Operator
Persistent storage values for Prometheus-Operator can be set/modified  in the bigbang chart:

```yaml
prometheusSpec:
  storageSpec:
    volumeClaimTemplate:
       spec:
          storageClassName: 
          accessModes: ["ReadWriteOnce"]
          resources:
            requests:
              storage: 50Gi
        selector: {}
```

### Logging

## Single Sign on (SSO)

SSO can be configured for monitoring  following the documentation provided. \
[Monitoring SSO Integration](https://repo1.dso.mil/platform-one/big-bang/apps/core/monitoring/-/blob/main/docs/KEYCLOAK.md)

## Monitoring
Monitoring deployment has serviceMonitors enabled for
* core-dns
* kube-api-server
* kube-controller-manager
* kube-dns
* kube-etcd
* kube-proxy
* kube-scheduler
* kube-state-metrics
*  kubelet
* node-exporter







