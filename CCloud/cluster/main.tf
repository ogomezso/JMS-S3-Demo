resource "confluent_environment" "POC" {
  display_name = "air-europa-poc"
}

data "confluent_schema_registry_region" "POC" {
  cloud   = "AWS"
  region  = "eu-south-2"
  package = "ESSENTIALS"
}

resource "confluent_schema_registry_cluster" "POC" {
  package = data.confluent_schema_registry_region.POC.package

  environment {
    id = confluent_environment.POC.id
  }

  region {
    id = data.confluent_schema_registry_region.POC.id
  }
}


resource "confluent_kafka_cluster" "POC" {
  display_name = "AE-POC"
  availability = "SINGLE_ZONE"
  cloud        = "AWS"
  region       = "eu-south-2"
  basic {}
  environment {
    id = confluent_environment.POC.id
  }
}

resource "confluent_service_account" "ogomez-AE-app-manager" {
  display_name = "ogomez-AE-app-manager"
  description  = "Service account to manage 'inventory' Kafka cluster"
}

resource "confluent_role_binding" "ogomez-AE-app-manager-kafka-cluster-admin" {
  principal   = "User:${confluent_service_account.ogomez-AE-app-manager.id}"
  role_name   = "CloudClusterAdmin"
  crn_pattern = confluent_kafka_cluster.POC.rbac_crn
}

resource "confluent_api_key" "ogomez-AE-app-manager-kafka-api-key" {
  display_name = "ogomez-AE-app-manager-kafka-api-key"
  description  = "Kafka API Key that is owned by 'ogomez-AE-app-manager' service account"
  owner {
    id          = confluent_service_account.ogomez-AE-app-manager.id
    api_version = confluent_service_account.ogomez-AE-app-manager.api_version
    kind        = confluent_service_account.ogomez-AE-app-manager.kind
  }

  managed_resource {
    id          = confluent_kafka_cluster.POC.id
    api_version = confluent_kafka_cluster.POC.api_version
    kind        = confluent_kafka_cluster.POC.kind

    environment {
      id = confluent_environment.POC.id
    }
  }
}