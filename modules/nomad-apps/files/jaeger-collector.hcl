job "jaeger-collector" {
    datacenters = ["hcpoc"]
    group "collector" {
        network {
            mode = "bridge"
            port "http" {}
            port "http_span" {}
        }
        service {
            name = "jaeger-collector"
            tags = [ "monitoring" ]
            port = "http_span",
            check {
                type = "http"
                port = "http"
                path = "/"
                interval = "5s"
                timeout = "2s"
            }
            connect = {
                sidecar_service {
                    proxy {
                        config {
                            protocol = "grpc"
                        }
                    }
                 }
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
        task "collector" {
            driver = "exec"

            config {
                command = "/usr/local/bin/jaeger-collector"
                args = [
                    "--admin.http.host-port=0.0.0.0:${NOMAD_PORT_http}",
                    "--collector.grpc-server.host-port=127.0.0.1:${NOMAD_PORT_http_span}"
                ]
            }

            env {
                SPAN_STORAGE_TYPE = "elasticsearch"
                ES_SERVER_URLS = "http://10.128.0.2:9200"
            }
        }
    }
}