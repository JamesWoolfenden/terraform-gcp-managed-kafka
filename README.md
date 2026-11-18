# terraform-gcp-managed-kafka

[![Build Status](https://github.com/JamesWoolfenden/terraform-gcp-managed-kafka/workflows/Verify/badge.svg?branch=main)](https://github.com/JamesWoolfenden/terraform-gcp-managed-kafka/actions)
[![Latest Release](https://img.shields.io/github/release/JamesWoolfenden/terraform-gcp-managed-kafka.svg)](https://github.com/JamesWoolfenden/terraform-gcp-managed-kafka/releases/latest)
[![GitHub tag (latest SemVer)](https://img.shields.io/github/tag/JamesWoolfenden/terraform-gcp-managed-kafka.svg?label=latest)](https://github.com/JamesWoolfenden/terraform-gcp-managed-kafka/releases/latest)
![Terraform Version](https://img.shields.io/badge/tf-%3E%3D1.5.0-blue.svg)
[![pre-commit](https://img.shields.io/badge/pre--commit-enabled-brightgreen?logo=pre-commit&logoColor=white)](https://github.com/pre-commit/pre-commit)

Terraform module for Google Cloud Managed Service for Apache Kafka. Creates a CMEK-encrypted Kafka cluster that is reachable only from the subnetworks you supply (via Private Service Connect, no public endpoint), with automatic partition rebalancing on scale-up, a map of topics (replication factor of at least 3 enforced), and optional Kafka ACLs that reject the `User:*` wildcard. The CMEK key is granted to the Managed Kafka service agent (`service-PROJECT_NUMBER@gcp-sa-managedkafka.iam.gserviceaccount.com`).

## Usage

Add **module.managed_kafka.tf** to your code:-

```terraform
module "managed_kafka" {
  source       = "jameswoolfenden/managed-kafka/gcp"
  cluster_id   = "example-kafka"
  region       = "europe-west2"
  kms_key_name = google_kms_crypto_key.kafka.id
  subnets      = [google_compute_subnetwork.kafka.id]

  topics = {
    "orders" = {
      partition_count = 6
    }
  }

  acls = {
    "topic/orders" = [{
      principal = "User:${google_service_account.producer.email}"
      operation = "WRITE"
    }]
  }
}
```

See [example/examplea](example/examplea) for a complete working example.

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

No requirements.

## Providers

| Name | Version |
| ---- | ------- |
| <a name="provider_google"></a> [google](#provider\_google) | n/a |

## Modules

No modules.

## Resources

| Name | Type |
| ---- | ---- |
| [google_kms_crypto_key_iam_member.managed_kafka](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/kms_crypto_key_iam_member) | resource |
| [google_managed_kafka_acl.main](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/managed_kafka_acl) | resource |
| [google_managed_kafka_cluster.main](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/managed_kafka_cluster) | resource |
| [google_managed_kafka_topic.main](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/managed_kafka_topic) | resource |
| [google_project.current](https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/project) | data source |

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_acls"></a> [acls](#input\_acls) | Kafka ACLs keyed by ACL ID (e.g. "topic/orders", "consumerGroup/billing", "allTopics"). Principals are "User:\<service-account-email\>\ | <pre>map(list(object({<br/>        principal       = string<br/>        operation       = string<br/>        permission\_type = optional(string, "ALLOW")<br/>      })))</pre> | `{}` | no |
| <a name="input_cluster_id"></a> [cluster\_id](#input\_cluster\_id) | ID of the Managed Service for Apache Kafka cluster | `string` | n/a | yes |
| <a name="input_kms_key_name"></a> [kms\_key\_name](#input\_kms\_key\_name) | CMEK key used to encrypt broker storage; must be in the same region as the cluster | `string` | n/a | yes |
| <a name="input_labels"></a> [labels](#input\_labels) | Labels applied to the cluster for cost allocation and ownership tracking | `map(string)` | `{}` | no |
| <a name="input_memory_bytes"></a> [memory\_bytes](#input\_memory\_bytes) | Memory provisioned for the cluster in bytes; between 1 GiB and 8 GiB per vCPU | `number` | `3221225472` | no |
| <a name="input_rebalance_mode"></a> [rebalance\_mode](#input\_rebalance\_mode) | Partition rebalance behaviour when the cluster scales (AUTO\_REBALANCE\_ON\_SCALE\_UP or NO\_REBALANCE) | `string` | `"AUTO_REBALANCE_ON_SCALE_UP"` | no |
| <a name="input_region"></a> [region](#input\_region) | Region for the Kafka cluster | `string` | n/a | yes |
| <a name="input_subnets"></a> [subnets](#input\_subnets) | Subnetworks (projects/P/regions/R/subnetworks/S) the cluster is reachable from via Private Service Connect. Brokers have no public endpoint | `list(string)` | n/a | yes |
| <a name="input_topics"></a> [topics](#input\_topics) | Topics to create, keyed by topic ID | <pre>map(object({<br/>      partition\_count    = optional(number, 3)<br/>      replication\_factor = optional(number, 3)<br/>      configs            = optional(map(string), {})<br/>    }))</pre> | `{}` | no |
| <a name="input_vcpu_count"></a> [vcpu\_count](#input\_vcpu\_count) | Number of vCPUs provisioned for the cluster (minimum 3) | `number` | `3` | no |

## Outputs

| Name | Description |
| ---- | ----------- |
| <a name="output_id"></a> [id](#output\_id) | ID of the Kafka cluster |
| <a name="output_name"></a> [name](#output\_name) | Full resource name of the Kafka cluster |
| <a name="output_topic_ids"></a> [topic\_ids](#output\_topic\_ids) | IDs of the topics, keyed by topic ID |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

## Role and Permissions

<!-- BEGINNING OF PRE-COMMIT-PIKE DOCS HOOK -->
The Terraform resource required is:

```golang
# apply role
resource "google_project_iam_custom_role" "terraform_pike" {
  project     = "pike-477416"
  role_id     = "terraform_pike"
  title       = "terraform_pike"
  description = "A user with least privileges"
  permissions = [
    "cloudkms.cryptoKeys.getIamPolicy",
    "cloudkms.cryptoKeys.setIamPolicy",
    "managedkafka.acls.create",
    "managedkafka.acls.delete",
    "managedkafka.acls.get",
    "managedkafka.acls.update",
    "managedkafka.clusters.create",
    "managedkafka.clusters.delete",
    "managedkafka.clusters.get",
    "managedkafka.clusters.update",
    "managedkafka.operations.get",
    "managedkafka.topics.create",
    "managedkafka.topics.delete",
    "managedkafka.topics.get",
    "managedkafka.topics.update",
    "resourcemanager.projects.get"
  ]
}

# plan role
resource "google_project_iam_custom_role" "terraform_pike_plan" {
  project     = "pike-477416"
  role_id     = "terraform_pike_plan"
  title       = "terraform_pike_plan"
  description = "A user with least privileges"
  permissions = [
    "cloudkms.cryptoKeys.getIamPolicy",
    "managedkafka.acls.get",
    "managedkafka.clusters.get",
    "managedkafka.operations.get",
    "managedkafka.topics.get",
    "resourcemanager.projects.get"
  ]
}


```
<!-- END OF PRE-COMMIT-PIKE DOCS HOOK -->

## Help

**Got a question?**

File a GitHub [issue](https://github.com/jameswoolfenden/terraform-gcp-managed-kafka/issues).

## Contributing

### Bug Reports & Feature Requests

Please use the [issue tracker](https://github.com/jameswoolfenden/terraform-gcp-managed-kafka/issues) to report any bugs or file feature requests.

## Copyrights

Copyright © 2026 James Woolfenden

## License

[![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](https://opensource.org/licenses/Apache-2.0)

See [LICENSE](LICENSE) for full details.

Licensed to the Apache Software Foundation (ASF) under one
or more contributor license agreements. See the NOTICE file
distributed with this work for additional information
regarding copyright ownership. The ASF licenses this file
to you under the Apache License, Version 2.0 (the
"License"); you may not use this file except in compliance
with the License. You may obtain a copy of the License at

<https://www.apache.org/licenses/LICENSE-2.0>

Unless required by applicable law or agreed to in writing,
software distributed under the License is distributed on an
"AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
KIND, either express or implied. See the License for the
specific language governing permissions and limitations
under the License.

### Contributors

[![James Woolfenden][jameswoolfenden_avatar]][jameswoolfenden_homepage]<br/>[James Woolfenden][jameswoolfenden_homepage]

[jameswoolfenden_homepage]: https://github.com/jameswoolfenden
[jameswoolfenden_avatar]: https://github.com/jameswoolfenden.png?size=150
