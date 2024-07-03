# Confluent Cloud JMS to S3 demo

Demo repo for JMS to S3 pipeline on Confluent Cloud (AWS

## Porivisioning Connfluent Cloud Cluster

On this example we are going to provision:

- `Basic Cluster` with `Essential Stream Governance Package` using as state backend a previously created s3 backed (backend.tf)
- `app-manager` Service Account with Cloud Cluster admin on the created cluster.