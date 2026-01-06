
variable "namespace" {
  type    = string
  default = "default"
}

variable "cluster_name" {
  type    = string
  default = "firevault-cluster"
}

variable "destinations_prometheus_url" {
  type    = string
  default = "https://prometheus-prod-55-prod-gb-south-1.grafana.net./api/prom/push"
}

variable "destinations_prometheus_username" {
  type    = string
  default = "2896915"
}

variable "destinations_prometheus_password" {
  type    = string
  default = "glc_eyJvIjoiMTYzMzE2OCIsIm4iOiJzdGFjay0xNDg2MzQxLWludGVncmF0aW9uLWZpcmV2YXVsdC1ncmFmYW5hLXRva2VuLWZpcmV2YXVsdC1ncmFmYW5hLXRva2VuIiwiayI6IjZkMGhqQTBVSUY5REtuNDBiVTZtNzQxbiIsIm0iOnsiciI6InByb2QtZ2Itc291dGgtMSJ9fQ=="
}

variable "destinations_loki_url" {
  type    = string
  default = "https://logs-prod-035.grafana.net./loki/api/v1/push"
}

variable "destinations_loki_username" {
  type    = string
  default = "1444134"
}

variable "destinations_loki_password" {
  type    = string
  default = "glc_eyJvIjoiMTYzMzE2OCIsIm4iOiJzdGFjay0xNDg2MzQxLWludGVncmF0aW9uLWZpcmV2YXVsdC1ncmFmYW5hLXRva2VuLWZpcmV2YXVsdC1ncmFmYW5hLXRva2VuIiwiayI6IjZkMGhqQTBVSUY5REtuNDBiVTZtNzQxbiIsIm0iOnsiciI6InByb2QtZ2Itc291dGgtMSJ9fQ=="
}

variable "destinations_otlp_url" {
  type    = string
  default = "https://otlp-gateway-prod-gb-south-1.grafana.net./otlp"
}

variable "destinations_otlp_username" {
  type    = string
  default = "1486341"
}

variable "destinations_otlp_password" {
  type    = string
  default = "glc_eyJvIjoiMTYzMzE2OCIsIm4iOiJzdGFjay0xNDg2MzQxLWludGVncmF0aW9uLWZpcmV2YXVsdC1ncmFmYW5hLXRva2VuLWZpcmV2YXVsdC1ncmFmYW5hLXRva2VuIiwiayI6IjZkMGhqQTBVSUY5REtuNDBiVTZtNzQxbiIsIm0iOnsiciI6InByb2QtZ2Itc291dGgtMSJ9fQ=="
}

variable "fleetmanagement_url" {
  type    = string
  default = "https://fleet-management-prod-023.grafana.net"
}

variable "fleetmanagement_username" {
  type    = string
  default = "1486341"
}

variable "fleetmanagement_password" {
  type    = string
  default = "glc_eyJvIjoiMTYzMzE2OCIsIm4iOiJzdGFjay0xNDg2MzQxLWludGVncmF0aW9uLWZpcmV2YXVsdC1ncmFmYW5hLXRva2VuLWZpcmV2YXVsdC1ncmFmYW5hLXRva2VuIiwiayI6IjZkMGhqQTBVSUY5REtuNDBiVTZtNzQxbiIsIm0iOnsiciI6InByb2QtZ2Itc291dGgtMSJ9fQ=="
}
