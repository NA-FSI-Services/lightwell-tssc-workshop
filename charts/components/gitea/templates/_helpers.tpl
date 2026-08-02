{{- define "gitea.labels" -}}
demo.redhat.com/application: "lightwell-tssc-workshop"
app.kubernetes.io/name: gitea
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
app.kubernetes.io/part-of: lightwell-tssc-workshop
{{- end -}}

{{- define "gitea.routeHost" -}}
{{- if .Values.deployer.domain -}}
{{ .Values.gitea.routeHostPrefix }}.{{ .Values.deployer.domain }}
{{- else -}}
{{ .Values.gitea.routeHostPrefix }}.apps.cluster.example.com
{{- end -}}
{{- end -}}

{{- define "gitea.url" -}}
https://{{ include "gitea.routeHost" . }}
{{- end -}}

{{- define "gitea.primaryStudent" -}}
{{- $s := index .Values.students 0 -}}
{{- $s.username -}}
{{- end -}}

{{- define "gitea.primaryStudentRepoUrl" -}}
{{ include "gitea.url" . }}/{{ include "gitea.primaryStudent" . }}/{{ .Values.seed.repoName }}.git
{{- end -}}
