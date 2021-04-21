# Monitioring

## Overview
Monioring in Bibang is deployed using the upstream chart  [kube-prometheus-stack](https://github.com/prometheus-community/helm-charts/charts/kube-prometheus-stack)

## Contents

[Developer Guide](docs/developer-guide.md)

## Big Bang Touchpoints

 ```mermaid
graph LR
  subgraph "Monitoring"
    alertmanager{{Alert Manager}} --> alertmanagerpods("AlertManager Pod(s)")
    svcmonitor("Service Monitor") --"Metrics Port"--> alertmanager
    Prometheus --> alertsvcmonitor("Service Monitor")
    grafana{{Grafana}} --> grafanapods("Grafana  Pod(s)")
    grafana{{Grafana}} --> grafanasvcmonitor("Service Monitor")
    prometheus{{Prometheus}} --> prometheuspods("Prometheus Pod(s)")
    prometheus{{Prometheus}} --> prometheussvcmonitor("Service Monitor")
    prometheus-operator{{Prometheus-Operator}} --> prometheusoperatorpods("PrometheusOperator Pod(s)")
    prometheus-operator{{Prometheus-Operator}} --> prometheusoperatorsvcmonitor("Service Monitor")
    prometheus-node-exporter{{Prometheus-Node-Exporter}} --> prometheusnodeexporterpods("PrometheusNodeExporter Pod(s)")
    prometheus-node-exporter{{Prometheus-Node-Exporter}} --> prometheusnodeexportersvcmonitor("Service Monitor")
    kube-state-metrics{{Kube-State-Metrics}} --> kubestatemetricspods("KubeStateMetrics Pod(s)")
    kube-state-metrics{{Kube-State-Metrics}} --> kubestatemetricssvcmonitor("Service Monitor")
    kube-prometheus-prometheus{{Kube-Prometheus-Prometheus}} --> kubeprometheusprometheuspod("KubePrometheusPromectheus Pods")
   kube-prometheus-prometheus{{Kube-Prometheus-Prometheus}} --> kubeprometheusprometheussvcmonitor("Service Monitor")

  end      

  subgraph "Ingress"
    ig(Ingress Gateway) --"App Port"--> alertmanager
    ig(Ingress Gateway) --"App Port"--> grafana
     ig(Ingress Gateway) --"App Port"--> prometheus
     
  end


  subgraph "Logging"
    monitoringpods("Monitoring Pod(s)") --"Logs"--> fluent(Fluentbit) --> logging-ek-es-http
    logging-ek-es-http{{Elastic Service<br />logging-ek-es-http}} --> elastic[(Elastic Storage)]
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








