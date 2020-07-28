job "tester_no_docker" {
    datacenters = ["hcpoc"]

    group "curl" {
        network {
            mode = "bridge"
            port "http" {}
        }

        service {
            name = "curl-service"
            port = "8080"

            connect {
                sidecar_service {
                    proxy {
                        upstreams {
                            destination_name = "echo-service"
                            local_bind_port = 8080
                        }
                    }
                }
                sidecar_task {
                        name  = "connect-proxy-java"
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

        task "curl" {
          
            driver = "docker"

            config {
                image = "gcr.io/hcpoc-boomboom-468826369/busyboxplus@sha256:4cd8ccdc346a1ccf22228f18e3a6bc2d21f81cfa6600023b3a3669ab3f432e88"
                command = "sleep"
                args = ["10000000"]
            }
        }
    }

    group "echo-server" {
        network {
            mode = "bridge"
            port "http" {}
        }

        service {
            name = "echo-service"
            tags = [ "web" ]
            port = "http",
            connect = {
                sidecar_service {}
            }
            check {
                type = "http"
                port = "http"
                path = "/health"
                interval = "30s"
                timeout = "2s"
            }
        }

        task "echo" {
            driver = "exec"

            config {
                command = "local/echo-server"
            }
          
            env {
              PORT = "${NOMAD_PORT_http}"
            }

            artifact {
                source = "gcs::https://www.googleapis.com/storage/v1/cfgs-hcpoc-boomboom-468826369/echo-server",
                options = {
                token = "ya29.c.KmnUB7SLinlviSZqlNsHjPUuel0UVl0PZHOE_UeYe1vUHSp6pzVaV5MemsRpvQ05b7VWwyjxXFf3apdzZFetyNIF3h6DVnR4lvCs1jqgJH32llZlgpLHDDKXfKpT9j9FHMFn0PpzCS7bjgU"
                },
                destination = "local/"
            }
        }
    }
}