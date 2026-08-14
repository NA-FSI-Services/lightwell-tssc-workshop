{{- define "showroom.labels" -}}
demo.redhat.com/application: "lightwell-tssc-workshop"
app.kubernetes.io/name: showroom
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
app.kubernetes.io/part-of: lightwell-tssc-workshop
{{- end -}}

{{/*
Route host — RHDP userinfo pattern showroom.<deployer.domain>
*/}}
{{- define "showroom.routeHost" -}}
{{- if .Values.deployer.domain -}}
{{ .Values.showroom.name }}.{{ .Values.deployer.domain }}
{{- else -}}
{{ .Values.showroom.name }}.apps.cluster.example.com
{{- end -}}
{{- end -}}

{{- define "showroom.url" -}}
https://{{ include "showroom.routeHost" . }}
{{- end -}}
