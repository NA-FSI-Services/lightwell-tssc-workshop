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
