{{- define "gateway-service.name" -}}
{{- default .Chart.Name .Values.nameOverride -}}
{{- end -}}

{{- define "gateway-service.fullname" -}}
{{- printf "%s-%s" .Release.Name (include "gateway-service.name" .) | trunc 63 | trimSuffix "-" -}}
{{- end -}}
