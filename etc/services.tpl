{{ range service "swarmdind" }}
server {{ .Name }}{{ .Address }}:{{ .Port }} {{ .Tags }}
{{ end }}

{{ range ls "swarmdind" }}
{{ .Key }}
{{ end }}
