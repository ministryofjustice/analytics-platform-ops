require 'awspec'
require 'rhcl'

# Some info required for tests aren't known ahead of time (such as
# resource IDs), so need to be obtained from `terraform output`
tf_output = eval(ENV['KITCHEN_KITCHEN_TERRAFORM_OUTPUT'])
vpc_id = tf_output[:vpc_id][:value]

# Parse .tfvars file
test_vars = Rhcl.parse(File.open('./vars/kitchen-test.tfvars'))
vpc_cidr = test_vars['vpc_cidr']

describe vpc(vpc_id) do
    it { should exist }
    its(:cidr_block) { should eq test_vars['vpc_cidr'] }
end
