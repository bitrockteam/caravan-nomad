job "java-bmed-no-docker" {
    datacenters = ["hcpoc"]
    group "springboot" {
        network {
            mode = "bridge"
            port "http" {}
            port "http_mgmt" {}
        }

        service {
                tags = [ "web" ]
                port = "9001",
                connect = {
                    sidecar_service {}
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
                check {
                    type = "http"
                    port = "http_mgmt"
                    path = "/actuator/health"
                    interval = "30s"
                    timeout = "10s"
                }
            }

        task "springboot" {
            driver = "java"

            config {
                jar_path    = "local/microservizio-1.0.0-SNAPSHOT.jar"
                jvm_options = ["-Xmx2048m", "-Xms256m"]
            }

            artifact {
                source = "gcs::https://www.googleapis.com/storage/v1/cfgs-bmed-116849772/microservizio-1.0.0-SNAPSHOT.jar",
                options = {
                token = "ya29.c.KmnUB7SLinlviSZqlNsHjPUuel0UVl0PZHOE_UeYe1vUHSp6pzVaV5MemsRpvQ05b7VWwyjxXFf3apdzZFetyNIF3h6DVnR4lvCs1jqgJH32llZlgpLHDDKXfKpT9j9FHMFn0PpzCS7bjgU"
                },
                destination = "local/"
            }

            env {
                SERVER_PORT="${NOMAD_PORT_http}"
                MANAGEMENT_SERVER_PORT="${NOMAD_PORT_http_mgmt}"
            }

            resources {
                memory = 2048
            }
            
        }
    }
}

[2020-07-28 16:59:42.206][31534][critical][main] [external/envoy/source/server/server.cc:95] error initializing configuration '/secrets/envoy_bootstrap.json': cannot bind '127.0.0.1:19001': Cannot assign requested address
[2020-07-28 16:59:42.206][31534][info][main] [external/envoy/source/server/server.cc:606] exiting
cannot bind '127.0.0.1:19001': Cannot assign requested address