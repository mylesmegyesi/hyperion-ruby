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
end

def spec(name)
  desc "Run #{name} specs"
  task :spec => :deps do
    command(name, 'bundle exec rspec')
  end
end

def dir_path(dir)
  File.expand_path(File.join('..', dir), __FILE__)
end

def return_command(dir, command)
  sh "cd #{dir_path(dir)} && #{command}" do |ok, res|
    return ok
  end
end

def command(dir, command)
  sh "cd #{dir_path(dir)} && #{command}"
end

namespace :core do
  package('core')
  spec('core')
end

namespace :postgres do
  package('postgres')
  spec('postgres')
end

namespace :mysql do
  package('mysql')
  spec('mysql')
end

namespace :sql do
  package('sql')
end

PROJECTS = [:core, :postgres, :mysql]
ALL = [:core, :sql, :postgres, :mysql]

def create_task_for_all(task_name, projects=PROJECTS)
  task task_name => projects.map {|project| "#{project}:#{task_name}"}
end

desc 'Run the specs for Hyperion'
create_task_for_all(:spec)

desc 'Install Hyperion'
create_task_for_all(:install, ALL)

task :default => [:spec, :install]
