package test

import (
	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"
	"math/rand"
	"strconv"
	"testing"
	"time"
)

// Test the Terraform module in examples/complete using Terratest.
func TestExamplesComplete(t *testing.T) {
	t.Parallel()

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
	}

	// At the end of the test, run `terraform destroy` to clean up any resources that were created
	defer terraform.Destroy(t, terraformOptions)

	// This will run `terraform init` and `terraform apply` and fail the test if there are any errors
	terraform.InitAndApply(t, terraformOptions)

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
