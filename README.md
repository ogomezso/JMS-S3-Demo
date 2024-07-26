# Confluent Cloud JMS to S3 demo

Demo repo for JMS to S3 pipeline on Confluent Cloud (AWS

## Porivisioning Connfluent Cloud Cluster

On this example we are going to provision:

- `Basic Cluster` with `Essential Stream Governance Package` using as state backend a previously created s3 backed (backend.tf)
- `app-manager` Service Account with Cloud Cluster admin on the created cluster.

## Provisioning Artemis (ActiveMQ) cluster

We will use Artemis Operator on your preferred K8s Distribution.

To install it:

1. Clone the artemis operator repository:

```bash
git clone https://github.com/artemiscloud/activemq-artemis-operator.git
```

2. Install the operator on a dedicated namespace:

```bash
deploy/install_opr.sh
```

3. Deploy a single artemis broker:

```bash
kubectl apply -f examples/artemis/artemis_single.yaml
```

## Kafka Connect and Connectors

Para Kafka Connect usaremos la versión 7.6.1 con init-container 2.8.2

### Secretos para CCLOUD
Para autenticar con CCLOUD necesitaremos tener las API-KEYS adecuadas.

Para ello necesitamos crear los secretos adecuados:

Credenciales para Cluster Kafka

```bash
kubectl create secret generic ccloud-credentials --from-file=plain.txt=ccloud-credentials.txt -n confluent --dry-run=client -o yaml > ccloud-credentials.yaml
```

donde ccloud-credentials.txt contiene:

```txt
username=<CCLOUD-API-KEY>
password=<CCLOUD-API-SECRET>
```

En caso de necesitar crear Topics desde el cluster AKS, necesitaremos una rest credential


```bash
kubectl create secret generic ccloud-rest-credentials --from-file=basic.txt=ccloud-credentials.txt --namespace confluent --dry-run=client -o yaml > ccloud-rest-credentials.yaml
```

### Schema Registry Credentials

```bash
kubectl create secret generic ccloud-sr-credentials --from-file=basic.txt=ccloud-sr-credentials.txt -n confluent  --dry-run=client -o yaml > ccloud-sr-credentials.yaml

```

donde ccloud-sr-credentials.txt contiene:

```txt
username=<CCLOUD-SR-API-KEY>
password=<CCLOUD-SR-API-SECRET>
```

Esto generá los recursos yaml para crear los secretos en el namespace confluent, por tanto solo nos queda aplicarlos:

```bash
kubectl apply -f ccloud-credentials.yaml
kubectl apply -f ccloud-sr-credentials.yaml
```

### Connect Deployment

Usaremos el CRD de Connect para deplegar nuestro cluster de connect