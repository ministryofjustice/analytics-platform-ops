require 'awspec'
require 'aws-sdk'
require 'rhcl'

# Parse and load our terraform manifest into example_main
# example_main = Rhcl.parse(File.open('test/test_fixture/main.tf'))
# vpc_name = example_main['module']['vpc']['environment'] + "-vpc"
# environment_tag = example_main['module']['vpc']['environment']
# service_tag = example_main['module']['vpc']['service']
# description_tag = "Managed by Terraform"
# # Load the terraform state file and convert it into a Ruby hash
# state_file = 'terraform.tfstate.d/kitchen-terraform-default-aws/terraform.tfstate'
# tf_state = JSON.parse(File.open(state_file).read)
# region = tf_state['modules'][0]['outputs']['region']['value']
# ENV['AWS_REGION'] = region

tfvars = Rhcl.parse(File.open('../vars/kitchen-test.tfvars'))

describe vpc('kitchen-terraform-default-aws.mojanalytics.xyz') do
    it { should exist }
    its(:cidr_block) { should eq '192.168.0.0/16' }
end
