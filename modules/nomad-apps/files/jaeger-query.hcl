job "jaeger-query" {
    datacenters = ["hcpoc"]

    type = "service"

    constraint {
        attribute = "${attr.unique.hostname}"
        operator  = "="
        value     = "monitoring"
    }

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
                sidecar_service {}
                sidecar_task {
                    name  = "connect-jaeger-query"
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

        task "jaeger-query" {
            driver = "exec"

            template {
              data = "nameserver {{env `NOMAD_HOST_IP_http`}}"
              destination = "etc/resolv.conf"
            }

            config {
                command = "/usr/local/bin/jaeger-query"
                args = [
                    "--admin.http.host-port=0.0.0.0:${NOMAD_PORT_http_admin}",
                    "--query.host-port=0.0.0.0:${NOMAD_PORT_http}"
                ]
            }

            env {
                SPAN_STORAGE_TYPE = "elasticsearch"
                ES_SERVER_URLS = "http://elastic-internal.service.hcpoc.consul:9200"
                JAEGER_AGENT_HOST = "${attr.unique.network.ip-address}"
                JAEGER_AGENT_PORT = "6831"
            }
        }
    }
}