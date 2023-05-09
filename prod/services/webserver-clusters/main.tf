provider "aws" {
}

module "webserver_clusters" {
    source = "git@github.com:hyeongju12/tf_modules.git//services/webserver-clusters?ref=v0.0.1"

    cluster_name = "prod-webservice"
    remote_state_bucket = "hjyoo-prod-state-bucket"
    remote_state_key = "prod/data-stores/mysql/terraform.tfstate"
}

