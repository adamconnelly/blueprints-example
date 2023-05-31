terraform {
  required_providers {
    spacelift = {
      source = "spacelift-io/spacelift"
    }
  }
}

resource "spacelift_blueprint" "developer-environment" {
  name        = "Developer Environment"
  description = "Deploys a remote developer environment for an engineer"
  space       = "root"
  state       = "PUBLISHED"

  template = <<EOF
# Here we define the inputs for our template. These inputs are optional and completely configurable
# by the blueprint author.
inputs:
  - id: developer_name
    name: "Developer name"
  - id: github_username
    name: "GitHub username"
  - id: ssh_public_key
    name: "SSH public key"
    type: "long_text"
  - id: create_environment_immediately
    name: "Create environment immediately"
    type: boolean
    default: false

# Here we define the configuration for our stack
stack:
  name: "Remote developer environment ($${{ inputs.developer_name }})"
  space: "root"
  auto_deploy: true
  labels:
    - "blueprints/$${{ context.blueprint.name }}"
    - "developer_environments/$${{ inputs.developer_name }}"

  # The VCS settings tell us where the stack will get its code from
  vcs:
    branch: main
    repository: "blueprints-example"
    
    # In this example we're using the managed GitHub integration.
    #
    # The other options are GITHUB_ENTERPRISE (this is "GitHub (custom App)") GITLAB, BITBUCKET_DATACENTER,
    # BITBUCKET_CLOUD and AZURE_DEVOPS, all of which require the `namespace` property to be provided.
    provider: GITHUB

    # The project root points at the folder containing the stack definition for our blueprint
    project_root: "blueprints/developer-environment"
  vendor:
    terraform:
      manage_state: true
      version: "1.3.0"
  environment:
    variables:
      - name: TF_VAR_developer_name
        value: $${{ inputs.developer_name }}
        secret: false
      - name: TF_VAR_ssh_public_key
        value: $${{ inputs.ssh_public_key }}
        secret: false
options:
  trigger_run: $${{ inputs.create_environment_immediately }}
  EOF
}

# NOTE: for the feature environment to work correctly, it requires a private worker pool to
# be specified. This is because it uses a Scheduled Delete, which requires a private worker
# pool to work. Please replace the `worker_pool` property with your own worker pool ID.
resource "spacelift_blueprint" "feature-environment" {
  name        = "Feature Environment"
  description = "Deploys a time-limited feature environment for an engineer"
  space       = "root"
  state       = "PUBLISHED"

  template = <<EOF
inputs:
  - id: environment_name
    name: "The Environment name"
  - id: instance_size
    name: "Instance Size"
    type: select
    options:
      - t3.micro
      - t3.small
      - t3.medium
  - id: ttl_days
    name: "TTL (days)"
    type: select
    options:
      - "1"
      - "7"
      - "14"
      - "30"
  - id: create_environment_immediately
    name: "Create environment immediately"
    type: boolean
    default: false
stack:
  name: "Feature environment ($${{ inputs.environment_name }})"
  space: "root"
  auto_deploy: true
  worker_pool: "01GW1NDG5AQXRM4V93KRCF2420"
  labels:
    - "blueprints/$${{ context.blueprint.name }}"
    - "feature_environments/$${{ inputs.environment_name }}"
  vcs:
    branch: main
    repository: "blueprints-example"
    provider: GITHUB
    project_root: "blueprints/feature-environment"
  vendor:
    terraform:
      manage_state: true
      version: "1.3.0"
  environment:
    variables:
      - name: TF_VAR_environment_name
        value: $${{ inputs.environment_name }}
        secret: false
      - name: TF_VAR_instance_size
        value: $${{ inputs.instance_size }}
        secret: false
  schedules:
    delete:
      delete_resources: true
      timestamp_unix: $${{ int(context.time) + (int(inputs.ttl_days) * 86400) }}
options:
  trigger_run: $${{ inputs.create_environment_immediately }}
  EOF
}
