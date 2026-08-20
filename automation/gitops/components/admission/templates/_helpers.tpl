{{/*
Common labels for admission chart resources.
*/}}
{{- define "admission.labels" -}}
demo.redhat.com/application: "lightwell-tssc-workshop"
app.kubernetes.io/name: admission
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
app.kubernetes.io/part-of: lightwell-tssc-workshop
{{- end -}}

{{- define "admission.tufUrlHint" -}}
{{- if .Values.deployer.domain -}}
{{ printf "https://tuf-%s.%s" .Values.rhtas.namespace .Values.deployer.domain }}
{{- else -}}
http://{{ .Values.rhtas.tufService }}.{{ .Values.rhtas.namespace }}.svc:{{ .Values.rhtas.tufPort }}
{{- end -}}
{{- end -}}

{{- define "admission.fulcioUrlHint" -}}
{{- if .Values.deployer.domain -}}
{{ printf "https://fulcio-server-%s.%s" .Values.rhtas.namespace .Values.deployer.domain }}
{{- end -}}
{{- end -}}

{{- define "admission.rekorUrlHint" -}}
{{- if .Values.deployer.domain -}}
{{ printf "https://rekor-server-%s.%s" .Values.rhtas.namespace .Values.deployer.domain }}
{{- end -}}
{{- end -}}
