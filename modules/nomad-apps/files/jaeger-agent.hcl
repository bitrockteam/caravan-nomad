job "jaeger-agent" {
    datacenters = ["hcpoc"]

    type = "system"

    group "agent" {

        network {
            mode = "bridge"
            port "http" {
                to = -1
            }
        }
        service {
            name = "jaeger-agent"
            tags = [ "monitoring" ]
            port = "14271",
            check {
                type = "http"
                port = "http"
                path = "/"
                interval = "5s"
                timeout = "2s"
                /*  expose = true rpc error: 1 error occurred: * exposed service check web->jaeger-agent-web->service: "jaeger-agent-web" check requires use of Nomad's builtin Connect proxy */
            }
            connect = {
                sidecar_service {
                    proxy {
                        upstreams {
                           destination_name = "jaeger-collector"
                           local_bind_port = 14250
                        }
                        expose {
                            path {
                                path            = "/"
                                protocol        = "http"
                                local_path_port = 14271
                                listener_port   = "http"
                            }
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
        task "agent" {
            driver = "exec"

            config {
                command = "/usr/local/bin/jaeger-agent"
                args = [
                    # "--admin.http.host-port=127.0.0.1:14271",
                    "--reporter.grpc.host-port=127.0.0.1:14250"
                ]
            }
        }
    }
}