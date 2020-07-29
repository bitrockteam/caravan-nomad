job "jaeger-query" {
    datacenters = ["hcpoc"]
    group "query" {
        network {
            mode = "bridge"
            port "http" {}
            port "http_admin" {}
        }
        service {
            name = "jaeger-query"
            tags = [ "monitoring" ]
            port = "http",
            check {
                type = "http"
                port = "http_admin"
                path = "/"
                interval = "5s"
                timeout = "2s"
            }
            connect = {
                sidecar_service { }
                /* sidecar_task {
                    driver = "exec"
                    shutdown_delay = "5s"
                    config {
                        command = "/usr/bin/envoy"
                        args  = [
                            "-c",
                            "${NOMAD_SECRETS_DIR}/envoy_bootstrap.json",
                            "-l",
                            "${meta.connect.log_level}",
                            "--disable-hot-restart"
                        ]
                    }
                    resources {
                        cpu    = 250
                        memory = 128
                    }
                    logs {
                        max_files     = 2
                        max_file_size = 2
                    }
                } */
            }
            
        }
        task "query" {
            driver = "exec"

            config {
                command = "/usr/local/bin/jaeger-query"
                args = [
                    "--admin.http.host-port=0.0.0.0:${NOMAD_PORT_http_admin}",
                    "--query.host-port=0.0.0.0:${NOMAD_PORT_http}"
                ]
            }

            env {
                SPAN_STORAGE_TYPE = "elasticsearch"
                ES_SERVER_URLS = "http://10.128.0.6:9200"
            }
        }
    }
}