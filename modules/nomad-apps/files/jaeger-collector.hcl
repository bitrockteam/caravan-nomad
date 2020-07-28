job "jaeger-collector" {
    datacenters = ["hcpoc"]
    group "web" {
        network {
            mode = "bridge"
            port "http" {}
        }
        service {
            name = "jaeger-collector"
            tags = [ "web", "monitoring" ]
            port = "http",
            check {
                type = "http"
                port = "http"
                path = "/"
                interval = "5s"
                timeout = "2s"
            }
            connect = {
                sidecar_service { }
                sidecar_task {
                    driver = "exec"
                    config {
                        command = "/usr/bin/envoy"
                        args  = [
                            "-c",
                            "${NOMAD_SECRETS_DIR}/envoy_bootstrap.json",
                            "-l",
                            "${meta.connect.log_level}"
                        ]
                    }
                }
            }
            
        }
        task "collector" {
            driver = "exec"

            config {
                command = "/usr/local/bin/jaeger-collector"
                args = [
                    "--admin.http.host-port=0.0.0.0:${NOMAD_PORT_http}",
                ]
            }

            env {
                SPAN_STORAGE_TYPE = "elasticsearch"
                ES_SERVER_URLS = "http://10.128.0.6:9200"
            }
        }
    }
}