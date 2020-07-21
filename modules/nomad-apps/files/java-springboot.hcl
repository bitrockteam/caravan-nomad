job "java-springboot" {
    datacenters = ["hcpoc"]
    group "web" {
        task "springboot" {
            driver = "java"

            config {
                jar_path    = "local/spring-boot-0.0.1-SNAPSHOT.jar"
                jvm_options = ["-Xmx2048m", "-Xms256m"]
                args        = ["--server.port=${NOMAD_PORT_http}"]
            }

            artifact {
                source = "gcs::https://www.googleapis.com/storage/v1/cfgs-hcpoc-boomboom-468826369/spring-boot-0.0.1-SNAPSHOT.jar",
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
                            destination_name = "sringboot"
                            local_bind_port = 8080
                        }
                    }   
                    }
                    sidecar_task {
                        name  = "connect-proxy-java"
                        driver = "raw_exec"
                        config {
                            command = "/usr/local/bin/envoy"
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
                    path = "/actuator/health"
                    interval = "5s"
                    timeout = "2s"
                }
            }
        }
    }
}