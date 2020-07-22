
job "echo-server" {
    datacenters = ["hcpoc"]
    group "web" {
        network {
            mode = "bridge"
        }   
        task "echo" {
            driver = "exec"

            config {
                command = "local/echo-server"
            }

            artifact {
                source = "gcs::https://www.googleapis.com/storage/v1/cfgs-hcpoc-boomboom-468826369/echo-server",
                options = {
                token = "ya29.c.KmnUB7SLinlviSZqlNsHjPUuel0UVl0PZHOE_UeYe1vUHSp6pzVaV5MemsRpvQ05b7VWwyjxXFf3apdzZFetyNIF3h6DVnR4lvCs1jqgJH32llZlgpLHDDKXfKpT9j9FHMFn0PpzCS7bjgU"
                },
                destination = "local/"
            }

            resources {
                network {
                    port "http" {}
                }
            }

            service {
                tags = [ "web" ]
                port = "http",
                connect = {
                    sidecar_service {
                        proxy {
                        upstreams {
                            destination_name = "echo"
                            local_bind_port = 8080
                        }
                    }   
                    }
                    sidecar_task {
                        name  = "connect-proxy-echo"
                        driver = "raw_exec"
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
                check {
                    type = "http"
                    port = "http"
                    path = "/"
                    interval = "5s"
                    timeout = "2s"
                }
            }
        }
    }
}