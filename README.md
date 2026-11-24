Option 2 - Persistent Application Database

The Flask application demonstrates the persistence of a visit counter in Redis.
Redis uses a Docker named volume in redis-data and append-only persistence to retain the counter even if the container is removed and recreated.

To deploy, run the following commands in the terraform-project directory:
"terraform init"
"terraform validate"
"terraform plan"
"terraform apply"

To test, run: 
"docker ps" 
"docker exec redis redis-cli ping" 
"curl http://localhost:5000"
"curl http://localhost:5000" (repeat as many times as you'd like)
"docker exec redis redis-cli GET visits" (displays visit count)
"docker rm -f redis" (removes redis container)
"docker ps" (verify redis was removed)
"terraform apply" (recreate redis)
"docker exec redis redis-cli GET visits"
"curl http://localhost:5000"

The counter value is preserved.

To destroy, run:
"terraform destroy"
