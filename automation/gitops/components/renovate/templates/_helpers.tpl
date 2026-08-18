{{- define "renovate.labels" -}}
demo.redhat.com/application: "lightwell-tssc-workshop"
app.kubernetes.io/name: renovate
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
app.kubernetes.io/part-of: lightwell-tssc-workshop
{{- end -}}

{{- define "renovate.giteaEndpoint" -}}
{{- .Values.gitea.endpoint | default "http://gitea.gitea.svc:3000" -}}
{{- end -}}

{{- define "renovate.mavenUrl" -}}
http://{{ .Values.nexus.name }}.{{ .Values.nexus.namespace }}.svc:{{ .Values.nexus.httpPort }}/repository/{{ .Values.nexus.mavenRepository }}/
{{- end -}}

{{- define "renovate.destRegistryHost" -}}
{{- if .Values.deployer.domain -}}
registry-{{ .Values.nexus.namespace }}.{{ .Values.deployer.domain }}
{{- else -}}
registry-{{ .Values.nexus.namespace }}.apps.cluster.example.com
{{- end -}}
{{- end -}}

{{- define "renovate.imagePullHost" -}}
{{- $repo := .Values.image.repository -}}
{{- $host := splitList "/" $repo | first -}}
{{- $host -}}
{{- end -}}
