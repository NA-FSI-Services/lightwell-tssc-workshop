{{- define "spring-boot-lw-poc.labels" -}}
demo.redhat.com/application: "lightwell-tssc-workshop"
app.kubernetes.io/name: spring-boot-lw-poc
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
app.kubernetes.io/part-of: lightwell-tssc-workshop
{{- end -}}

{{- define "spring-boot-lw-poc.routeHost" -}}
{{- if .Values.route.host -}}
{{- .Values.route.host -}}
{{- else if .Values.deployer.domain -}}
{{ .Values.springBootLwPoc.name }}-{{ .Values.springBootLwPoc.namespace }}.{{ .Values.deployer.domain }}
{{- else -}}
{{ .Values.springBootLwPoc.name }}-{{ .Values.springBootLwPoc.namespace }}.apps.cluster.example.com
{{- end -}}
{{- end -}}

{{- define "spring-boot-lw-poc.appUrl" -}}
https://{{ include "spring-boot-lw-poc.routeHost" . }}
{{- end -}}

{{- define "spring-boot-lw-poc.imageRepository" -}}
{{- if .Values.image.repository -}}
{{- .Values.image.repository -}}
{{- else -}}
{{ .Values.image.registry }}/{{ .Values.springBootLwPoc.namespace }}/{{ .Values.image.name }}
{{- end -}}
{{- end -}}

{{- /* Prefer digest when set (Module 5 Ex4 / #100 promote); else tag. */ -}}
{{- define "spring-boot-lw-poc.imageRef" -}}
{{- $repo := include "spring-boot-lw-poc.imageRepository" . -}}
{{- if .Values.image.digest -}}
{{ $repo }}@{{ .Values.image.digest }}
{{- else -}}
{{ $repo }}:{{ .Values.image.tag }}
{{- end -}}
{{- end -}}
