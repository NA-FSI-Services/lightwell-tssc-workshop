{{/*
Common labels for RHDH chart resources.
*/}}
{{- define "rhdh.labels" -}}
demo.redhat.com/application: "lightwell-tssc-workshop"
app.kubernetes.io/name: rhdh
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
app.kubernetes.io/part-of: lightwell-tssc-workshop
{{- end -}}

{{/*
External base URL for Developer Hub (route host pattern used by the Operator).
*/}}
{{- define "rhdh.baseUrl" -}}
{{- if .Values.appConfig.baseUrl -}}
{{- .Values.appConfig.baseUrl -}}
{{- else if .Values.deployer.domain -}}
{{- /* RHDH Operator Route host: backstage-<cr-name>-<namespace>.<apps-domain> */ -}}
https://backstage-{{ .Values.rhdh.name }}-{{ .Values.rhdh.namespace }}.{{ .Values.deployer.domain }}
{{- else -}}
https://backstage-{{ .Values.rhdh.name }}-{{ .Values.rhdh.namespace }}.apps.cluster.example.com
{{- end -}}
{{- end -}}

