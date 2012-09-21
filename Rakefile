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

def command(dir, command)
  sh "cd #{dir_path(dir)} && #{command}"
end

PROJECTS = [:api, :sql, :postgres, :mysql, :sqlite, :riak]

PROJECTS.each do |project|
  namespace project do
    package(project.to_s)
  end
end

def create_task_for_all(task_name)
  task task_name => PROJECTS.map {|project| "#{project}:#{task_name}"}
end

desc 'Run the specs for Hyperion'
create_task_for_all(:spec)

desc 'Install Hyperion'
create_task_for_all(:install)

desc 'Release all Hyperion gems'
create_task_for_all(:release)

task :default => :spec
