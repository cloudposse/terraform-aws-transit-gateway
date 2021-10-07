package test

import (
	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"
	"math/rand"
	"os"
	"strconv"
	"strings"
	"testing"
	"time"
)

// Test the Terraform module in examples/complete using Terratest.
func TestExamplesComplete(t *testing.T) {
	rand.Seed(time.Now().UnixNano())

	randId := strconv.Itoa(rand.Intn(100000))
	attributes := []string{randId}

	terraformOptions := &terraform.Options{
		// The path to where our Terraform code is located
		TerraformDir: "../../examples/complete",
		Upgrade:      true,
		// Variables to pass to our Terraform code using -var-file options
		VarFiles: []string{"fixtures.us-east-2.tfvars"},
		Vars: map[string]interface{}{
			"attributes": attributes,
		},
		Targets: []string{"module.transit_gateway"},
	}
	terraformVpcOptions := &terraform.Options{
		TerraformDir: terraformOptions.TerraformDir,
		Upgrade:      terraformOptions.Upgrade,
		// We always want the VPC base infrastructure to be enabled. Also forced in the code.
		VarFiles: []string{"fixtures.us-east-2.tfvars", "fixtures.enabled.tfvars"},
		Vars:     terraformOptions.Vars,
		Targets:  []string{"module.vpc_prod", "module.subnets_prod", "module.vpc_staging", "module.subnets_staging", "module.vpc_dev", "module.subnets_dev"},
	}

	// At the end of the test, run `terraform destroy` to clean up any resources that were created
	defer func() {
		terraformOptions.Targets = []string{"module.transit_gateway"}
		// Creating infrastructure per test takes minutes so optimise by optionally destroying the vpc/subnets dependencies - default is to destroy all
		if len(strings.TrimSpace(os.Getenv("DESTROY_TGW_ONLY"))) > 0 {
			terraform.Destroy(t, terraformOptions)
		} else {
			terraform.Destroy(t, terraformOptions)
			terraform.Destroy(t, terraformVpcOptions)
		}
	}()

	// This will run `terraform init` and `terraform apply` and fail the test if there are any errors
	terraform.InitAndApply(t, terraformVpcOptions)
	terraform.Apply(t, terraformOptions)

	// Run `terraform output` to get the value of an output variable
	transitGatewayArn := terraform.Output(t, terraformOptions, "transit_gateway_arn")
	// Verify we're getting back the outputs we expect
	assert.Contains(t, transitGatewayArn, "transit-gateway/tgw-")

	// Run `terraform output` to get the value of an output variable
	transitGatewayRouteTableId := terraform.Output(t, terraformOptions, "transit_gateway_route_table_id")
	// Verify we're getting back the outputs we expect
	assert.Contains(t, transitGatewayRouteTableId, "tgw-rtb-")

	// Run `terraform output` to get the value of an output variable
	transitGatewayVpcAttachmentIds := terraform.OutputMap(t, terraformOptions, "transit_gateway_vpc_attachment_ids")
	// Verify we're getting back the outputs we expect
	assert.Equal(t, 3, len(transitGatewayVpcAttachmentIds))

	// Run `terraform output` to get the value of an output variable
	subnetRouteIds := terraform.OutputMap(t, terraformOptions, "subnet_route_ids")
	// Verify we're getting back the outputs we expect
	assert.Equal(t, 3, len(subnetRouteIds))

	// Run `terraform output` to get the value of an output variable
	transitGatewayRouteIds := terraform.OutputMap(t, terraformOptions, "transit_gateway_route_ids")
	// Verify we're getting back the outputs we expect
	assert.Equal(t, 3, len(transitGatewayRouteIds))
}

func TestExamplesCompleteDisabledModule(t *testing.T) {
	rand.Seed(time.Now().UnixNano())

	randId := strconv.Itoa(rand.Intn(100000))
	attributes := []string{randId}

	terraformOptions := &terraform.Options{
		// The path to where our Terraform code is located
		TerraformDir: "../../examples/complete",
		Upgrade:      true,
		// Variables to pass to our Terraform code using -var-file options
		VarFiles: []string{"fixtures.us-east-2.tfvars", "fixtures.disabled.tfvars"},
		Vars: map[string]interface{}{
			"attributes": attributes,
		},
	}
	terraformVpcOptions := &terraform.Options{
		TerraformDir: terraformOptions.TerraformDir,
		Upgrade:      terraformOptions.Upgrade,
		// We always want the VPC base infrastructure to be enabled. Also forced in the code.
		VarFiles: []string{"fixtures.us-east-2.tfvars", "fixtures.enabled.tfvars"},
		Vars:     terraformOptions.Vars,
		Targets:  []string{"module.vpc_prod", "module.subnets_prod", "module.vpc_staging", "module.subnets_staging", "module.vpc_dev", "module.subnets_dev"},
	}

	// At the end of the test, run `terraform destroy` to clean up any resources that were created
	defer func() {
		terraformOptions.Targets = []string{"module.transit_gateway"}
		// Creating infrastructure per test takes minutes so optimise by optionally destroying the vpc/subnets dependencies - default is to destroy all
		if len(strings.TrimSpace(os.Getenv("DESTROY_TGW_ONLY"))) > 0 {
			terraform.Destroy(t, terraformOptions)
		} else {
			terraform.Destroy(t, terraformOptions)
			terraform.Destroy(t, terraformVpcOptions)
		}
	}()

	// This will run `terraform init` and `terraform apply` and fail the test if there are any errors
	terraform.InitAndApply(t, terraformVpcOptions)
	terraform.Apply(t, terraformOptions)

	transitGatewayArn := terraform.Output(t, terraformOptions, "transit_gateway_arn")
	transitGatewayRouteTableId := terraform.Output(t, terraformOptions, "transit_gateway_route_table_id")
	transitGatewayVpcAttachmentIds := terraform.OutputMap(t, terraformOptions, "transit_gateway_vpc_attachment_ids")
	subnetRouteIds := terraform.OutputMap(t, terraformOptions, "subnet_route_ids")
	transitGatewayRouteIds := terraform.OutputMap(t, terraformOptions, "transit_gateway_route_ids")

	assert.Empty(t, transitGatewayArn)
	assert.Empty(t, transitGatewayRouteTableId)
	assert.Empty(t, transitGatewayVpcAttachmentIds)
	assert.Empty(t, subnetRouteIds)
	assert.Empty(t, transitGatewayRouteIds)
}
