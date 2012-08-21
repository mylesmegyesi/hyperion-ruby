def package(name)
  desc "Gather dependencies for #{name}"
  task :deps do
    deps(name)
  end

  desc "Run #{name} specs"
  task :spec => :deps do
    spec(name)
  end
end

def spec(dir)
  command(dir, 'bundle exec rspec')
end

def deps(dir)
  command(dir, 'bundle install')
end

def command(dir, command)
  sh "cd #{dir} && #{command}"
end

namespace :core do
  package('core')
end

PROJECTS = [:core]

def create_task_for_all(task_name)
  task task_name => PROJECTS.map {|project| "#{project}:#{task_name}"}
end

desc 'Run the specs for Hyperion'
create_task_for_all(:spec)

task :default => :spec
