job "payment-api" {
    multiregion {
        strategy {
            max_parallel = 1
            on_failure   = "fail_all"
        }
        region "west" {
            count       = 1
            datacenters = ["cloud"]
        }
        region "east" {
            count       = 1
            datacenters = ["on-prem"]
        }
    }

    update {
        max_parallel      = 1
        min_healthy_time  = "10s"
        healthy_deadline  = "2m"
        progress_deadline = "3m"
        auto_revert       = true
        auto_promote      = true
        canary            = 1
    }

    group "payment-api" {
        count = 0

        constraint {
            operator  = "distinct_hosts"
            value     = "true"
        }

        task "payments" {
            driver = "java"
            artifact {
                //source = "https://github.com/hashicorp-demoapp/payments/releases/download/v0.0.2/spring-boot-payments-0.1.0.jar"
                source = "https://github.com/hashicorp-demoapp/payments/releases/download/v0.0.11/spring-boot-payments-0.0.11.jar"
            }

            config {
                jar_path    = "local/spring-boot-payments-0.1.0.jar"
                jvm_options = ["-Xmx512m", "-Xms256m"]
            }

            resources {
                cpu    = 256
                memory = 512

                network {
                    port "proxy" {
                        static = 8080
                    }
                }
            }

            service {
                name = "payment-api"
                tags = ["windows","linux","java"]
                port = "proxy"
                check_restart {
                    grace = "600s"
                }
            }
        }
    }
}

# Enable the transform secrets engine
vault secrets enable transform
# Create a role containing the transformations that it can perform
vault write transform/role/payments transformations=card-number
# Create an alphabet defining a set of characters to use for format-preserving
# encryption (FPE) if not using the built-in alphabets.
# Create a template defining the rules for value matching if not using the built-in template
# Create a transformation to specify the nature of the data manipulation
vault write transform/transformation/card-number \
type=fpe \
template="builtin/creditcardnumber" \
tweak_source=internal \
allowed_roles=payments
#vault list transform/transformation/
#vault read transform/transformation/card-number
#vault write transform/encode/payments value=1111-2222-3333-4444 > /tmp/transform-clear.txt
#vault write transform/encode/payments -format=json value=1111-2222-3333-4444 > /tmp/transform-clear.txt
#vault write transform/decode/payments value=$(jq -r .data.encoded_value /tmp/transform-clear.txt)
cat <<EOF > /tmp/transform_vault.hcl
path "transform/encode/payments" {
capabilities = [ "read", "update" ]
}
path "transform/decode/payments" {
capabilities = [ "read", "update" ]
}
EOF
vault policy write transform /tmp/transform_vault.hcl
