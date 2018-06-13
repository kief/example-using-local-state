require 'confidante'
require 'rake_terraform'
require 'rake_docker'
require 'rake/clean'

require_relative 'lib/paths'
require_relative 'lib/terraform_output'
require_relative 'lib/version'
require_relative 'lib/secure_parameter'
require_relative 'lib/key_maker'

configuration = Confidante.configuration

my_ip = `curl -s icanhazip.com`.chomp

RakeTerraform.define_installation_tasks(
  path: File.join(Dir.pwd, 'vendor', 'terraform'),
  version: '0.11.7'
)

CLEAN.include('build')
CLEAN.include('work')
CLEAN.include('dist')
CLOBBER.include('vendor')

deployment_stacks = Dir.entries('deployment').select { |stack|
  File.directory? File.join('deployment', stack) and File.exists?("deployment/#{stack}/stack.yaml")
}

task :default => [ :plan ]

desc 'Show the plan for changes to the deployment stacks'
task :plan => deployment_stacks.map { |deployment_stack|
  :"deployment:#{deployment_stack}:plan"
}

desc 'Provision the deployment stacks'
task :provision => deployment_stacks.map { |deployment_stack|
  :"deployment:#{deployment_stack}:provision"
}

desc 'Destroy the deployment stacks'
task :destroy => deployment_stacks.map { |deployment_stack|
  :"deployment:#{deployment_stack}:destroy"
}

namespace :deployment do

  Dir.entries('deployment').select { |entry|
    File.directory? File.join('deployment',entry) and !(entry =='.' || entry == '..')
  }.each { |deployment_stack|

    namespace deployment_stack do

      stack_configuration = configuration
        .for_scope(deployment: deployment_stack)

      unless stack_configuration.ssh_keys.nil?
        desc "Ensure ssh keys for #{deployment_stack}"
        task :ssh_keys do
          puts  "Need ssh keys:"
          stack_configuration.ssh_keys.each { |ssh_key_name|
            puts "  - #{ssh_key_name}"
            secure_parameter_ssh_key_public = "/#{configuration.estate}/#{configuration.component}/#{deployment_stack}/#{configuration.deployment_identifier}/ssh_key/#{ssh_key_name}/public"
            secure_parameter_ssh_key_private = "/#{configuration.estate}/#{configuration.component}/#{deployment_stack}/#{configuration.deployment_identifier}/ssh_key/#{ssh_key_name}/private"

            public_key = SecureParameter.get_parameter(secure_parameter_ssh_key_public, configuration.region)
            if public_key.nil? then
              puts "Generating a new ssh key #{ssh_key_name}"
              key = KeyMaker.make_key(ssh_key_name)
              SecureParameter.put_parameter(secure_parameter_ssh_key_public, key[:public], configuration.region)
              SecureParameter.put_parameter(secure_parameter_ssh_key_private, key[:private], configuration.region)
              public_key = key[:public]
            end
            puts "ssh key is in 'work/deployment/#{deployment_stack}/ssh_keys/#{ssh_key_name}.pub'"
            mkpath "work/deployment/#{deployment_stack}/ssh_keys"
            File.open("work/deployment/#{deployment_stack}/ssh_keys/#{ssh_key_name}.pub", 'w') {|f| f.write(public_key) }
          }
        end

        task :plan => [ :ssh_keys ]
        task :provision => [ :ssh_keys ]
      end

      RakeTerraform.define_command_tasks do |t|

        t.configuration_name = "deployment-#{deployment_stack}"
        t.source_directory = "deployment/#{deployment_stack}/infra"
        t.work_directory = 'work'

        puts "============================="
        puts "deployment/#{deployment_stack}"
        puts "============================="

        t.state_file = lambda do
          Paths.from_project_root_directory('state', 'example', 'statebucket', 'statebucket.tfstate')
        end

        t.vars = lambda do |args|
          args = { :my_ip => my_ip }.merge(args)
          configuration
              .for_overrides(args)
              .for_scope(deployment: deployment_stack)
              .vars
        end
        puts "tfvars:"
        puts "---------------------------------------"
        puts "#{t.vars.call({}).to_yaml}"
        puts "---------------------------------------"
      end

      if Dir.exist? ("deployment/#{deployment_stack}/inspec")

        desc 'Test things'
        task :test do
          mkpath "work/inspec"
          File.open("work/inspec/attributes-deployment-#{deployment_stack}.yml", 'w') {|f| 
            f.write({
              'deployment_identifier' => configuration.deployment_identifier,
              'component' => configuration.component,
              'deployment_stack' => configuration.deployment_stack
            }.to_yaml)
          }

          inspec_cmd = 
            "inspec exec " \
            "deployment/#{deployment_stack}/inspec " \
            "-t aws:// " \
            "--reporter json-rspec:work/inspec/results-deployment-#{deployment_stack}.json " \
            "cli " \
            "--attrs work/inspec/attributes-deployment-#{deployment_stack}.yml"
          puts "INSPEC: #{inspec_cmd}"
          system(inspec_cmd)
        end
      end

    end

  }
end
