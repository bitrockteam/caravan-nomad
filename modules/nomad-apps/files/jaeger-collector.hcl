job "jaeger-collector" {
    datacenters = ["hcpoc"]

    type = "service"

    constraint {
        attribute = "${attr.unique.hostname}"
        operator  = "="
        value     = "monitoring"
    }

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
                sidecar_service {}
                 sidecar_task {
                    name  = "connect-jaeger-collector"
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

        task "loopback" {
            lifecycle {
                hook = "prestart"
            }
            driver = "exec"
            user = "root"
            config = {
                command = "/sbin/ifup"
                args = ["lo"]
            }
        }

        task "collector" {
            driver = "exec"

            template {
              data = "nameserver {{env `NOMAD_HOST_IP_http`}}"
              destination = "etc/resolv.conf"
            }

            config {
                command = "/usr/local/bin/jaeger-collector"
                args = [
                    "--admin.http.host-port=0.0.0.0:${NOMAD_PORT_http}",
                    "--collector.grpc-server.host-port=127.0.0.1:${NOMAD_PORT_http_span}"
                ]
            }

            env {
                SPAN_STORAGE_TYPE = "elasticsearch"
                ES_SERVER_URLS = "http://elastic-internal.service.hcpoc.consul:9200"
            }
        }
    }
}