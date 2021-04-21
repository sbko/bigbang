# Monitioring

## Overview
Monioring in Bibang is deployed using the upstream chart  [kube-prometheus-stack](https://github.com/prometheus-community/helm-charts/charts/kube-prometheus-stack)

## Contents

[Developer Guide](docs/developer-guide.md)

## Big Bang Touchpoints

 ```mermaid
graph LR
  subgraph "Monitoring"
    alertmanagerpods("AlertManager Pod(s)") --> monitoringpods("Monitoring Pod(s)")
    alertmanagerservice{{AlertManager Service}} --> alertmanagerpods("AlertManager Pod(s)")
    alertmanagersvcmonitor("Service Monitor") --"Metrics Port"--> alertmanagerservice
    Prometheus --> alertmanagersvcmonitor("Service Monitor")
    grafanapods("Grafana Pod(s)") --> monitoringpods("Monitoring Pod(s)")
    grafanaservice{{Grafana Service}} --> grafanapods("Grafana Pod(s)")
    grafanasvcmonitor("Service Monitor") --"Metrics Port"--> grafanaservice
    Prometheus --> grafanasvcmonitor("Service Monitor")
    prometheusoperatorpods("Prometheus-Operator Pod(s)") --> monitoringpods("Monitoring Pod(s)")
    prometheusoperatorservice{{Prometheus-Operator Service}} -->  prometheusoperatorpods("Prometheus-Operator Pod(s)")
    prometheusoperatorsvcmonitor("Service Monitor") --"Metrics Port"--> prometheusoperatorservice
    Prometheus --> prometheusoperatorsvcmonitor("Service Monitor")
    nodeexporterpods("Node-Exporter Pod(s)") --> monitoringpods("Monitoring Pod(s)")
    nodeexporterservice{{Node-Exporter Service}} -->  nodeexporterpods("Node-Exporter Pod(s)")
    nodeexportersvcmonitor("Service Monitor") --"Metrics Port"-->  nodeexporterservice
    Prometheus --> nodeexportersvcmonitor("Service Monitor")
    kubestatemetricspods("Kube-State-Metrics Pod(s)") --> kubestatemetricspods("Monitoring Pod(s)")
    kubestatemetricsservice{{Kube-State-Metrics Service}} --> kubestatemetricspods("Kube-State-Metrics Pod(s)")
    kubestatemetricssvcmonitor("Service Monitor") --"Metrics Port"-->  kubestatemetricsservice
    Prometheus --> kubestatemetricssvcmonitor("Service Monitor")
    kubeprometheusprometheuspods("Kube-Prometheus-Prometheus Pod(s)") --> kubeprometheusprometheuspods("Monitoring Pod(s)")
    kubeprometheusprometheusservice{{Kube-Prometheus-Prometheus Service}} --> kubestatemetricspods("Kube-Prometheus-Prometheus Pod(s)")
    kubeprometheusprometheussvcmonitor("Service Monitor") --"Metrics Port"-->  kubeprometheusprometheusservice
    Prometheus --> kubeprometheusprometheussvcmonitor("Service Monitor")

    
  end
  
```   
### UI

Monitoring deployment in BigBang provides web UI for Alert Manager, Prometheus and Grafana

### Istio Configuration

Istio is disabled in the monitoring
 chart by default and can be enabled by setting the following values in the bigbang chart:

```yaml
hostname: bigbang.dev
istio:
  enabled: true
```

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

Mattermost provides access to the system logs via the "System Console" (under "Server Logs"). The UI provides a basic search functionality as well for these logs

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
* alert manager
* grafana
* prometheus
* prometheus-operator
* node-exporter

### HA

High Availability can be accomplished by increasing the number of replicas in the deployment.

```yaml
alertmanagerSpec:
  replicas:
prometheus:
  replicas:
```








