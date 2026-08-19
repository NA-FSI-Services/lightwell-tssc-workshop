{{/*
Common labels and derived names for validate-jobs.
*/}}
{{- define "validate-jobs.labels" -}}
demo.redhat.com/application: "lightwell-tssc-workshop"
app.kubernetes.io/name: validate-jobs
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
app.kubernetes.io/part-of: lightwell-tssc-workshop
{{- end -}}

{{- define "validate-jobs.jobName" -}}
validate-{{ .id }}-{{ .slug }}
{{- end -}}

{{- define "validate-jobs.reportName" -}}
report-{{ .id }}-{{ .slug }}
{{- end -}}
