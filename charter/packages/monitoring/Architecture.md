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
    kubestatemetricspods("Kube-State-Metrics Pod(s)") --> monitoringpods("Monitoring Pod(s)")
    kubestatemetricsservice{{Kube-State-Metrics Service}} -->  kubestatemetricspods("Kube-State-Metrics Pod(s)")
    kubestatemetricssvcmonitor("Service Monitor") --"Metrics Port"-->  kubestatemetricsservice
    Prometheus --> kubestatemetricssvcmonitor("Service Monitor")
    kubeprometheuspods("Kube-Prometheus-Prometheus Pod(s)") --> monitoringpods("Monitoring Pod(s)")
    kubeprometheusservice{{Kube-Prometheus-Prometheus Service}} -->  kubeprometheuspods("Kube-Prometheus-Prometheus Pod(s)")
    kubeprometheussvcmonitor("Service Monitor") --"Metrics Port"-->  kubeprometheusservice
    Prometheus --> kubeprometheussvcmonitor("Service Monitor")
  end

  subgraph "Logging"
    monitoringpods("Monitoring Pod(s)") --"Logs"--> fluent(Fluentbit) --> logging-ek-es-http
    logging-ek-es-http{{Elastic Service<br />logging-ek-es-http}} --> elastic[(Elastic Storage)]
  end
  subgraph "Ingress"
    ig(Ingress Gateway) --"App Port"--> alertmanagerservice
    ig(Ingress Gateway) --"App Port"--> grafanaservice
    ig(Ingress Gateway) --"App Port"--> kubeprometheusservice
  end 
  
```   
### UI

Monitoring deployment in BigBang provides web UI for Alert Manager, Prometheus and Grafana

### Istio Configuration

Istio is disabled in the monitoring chart by default and can be enabled by setting the following values in the bigbang chart:

```yaml
hostname: bigbang.dev
istio:
  enabled: true
```

Within the Big Bang chart the external URLs for prometheus, grafana, and alertmanager


### Storage
#### Alert Manager
Persistent storage values for Alert Manager can be set/modified in the Big Bang chart:

```yaml
monitoring:
  values:
    alertmanager:
      alertmanagerSpec:
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
Persistent storage values for Prometheus-Operator can be set/modified in the Big Bang chart:

```yaml
monitoring:
  values:
    prometheus:
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

#### Grafana
Persistent storage values for Grafana can be set/modified in the Big Bang chart:

```yaml
monitoring:
  values:
    grafana:
      persistence:
        type: pvc
        enabled: false
        # storageClassName: default
        accessModes:
          - ReadWriteOnce
        size: 10Gi
        # annotations: {}
        finalizers:
          - kubernetes.io/pvc-protection
        # selectorLabels: {}
        # subPath: ""
        # existingClaim:
```

### Logging

Within the kube-prometheus-stack chart you can customize both the LogFormat and LogLevel for the following components within the chart:
Note: within Big Bang, logs are captured by fluentbit and shipped to elastic by default.

#### Prometheus-Operator
LogFormat and LogLevel can be set for Prometheus-Operator via the following values in the Big Bang chart:
```yaml
monitoring:
  values:
    prometheusOperator:
      logFormat: logfmt
      logLevel: info
```

#### Prometheus
LogFormat and LogLevel can be set for Prometheus via the following values in the Big Bang chart:
```yaml
monitoring:
  values:
    prometheus:
      prometheusSpec:
         logFormat: logfmt
         logLevel: info
```

#### Alertmanager
LogFormat and LogLevel can be set for Alertmanager via the following values in the Big Bang chart:
```yaml
monitoring:
  values:
    alertmanager:
      alertmanagerSpec:
        logFormat: logfmt
         logLevel: info
```

#### Grafana
LogLevel can be set for Grafana via the following values in the Big Bang chart:
```yaml
monitoring:
  values:
    grafana:
      grafana.ini:
        log:
          mode: console
```

## Single Sign on (SSO)

SSO can be configured for monitoring through Authservice, more info is included in the following the documentation. \
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

High Availability can be accomplished by increasing the number of replicas for the deployments of Alertmanager, Prometheus and Grafana:

```yaml
monitoring:
  values:
    alertmanager:
      alertmanagerSpec:
        replicas:
    prometheus:
      prometheusSpec:
        replicas:
    grafana:
      replicas:
```

### Dependency Packages

By default BigBang  installs additional, dependent charts:
* kubernetes/kube-state-metrics
* prometheus-community/prometheus-node-exporter
* grafana/grafana


