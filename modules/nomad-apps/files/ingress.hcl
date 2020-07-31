job "ingress" {
    datacenters = ["hcpoc"]
    
    type = "system"

    group "ingress" {
        network {
            mode = "host"
        }
       
        service {
          name = "ingress-service"
          port = "8080"
        }
      
        task "envoy_ingress" {
            driver = "raw_exec"
            
            config {
                command = "/usr/local/bin/consul"
                args    = ["connect", "envoy", "-gateway=ingress", "-register", "-service", "ingress-service", "-address", "{{ GetInterfaceIP \"eth0\" }}:8888", "-ca-file=/etc/consul.d/ca", "-client-cert=/etc/consul.d/cert", "-client-key=/etc/consul.d/keyfile", "-grpc-addr=https://localhost:8502"]
            }
        }
    }
}