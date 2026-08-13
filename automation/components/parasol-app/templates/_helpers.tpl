{{- define "parasol-app.labels" -}}
demo.redhat.com/application: "lightwell-tssc-workshop"
app.kubernetes.io/name: parasol-app
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
app.kubernetes.io/part-of: lightwell-tssc-workshop
{{- end -}}

{{- define "parasol-app.nexusUrl" -}}
{{- if .Values.lightwell.nexusUrl -}}
{{- .Values.lightwell.nexusUrl -}}
{{- else if .Values.deployer.domain -}}
https://nexus-lightwell-repo.{{ .Values.deployer.domain }}
{{- else -}}
https://nexus-lightwell-repo.apps.cluster.example.com
{{- end -}}
{{- end -}}

{{- define "parasol-app.routeHost" -}}
{{- if .Values.route.host -}}
{{- .Values.route.host -}}
{{- else if .Values.deployer.domain -}}
parasol-{{ .Values.parasolApp.namespace }}.{{ .Values.deployer.domain }}
{{- else -}}
parasol-{{ .Values.parasolApp.namespace }}.apps.cluster.example.com
{{- end -}}
{{- end -}}

{{- define "parasol-app.appUrl" -}}
https://{{ include "parasol-app.routeHost" . }}
{{- end -}}

{{- define "parasol-app.routeTarget" -}}
{{- if and (eq .Values.route.target "frontend") .Values.frontend.enabled -}}
{{ .Values.frontend.name }}
{{- else -}}
{{ .Values.backend.name }}
{{- end -}}
{{- end -}}
