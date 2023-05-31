# Blueprints example

This repo contains an admin stack that deploys two Blueprints. To use it, create an administrative
stack pointing at the root of this repo, and trigger it.

The Blueprint definitions are defined via the [Spacelift Terraform provider](https://registry.terraform.io/providers/spacelift-io/spacelift/latest/docs/resources/blueprint) in the main.tf file, and the underlying Terraform code that will be used by each stack created from the blueprints can be found in the `blueprints` folder.

These stacks don't actually deploy any real infrastructure. They're just intended to illustrate how to create Blueprints.

For more information on Blueprints check out our [docs](https://docs.spacelift.io/concepts/blueprint/index.html).
