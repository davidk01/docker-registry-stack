require 'fileutils'
require 'pathname'

DOCKERFILES = 'Dockerfiles'
NAMEFILE = 'name'
VERSIONFILE = 'version'
TEMPLATE = 'Dockerfile.template'
DAEMON = 'localhost:5000'

desc "Make a directory with a template Dockerfile"
task :add, [:name] do |t, args|
  name = args[:name]
  dir = Pathname.new(File.join(DOCKERFILES, name)).cleanpath
  if dir.exist?
    raise StandardError, "Directory already exists: #{dir}"
  end
  # Make the directory and write down the necessary bits
  FileUtils.mkdir_p(dir)
  namefile = File.join(dir, NAMEFILE)
  open(namefile, 'w') {|f| f.write(name)}
  versionfile = File.join(dir, VERSIONFILE)
  open(versionfile, 'w') {|f| f.write '0.1'}
  dockerfile = File.join(dir, 'Dockerfile')
  FileUtils.cp(TEMPLATE, dockerfile)
end

desc "Build, tag, and push a specific Dockerfile directory contents. Directory is relative to #{DOCKERFILES} directory"
task :build, [:dirname] do |t, args|
  dir = Pathname.new(File.join(DOCKERFILES, args[:dirname])).cleanpath
  namefile = File.join(dir, NAMEFILE)
  versionfile = File.join(dir, VERSIONFILE)
  name = File.read(namefile).strip
  version = File.read(versionfile).strip
  tag = "#{name}:#{version}"
  sh "docker rmi '#{tag}' || echo Image does not exist"
  sh "docker rmi '#{DAEMON}/#{tag}' || echo Image does not exist"
  sh "cd #{dir} && docker build -t '#{tag}' ."
  sh "docker tag '#{tag}' #{DAEMON}/#{tag}"
  sh "docker push #{DAEMON}/#{tag}"
end

desc "Remove all the '*.done' files. This assumes images have been removed from local registry."
task :clean do |t, args|
  sh "rm -rf *.done"
end

desc "Remove non-running containers"
task :cleancontainers do |t, args|
  running = `docker ps -q`.split("\n")
  non_running = `docker ps -a -q`.split("\n").reject {|c| running.include?(c)}
  if non_running.any?
    sh "docker rm #{non_running.join(' ')}"
  end
end

# Now for each Dockerfile create a file dependency for CI purposes and add to default task
Dir["#{DOCKERFILES}/*"].each do |dir|
  name = Pathname.new(dir).cleanpath.basename
  immediate_dependencies = FileList.new(File.join(dir, '*'))
  if (extra_dependencies_file = Pathname.new(File.join(dir, 'dependencies')).cleanpath).exist?
    STDOUT.puts "#{name} has extra dependencies on previously built docker images."
    extra_dependencies = FileList.new(File.read(extra_dependencies_file).split("\n").reject(&:empty?).map {|f| "#{f}.done"})
    STDOUT.puts "#{name} will also depend on #{extra_dependencies.join(', ')}"
  else
    extra_dependencies = []
  end
  dependencies = immediate_dependencies + extra_dependencies
  desc "Will build and push #{name}. To add more dependencies add them to #{name}.done file task"
  file "#{name}.done" => dependencies do |t, args|
    Rake::Task[:build].execute(:dirname => name)
    sh "touch #{name}.done"
  end
  task :default => "#{name}.done"
end
