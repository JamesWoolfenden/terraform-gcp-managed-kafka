variable "cluster_id" {
  type        = string
  description = "ID of the Managed Service for Apache Kafka cluster"

  validation {
    condition     = can(regex("^[a-z]([a-z0-9-]{0,61}[a-z0-9])?$", var.cluster_id))
    error_message = "var.cluster_id must be 1-63 characters of lowercase letters, numbers and hyphens, starting with a letter"
  }
}

variable "region" {
  type        = string
  description = "Region for the Kafka cluster"

  validation {
    condition     = length(trimspace(var.region)) > 0
    error_message = "var.region must be a non-empty string"
  }
}

variable "kms_key_name" {
  type        = string
  description = "CMEK key used to encrypt broker storage; must be in the same region as the cluster"
  sensitive   = true

  validation {
    condition     = length(trimspace(var.kms_key_name)) > 0
    error_message = "var.kms_key_name must be a non-empty string"
  }

  validation {
    condition     = can(regex("/locations/${var.region}/", var.kms_key_name))
    error_message = "var.kms_key_name must be a KMS key in the same location as var.region"
  }
}

variable "subnets" {
  type        = list(string)
  description = "Subnetworks (projects/P/regions/R/subnetworks/S) the cluster is reachable from via Private Service Connect. Brokers have no public endpoint"

  validation {
    condition     = length(var.subnets) > 0 && alltrue([for s in var.subnets : can(regex("^projects/[^/]+/regions/[^/]+/subnetworks/[^/]+$", s))])
    error_message = "var.subnets must contain at least one subnetwork in the form projects/P/regions/R/subnetworks/S"
  }
}

variable "vcpu_count" {
  type        = number
  description = "Number of vCPUs provisioned for the cluster (minimum 3)"
  default     = 3

  validation {
    condition     = var.vcpu_count >= 3 && floor(var.vcpu_count) == var.vcpu_count
    error_message = "var.vcpu_count must be a whole number of at least 3"
  }
}

variable "memory_bytes" {
  type        = number
  description = "Memory provisioned for the cluster in bytes; between 1 GiB and 8 GiB per vCPU"
  default     = 3221225472

  validation {
    condition     = var.memory_bytes >= var.vcpu_count * 1073741824 && var.memory_bytes <= var.vcpu_count * 8589934592
    error_message = "var.memory_bytes must be between 1 GiB and 8 GiB per vCPU"
  }
}

variable "rebalance_mode" {
  type        = string
  description = "Partition rebalance behaviour when the cluster scales (AUTO_REBALANCE_ON_SCALE_UP or NO_REBALANCE)"
  default     = "AUTO_REBALANCE_ON_SCALE_UP"

  validation {
    condition     = contains(["AUTO_REBALANCE_ON_SCALE_UP", "NO_REBALANCE"], var.rebalance_mode)
    error_message = "var.rebalance_mode must be AUTO_REBALANCE_ON_SCALE_UP or NO_REBALANCE"
  }
}

variable "topics" {
  type = map(object({
    partition_count    = optional(number, 3)
    replication_factor = optional(number, 3)
    configs            = optional(map(string), {})
  }))
  description = "Topics to create, keyed by topic ID"
  default     = {}

  validation {
    condition     = alltrue([for k, v in var.topics : can(regex("^[a-zA-Z0-9._-]{1,249}$", k))])
    error_message = "var.topics keys must be valid Kafka topic names"
  }

  validation {
    condition     = alltrue([for k, v in var.topics : v.partition_count >= 1 && v.replication_factor >= 3])
    error_message = "var.topics partition_count must be at least 1 and replication_factor at least 3 for durability"
  }
}

variable "acls" {
  type = map(list(object({
    principal       = string
    operation       = string
    permission_type = optional(string, "ALLOW")
  })))
  description = "Kafka ACLs keyed by ACL ID (e.g. \"topic/orders\", \"consumerGroup/billing\", \"allTopics\"). Principals are \"User:<service-account-email>\""
  default     = {}

  validation {
    condition     = alltrue([for k, v in var.acls : can(regex("^(cluster|allTopics|allConsumerGroups|allTransactionalIds|(topic|consumerGroup|transactionalId)/.+)$", k)) && length(v) > 0])
    error_message = "var.acls keys must be valid ACL IDs and each ACL must have at least one entry"
  }

  validation {
    condition     = alltrue(flatten([for k, v in var.acls : [for e in v : can(regex("^User:", e.principal)) && e.principal != "User:*"]]))
    error_message = "var.acls principals must be \"User:<identity>\"; the wildcard \"User:*\" is not allowed"
  }

  validation {
    condition     = alltrue(flatten([for k, v in var.acls : [for e in v : contains(["ALLOW", "DENY"], e.permission_type) && contains(["ALL", "READ", "WRITE", "CREATE", "DELETE", "ALTER", "DESCRIBE", "CLUSTER_ACTION", "DESCRIBE_CONFIGS", "ALTER_CONFIGS", "IDEMPOTENT_WRITE"], e.operation)]]))
    error_message = "var.acls permission_type must be ALLOW or DENY and operation a valid Kafka ACL operation"
  }
}

variable "labels" {
  type        = map(string)
  description = "Labels applied to the cluster for cost allocation and ownership tracking"
  default     = {}

  validation {
    condition     = alltrue([for k, v in var.labels : can(regex("^[a-z0-9_-]{1,63}$", k)) && can(regex("^[a-z0-9_-]{0,63}$", v))])
    error_message = "var.labels keys and values must be lowercase letters, numbers, underscores, or dashes (GCP label constraints)"
  }
}
