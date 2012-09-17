require File.expand_path('../config', __FILE__)

def package(name)
  desc "Clean #{name}"
  task :clean do
    command(name, 'rm -rf Gemfile.lock pkg')
  end

  desc "Gather dependencies for #{name}"
  task :deps => :clean do
    command(name, 'bundle install')
  end

  desc "Install #{name}"
  task :install do
    command(name, 'rake install')
  end

  desc "Run #{name} specs"
  task :spec => :deps do
    command(name, 'bundle exec rspec')
  end

  task :remove_version_tag do
    sh "git tag --delete v#{Hyperion::VERSION}" do |ok, res|
    end
  end

  desc "Release #{name}"
  task :release => :remove_version_tag do
    command(name, 'rake release')
  end
end

def dir_path(dir)
  File.expand_path(File.join('..', dir), __FILE__)
end

def dir_command(dir, command)
  "cd #{dir_path(dir)} && #{command}"
end

def return_command(dir, command)
  sh dir_command(dir, command) do |ok, res|
    return ok
  end
end

def command(dir, command)
  sh dir_command(dir, command)
end

namespace :api do
  package('api')
end

namespace :postgres do
  package('postgres')
end

namespace :mysql do
  package('mysql')
end

namespace :sql do
  package('sql')
end

namespace :sqlite do
  package('sqlite')
end

PROJECTS = [:api, :sql, :postgres, :mysql, :sqlite]

def create_task_for_all(task_name)
  task task_name => PROJECTS.map {|project| "#{project}:#{task_name}"}
end

desc 'Run the specs for Hyperion'
create_task_for_all(:spec)

desc 'Install Hyperion'
create_task_for_all(:install)

task :default => [:spec, :install]
