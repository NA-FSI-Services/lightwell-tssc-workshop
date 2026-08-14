{{- define "fastapi-lw-poc.labels" -}}
demo.redhat.com/application: "lightwell-tssc-workshop"
app.kubernetes.io/name: fastapi-lw-poc
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
app.kubernetes.io/part-of: lightwell-tssc-workshop
{{- end -}}

{{- define "fastapi-lw-poc.routeHost" -}}
{{- if .Values.route.host -}}
{{- .Values.route.host -}}
{{- else if .Values.deployer.domain -}}
{{ .Values.fastapiLwPoc.name }}-{{ .Values.fastapiLwPoc.namespace }}.{{ .Values.deployer.domain }}
{{- else -}}
{{ .Values.fastapiLwPoc.name }}-{{ .Values.fastapiLwPoc.namespace }}.apps.cluster.example.com
{{- end -}}
{{- end -}}

{{- define "fastapi-lw-poc.appUrl" -}}
https://{{ include "fastapi-lw-poc.routeHost" . }}
{{- end -}}

{{- define "fastapi-lw-poc.imageRepository" -}}
{{- if .Values.image.repository -}}
{{- .Values.image.repository -}}
{{- else -}}
{{ .Values.image.registry }}/{{ .Values.fastapiLwPoc.namespace }}/{{ .Values.image.name }}
{{- end -}}
{{- end -}}

{{- /* Prefer digest when set (Module 9 promote); else tag. */ -}}
{{- define "fastapi-lw-poc.imageRef" -}}
{{- $repo := include "fastapi-lw-poc.imageRepository" . -}}
{{- if .Values.image.digest -}}
{{ $repo }}@{{ .Values.image.digest }}
{{- else -}}
{{ $repo }}:{{ .Values.image.tag }}
{{- end -}}
{{- end -}}
