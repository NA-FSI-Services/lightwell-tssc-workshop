{{- define "keycloak.labels" -}}
demo.redhat.com/application: "lightwell-tssc-workshop"
app.kubernetes.io/name: keycloak
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
app.kubernetes.io/part-of: lightwell-tssc-workshop
{{- end -}}

{{- define "keycloak.routeHost" -}}
{{- if .Values.deployer.domain -}}
{{ .Values.keycloak.routeHostPrefix }}.{{ .Values.deployer.domain }}
{{- else -}}
{{ .Values.keycloak.routeHostPrefix }}.apps.cluster.example.com
{{- end -}}
{{- end -}}

{{- define "keycloak.url" -}}
https://{{ include "keycloak.routeHost" . }}
{{- end -}}

{{- define "keycloak.issuerUrl" -}}
{{ include "keycloak.url" . }}/realms/{{ .Values.oidc.realm }}
{{- end -}}
