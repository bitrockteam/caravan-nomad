job "bmed" {
    datacenters = ["hcpoc"]
    group "web" {
        network {
            mode = "bridge"
        }
      
        service {
          name = "java-api"
          port = "8080"

          connect {
            sidecar_service {}
          }
        }
      
        task "springboot" {
            driver = "java"

            config {
                jar_path    = "local/spring-echo-example-1.0.0.jar"
                jvm_options = ["-Xmx2048m", "-Xms256m"]
                args        = ["--server.port=${NOMAD_PORT_http}"]
            }

            artifact {
                source = "gcs::https://www.googleapis.com/storage/v1/cfgs-hcpoc-boomboom-468826369/spring-echo-example-1.0.0.jar",
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
                                destination_name = "java-api"
                                local_bind_port = 8080
                            }
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