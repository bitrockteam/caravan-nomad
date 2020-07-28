job "tester" {
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
            }
        }

        task "curl" {
          
            driver = "docker"

            config {
                image = "gcr.io/bmed-116849772/busyboxplus:curl"
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
                source = "gcs::https://www.googleapis.com/storage/v1/cfgs-bmed-116849772/echo-server",
                options = {
                token = "ya29.c.KmnUB7SLinlviSZqlNsHjPUuel0UVl0PZHOE_UeYe1vUHSp6pzVaV5MemsRpvQ05b7VWwyjxXFf3apdzZFetyNIF3h6DVnR4lvCs1jqgJH32llZlgpLHDDKXfKpT9j9FHMFn0PpzCS7bjgU"
                },
                destination = "local/"
            }
        }
    }
}