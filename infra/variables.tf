variable "project-name" {
  description = "The name of the project"
  type        = string
}

variable "client_id" {
  description = "The client IDs to allow to connect"
  type        = string
}

variable "topic_name" {
  description = "The topic to publish and subscribe to"
  type        = string
}