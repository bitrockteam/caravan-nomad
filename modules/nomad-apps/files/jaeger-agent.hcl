job "jaeger-agent" {
    datacenters = ["hcpoc"]

    type = "system"

    group "web" {

        network {
            mode = "bridge"
            port "http" {}
        }
        service {
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
                sidecar_service {
                    proxy {
                        upstreams {
                           destination_name = "jaeger-collector"
                           local_bind_port = 14250
                        }
                    }   
                }
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
        task "agent" {
            driver = "exec"

            config {
                command = "/usr/local/bin/jaeger-agent"
                args = [
                    "--admin.http.host-port=0.0.0.0:${NOMAD_PORT_http}",
                    "--reporter.grpc.host-port=127.0.0.1:14250"
                ]
            }
        }
    }
}