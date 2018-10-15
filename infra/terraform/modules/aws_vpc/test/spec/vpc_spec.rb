require 'awspec'

describe vpc('test-vpc') do
    it { should exist }
    its(:cidr_block) { should eq '192.168.0.0/16' }
end
