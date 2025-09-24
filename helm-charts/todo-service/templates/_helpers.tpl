{{/*
Expand the name of the chart.
*/}}
{{- define "todo-service.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "todo-service.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.nameOverride }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "todo-service.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "todo-service.labels" -}}
helm.sh/chart: {{ include "todo-service.chart" . }}
{{ include "todo-service.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "todo-service.selectorLabels" -}}
app.kubernetes.io/name: {{ include "todo-service.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "todo-service.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "todo-service.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Database connection string helper
*/}}
{{- define "todo-service.connectionString" -}}
{{- if .Values.secrets.postgresConnectionString }}
{{- .Values.secrets.postgresConnectionString }}
{{- else if .Values.database.connectionString }}
{{- .Values.database.connectionString }}
{{- else }}
{{- printf "Host=%s;Port=%d;Database=%s;Username=%s;Password=%s;SSL Mode=%s;Trust Server Certificate=%t;Pooling=%t;Minimum Pool Size=%d;Maximum Pool Size=%d;Connection Lifetime=%d;Timeout=%d;" 
    .Values.database.host 
    .Values.database.port 
    .Values.database.name 
    .Values.secrets.postgresUser 
    .Values.secrets.postgresPassword 
    .Values.database.sslMode 
    .Values.database.trustServerCertificate 
    .Values.database.pooling 
    .Values.database.minPoolSize 
    .Values.database.maxPoolSize 
    .Values.database.connectionLifetime 
    .Values.database.connectionTimeout }}
{{- end }}
{{- end }}