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

{{/* Operator-prepared template org (monorepo isolation). Learners do not edit these. */}}
{{- define "gitea.templatesOrgName" -}}
{{- .Values.seed.templates.org | default "workshop-templates" -}}
{{- end -}}

{{/* Learner-owned org convention: lw-<username> (created by the student in Module 2). */}}
{{- define "gitea.learnerOrgName" -}}
{{- $user := . -}}
{{- printf "lw-%s" $user -}}
{{- end -}}

{{- define "gitea.primaryStudent" -}}
{{- $s := index .Values.students 0 -}}
{{- $s.username -}}
{{- end -}}

{{- define "gitea.studentAppRepoUrl" -}}
{{- $root := index . 0 -}}
{{- $user := index . 1 -}}
{{- $org := include "gitea.learnerOrgName" $user -}}
{{- printf "%s/%s/%s.git" (include "gitea.url" $root) $org $root.Values.seed.repoName -}}
{{- end -}}

{{- define "gitea.studentGitopsRepoUrl" -}}
{{- $root := index . 0 -}}
{{- $user := index . 1 -}}
{{- $org := include "gitea.learnerOrgName" $user -}}
{{- $repo := $root.Values.seed.gitops.repoName | default "gitops-spring-boot-lw-poc" -}}
{{- printf "%s/%s/%s.git" (include "gitea.url" $root) $org $repo -}}
{{- end -}}

{{- define "gitea.templateAppRepoUrl" -}}
{{- printf "%s/%s/%s.git" (include "gitea.url" .) (include "gitea.templatesOrgName" .) .Values.seed.repoName -}}
{{- end -}}

{{- define "gitea.templateGitopsRepoUrl" -}}
{{- $repo := .Values.seed.gitops.repoName | default "gitops-spring-boot-lw-poc" -}}
{{- printf "%s/%s/%s.git" (include "gitea.url" .) (include "gitea.templatesOrgName" .) $repo -}}
{{- end -}}

{{- define "gitea.templateSkeletonRepoUrl" -}}
{{- $repo := .Values.seed.templates.skeleton.repoName | default "lightwell-java-service" -}}
{{- printf "%s/%s/%s.git" (include "gitea.url" .) (include "gitea.templatesOrgName" .) $repo -}}
{{- end -}}

{{- define "gitea.templatePythonSkeletonRepoUrl" -}}
{{- $repo := .Values.seed.templates.skeletonPython.repoName | default "lightwell-python-service" -}}
{{- printf "%s/%s/%s.git" (include "gitea.url" .) (include "gitea.templatesOrgName" .) $repo -}}
{{- end -}}

{{/* Python track (#147) — parallel keys; do not overwrite Java student_repo_url. */}}
{{- define "gitea.studentPythonAppRepoUrl" -}}
{{- $root := index . 0 -}}
{{- $user := index . 1 -}}
{{- $org := include "gitea.learnerOrgName" $user -}}
{{- $repo := $root.Values.seed.python.repoName | default "fastapi-lw-poc" -}}
{{- printf "%s/%s/%s.git" (include "gitea.url" $root) $org $repo -}}
{{- end -}}

{{- define "gitea.studentPythonGitopsRepoUrl" -}}
{{- $root := index . 0 -}}
{{- $user := index . 1 -}}
{{- $org := include "gitea.learnerOrgName" $user -}}
{{- $repo := $root.Values.seed.python.gitops.repoName | default "gitops-fastapi-lw-poc" -}}
{{- printf "%s/%s/%s.git" (include "gitea.url" $root) $org $repo -}}
{{- end -}}

{{- define "gitea.templatePythonAppRepoUrl" -}}
{{- $repo := .Values.seed.python.repoName | default "fastapi-lw-poc" -}}
{{- printf "%s/%s/%s.git" (include "gitea.url" .) (include "gitea.templatesOrgName" .) $repo -}}
{{- end -}}

{{- define "gitea.templatePythonGitopsRepoUrl" -}}
{{- $repo := .Values.seed.python.gitops.repoName | default "gitops-fastapi-lw-poc" -}}
{{- printf "%s/%s/%s.git" (include "gitea.url" .) (include "gitea.templatesOrgName" .) $repo -}}
{{- end -}}

{{- define "gitea.primaryStudentRepoUrl" -}}
{{- include "gitea.studentAppRepoUrl" (list . (include "gitea.primaryStudent" .)) -}}
{{- end -}}
