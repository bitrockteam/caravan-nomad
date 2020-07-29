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
                source = "gcs::https://www.googleapis.com/storage/v1/cfgs-bmed-116849772/spring-echo-example-1.0.0.jar",
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
        }
    }
}