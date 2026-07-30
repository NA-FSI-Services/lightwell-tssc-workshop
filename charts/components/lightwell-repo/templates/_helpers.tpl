{{/*
Common labels for lightwell-repo chart resources.
*/}}
{{- define "lightwell-repo.labels" -}}
demo.redhat.com/application: "lightwell-tssc-workshop"
app.kubernetes.io/name: lightwell-repo
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
app.kubernetes.io/part-of: lightwell-tssc-workshop
{{- end -}}

{{- define "lightwell-repo.nexusHost" -}}
{{- if .Values.nexus.route.host -}}
{{- .Values.nexus.route.host -}}
{{- else if .Values.deployer.domain -}}
{{ .Values.nexus.name }}-{{ .Values.lightwellRepo.namespace }}.{{ .Values.deployer.domain }}
{{- else -}}
{{ .Values.nexus.name }}-{{ .Values.lightwellRepo.namespace }}.apps.cluster.example.com
{{- end -}}
{{- end -}}

{{- define "lightwell-repo.nexusUrl" -}}
{{- if .Values.mavenSettings.nexusUrl -}}
{{- .Values.mavenSettings.nexusUrl -}}
{{- else -}}
https://{{ include "lightwell-repo.nexusHost" . }}
{{- end -}}
{{- end -}}
