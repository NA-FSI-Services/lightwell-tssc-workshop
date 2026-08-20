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

{{- define "lightwell-repo.nexusInternalUrl" -}}
http://{{ .Values.nexus.name }}.{{ .Values.lightwellRepo.namespace }}.svc:8081
{{- end -}}

{{- define "lightwell-repo.nexusUrl" -}}
{{- if .Values.mavenSettings.nexusUrl -}}
{{- .Values.mavenSettings.nexusUrl -}}
{{- else if .Values.pipSettings.nexusUrl -}}
{{- .Values.pipSettings.nexusUrl -}}
{{- else -}}
https://{{ include "lightwell-repo.nexusHost" . }}
{{- end -}}
{{- end -}}

{{/* Docker Registry API host for oc-mirror dest (dedicated Route, not the Nexus UI). */}}
{{- define "lightwell-repo.registryHost" -}}
{{- if .Values.deployer.domain -}}
registry-{{ .Values.lightwellRepo.namespace }}.{{ .Values.deployer.domain }}
{{- else -}}
registry-{{ .Values.lightwellRepo.namespace }}.apps.cluster.example.com
{{- end -}}
{{- end -}}

{{- define "lightwell-repo.registryUrl" -}}
https://{{ include "lightwell-repo.registryHost" . }}
{{- end -}}

{{/* In-cluster Docker Registry API (Service). Route dest_registry_host is blocked after 4.3. */}}
{{- define "lightwell-repo.registryInternalHost" -}}
{{ .Values.nexus.name }}.{{ .Values.lightwellRepo.namespace }}.svc:{{ .Values.nexus.docker.port }}
{{- end -}}
