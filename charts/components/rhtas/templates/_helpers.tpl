{{/*
Common labels for RHTAS chart resources.
*/}}
{{- define "rhtas.labels" -}}
demo.redhat.com/application: "lightwell-tssc-workshop"
app.kubernetes.io/name: rhtas
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
app.kubernetes.io/part-of: lightwell-tssc-workshop
{{- end -}}

{{/*
Fulcio commonName — defaults to fulcio.<deployer.domain> when unset.
*/}}
{{- define "rhtas.fulcioCommonName" -}}
{{- if .Values.securesign.fulcio.commonName -}}
{{- .Values.securesign.fulcio.commonName -}}
{{- else if .Values.deployer.domain -}}
fulcio.{{ .Values.deployer.domain }}
{{- else -}}
fulcio.hostname
{{- end -}}
{{- end -}}

{{/*
Optional Keycloak issuer URL.
*/}}
{{- define "rhtas.keycloakIssuer" -}}
{{- if .Values.oidc.keycloak.issuerURL -}}
{{- .Values.oidc.keycloak.issuerURL -}}
{{- else if .Values.deployer.domain -}}
https://sso.{{ .Values.deployer.domain }}/realms/{{ .Values.oidc.keycloak.realm }}
{{- else -}}
https://sso.apps.cluster.example.com/realms/{{ .Values.oidc.keycloak.realm }}
{{- end -}}
{{- end -}}
