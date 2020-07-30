job "java-springboot-jaeger" {
    datacenters = ["hcpoc"]
    group "springboot" {
        network {
            mode = "bridge"
            port "http" {}
            port "http_mgmt" {}
        }

        service {
                tags = [ "web" ]
                port = "http",
                connect = {
                    sidecar_service {
                        proxy {
                            /* upstreams {
                                destination_name = "jaeger-agent"
                                local_bind_port = 6831
                            } */
                        }
                    }
                }
                /* check {
                    type = "http"
                    port = "http_mgmt"
                    path = "/actuator/health"
                    interval = "30s"
                    timeout = "10s"
                }*/
            }

        task "springboot" {
            driver = "java"

            config {
                jar_path    = "local/OpenTracing-AppA-0.0.1-SNAPSHOT.jar"
                jvm_options = ["-Xmx2048m", "-Xms256m"]
                args = ["--opentracing.jaeger.udp-sender.host=${attr.unique.network.ip-address}"]
            }

            artifact {
                source = "gcs::https://www.googleapis.com/storage/v1/cfgs-bmed-1173886834/OpenTracing-AppA-0.0.1-SNAPSHOT.jar",
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
