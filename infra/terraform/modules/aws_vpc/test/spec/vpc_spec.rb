require 'awspec'
require 'aws-sdk'
require 'rhcl'

# tfvars = Rhcl.parse(File.open('../vars/kitchen-test.tfvars'))

describe vpc('test-vpc') do
    it { should exist }
    its(:cidr_block) { should eq '192.168.0.0/16' }
end
