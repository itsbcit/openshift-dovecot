require "erb"

# @ripienaar https://www.devco.net/archives/2010/11/18/a_few_rake_tips.php
def render_template(template, output, scope)
  tmpl = File.read(template)
  erb = ERB.new(tmpl, 0, "<>")
  File.open(output, "w") do |f|
    f.puts erb.result(scope)
  end
end

maintainer = 'jesse_weisner@bcit.ca'
org_name = 'bcit'
image_name = 'openshift-dovecot'
databases = [ 'mysql', 'pgsql', 'sql' ]
database = ''
version = '2.3.5.1-r0'
version_segments = version.split('.')
patch_segments = version_segments[3].split('-')
tags = [
  "#{version_segments[0]}.#{version_segments[1]}.#{version_segments[2]}.#{patch_segments[0]}",
  "#{version_segments[0]}.#{version_segments[1]}.#{version_segments[2]}",
  "#{version_segments[0]}.#{version_segments[1]}",
  'latest'
]

desc "Template, build, tag, push"
task :default do
  Rake::Task[:Dockerfile].invoke
  Rake::Task[:build].invoke
  Rake::Task[:test].invoke
  Rake::Task[:tag].invoke
  Rake::Task[:push].invoke
end

desc "Update Dockerfile templates"
task :Dockerfile do
  render_template("Dockerfile.erb", "Dockerfile", binding)

  databases.each do |database|
    render_template("Dockerfile.erb", "Dockerfile-#{database}", binding)
  end
end

desc "Build docker images"
task :build do
  sh "docker build -t #{org_name}/#{image_name}:#{version} ."

  databases.each do |database|
    sh "docker build -t #{org_name}/#{image_name}:#{version}-#{database} -f Dockerfile-#{database} ."
  end
end

desc "Test docker images"
task :test do
  puts "Running tests on #{org_name}/#{image_name}:#{version}"
  puts "lol"
  databases.each do |database|
    puts "Running tests on #{org_name}/#{image_name}:#{version}-#{database}"
    puts "lol"
  end
end

desc "Tag docker images"
task :tag do
  tags.each do |tag|
    sh "docker tag #{org_name}/#{image_name}:#{version} #{org_name}/#{image_name}:#{tag}"
  end

  databases.each do |database|
    tags.each do |tag|
      sh "docker tag #{org_name}/#{image_name}:#{version}-#{database} #{org_name}/#{image_name}:#{tag}-#{database}"
    end
  end
end

desc "Push to Docker Hub"
task :push do
  sh "docker push #{org_name}/#{image_name}:#{version}"

  tags.each do |tag|
    sh "docker push #{org_name}/#{image_name}:#{tag}"
  end

  databases.each do |database|
    sh "docker push #{org_name}/#{image_name}:#{version}-#{database}"

    tags.each do |tag|
      sh "docker push #{org_name}/#{image_name}:#{tag}-#{database}"
    end
  end
end
