{{- define "todo-service.name" -}}
todo-service
{{- end }}

{{- define "todo-service.fullname" -}}
{{ include "todo-service.name" . }}-{{ .Release.Name }}
{{- end }}
