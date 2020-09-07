job "jaeger-agent" {
    datacenters = ["hcpoc"]

    type = "service"

    constraint {
        attribute = "${attr.unique.hostname}"
        operator  = "="
        value     = "monitoring"
    }

    group "agent" {

        network {
            mode = "bridge"
            port "http" {}
            port "udp" {
                static = 6831
                to = 6831
            }
        }
        service {
            name = "jaeger-agent"
            tags = [ "monitoring" ]
            port = "udp",
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
                        config {
                            protocol = "udp"
                        }
                    }
                }
                sidecar_task {
                    name  = "connect-jaeger-agent"
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

        task "agent" {
            driver = "exec"

            config {
                command = "/usr/local/bin/jaeger-agent"
                args = [
                    "--admin.http.host-port=0.0.0.0:${NOMAD_PORT_http}",
                    "--reporter.grpc.host-port=${NOMAD_UPSTREAM_ADDR_jaeger_collector}",
                    "--processor.jaeger-compact.server-host-port=:${NOMAD_PORT_udp}",
                    "--reporter.grpc.discovery.min-peers=1"
                ]
            }
        }
    }
}