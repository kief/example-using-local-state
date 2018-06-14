# encoding: utf-8

title 'servers'

deployment_identifier = attribute('deployment_identifier', default: 'unknown', description: 'Which deployment_identifier to inspect')
component = attribute('component', description: 'Which component things should be tagged')
service = attribute('service', description: 'Which service things should be tagged as')

describe aws_ec2_instances(state_name: 'running',
      tag_values: [
            "Component:#{component}",
            "Service:#{service}",
            "DeploymentIdentifier:#{deployment_identifier}"
      ]) do
  it { should have_instances }
  its('count') { should eq 2 }
  its('name') { should include "#{service}-#{component}-#{deployment_identifier}" }
  its('name') { should include "bastion-#{service}-#{component}-#{deployment_identifier}" }
  # Redundant, but flags if I've botched the aws_ec2_instances code
  its('states') { should include 'running' }
end
