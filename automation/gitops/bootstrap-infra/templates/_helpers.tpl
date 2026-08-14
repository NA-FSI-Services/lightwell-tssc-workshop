{{/*
Common labels for ArgoCD Applications managed by this App-of-Apps chart.
*/}}
{{- define "root-app.labels" -}}
demo.redhat.com/application: "lightwell-tssc-workshop"
app.kubernetes.io/managed-by: {{ .Release.Service }}
app.kubernetes.io/part-of: lightwell-tssc-workshop
{{- end -}}
