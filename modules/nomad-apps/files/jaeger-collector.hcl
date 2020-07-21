job "jaeger-collector" {
    datacenters = ["hcpoc"]
    group "web" {
        task "monitoring" {
            driver = "exec"

            config {
                command = "/usr/local/bin/jaeger-collector"
            }

            resources {
                network {
                    port "http" {}
                }
            }

            service {
                tags = [ "web", "monitoring" ]
                port = "http",
                connect = {
                    sidecar_service {
                        proxy {
                            upstreams {
                                destination_name = "jaeger-collector"
                                local_bind_port = 9411
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