def package(name)
  desc "Clean #{name}"
  task :clean do
    command(name, 'rm -rf Gemfile.lock pkg')
  end

  desc "Gather dependencies for #{name}"
  task :deps  => :clean do
    command(name, 'bundle install')
  end

  desc "Run #{name} specs"
  task :spec => :deps do
    command(name, 'bundle exec rspec')
  end

  desc "Install #{name}"
  task :install do
    command(name, 'rake install')
  end
end

def dir_path(dir)
  File.expand_path(File.join('..', dir), __FILE__)
end

def command(dir, command)
  sh "cd #{dir_path(dir)} && #{command}"
end

namespace :core do
  package('core')
end

namespace :postgres do
  task :deps => 'core:install'
  package('postgres')
end

PROJECTS = [:core, :postgres]

def create_task_for_all(task_name)
  task task_name => PROJECTS.map {|project| "#{project}:#{task_name}"}
end

desc 'Run the specs for Hyperion'
create_task_for_all(:spec)

task :default => :spec
