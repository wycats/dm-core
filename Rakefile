#!/usr/bin/env ruby

require 'pathname'
require 'rubygems'
require 'rake'
require Pathname('spec/rake/spectask')
require Pathname('rake/rdoctask')
require Pathname('rake/gempackagetask')
require Pathname('rake/contrib/rubyforgepublisher')

# for __DIR__
require Pathname(__FILE__).dirname.expand_path + 'lib/data_mapper/support/kernel'

Pathname.glob(__DIR__ + 'tasks/**/*.rb') { |t| require t }

task :default => 'dm:spec'

task :environment => 'dm:environment'

namespace :dm do
  desc "Setup Environment"
  task :environment do
    require 'environment'
  end

  desc "Run specifications"
  Spec::Rake::SpecTask.new('spec') do |t|
    t.spec_opts = ["--format", "specdoc", "--colour"]
    t.spec_files = Pathname.glob(ENV['FILES'] || __DIR__ + 'spec/**/*_spec.rb')
    unless ENV['NO_RCOV']
      t.rcov = true
      t.rcov_opts << '--exclude' << 'spec,environment.rb'
      t.rcov_opts << '--text-summary'
      t.rcov_opts << '--sort' << 'coverage' << '--sort-reverse'
      t.rcov_opts << '--only-uncovered'
    end
  end

  desc "Run comparison with ActiveRecord"
  task :perf do
    load __DIR__ + 'script/performance.rb'
  end

  desc "Profile DataMapper"
  task :profile do
    load __DIR__ + 'script/profile_data_mapper.rb'
  end
end

PACKAGE_VERSION = '0.9.0'

PACKAGE_FILES = [
  'README',
  'FAQ',
  'QUICKLINKS',
  'CHANGELOG',
  'MIT-LICENSE',
  '*.rb',
  'lib/**/*.rb',
  'spec/**/*.{rb,yaml}',
  'tasks/**/*',
  'plugins/**/*'
].collect { |pattern| Pathname.glob(pattern) }.flatten.reject { |path| path.to_s =~ /(\/db|Makefile|\.bundle|\.log|\.o)\z/ }

DOCUMENTED_FILES = PACKAGE_FILES.reject do |path|
  path.directory? || path.to_s.match(/(?:^spec|\/spec|\/swig\_)/)
end

PROJECT = "dm-core"

task :ls do
  puts PACKAGE_FILES
end

desc "Generate Documentation"
rd = Rake::RDocTask.new do |rdoc|
  rdoc.rdoc_dir = 'doc'
  rdoc.title = "DataMapper -- An Object/Relational Mapper for Ruby"
  rdoc.options << '--line-numbers' << '--inline-source' << '--main' << 'README'
  rdoc.rdoc_files.include(*DOCUMENTED_FILES.map { |file| file.to_s })
end

gem_spec = Gem::Specification.new do |s|
  s.platform = Gem::Platform::RUBY
  s.name = PROJECT
  s.summary = "An Object/Relational Mapper for Ruby"
  s.description = "Faster, Better, Simpler."
  s.version = PACKAGE_VERSION

  s.authors = "Sam Smoot"
  s.email = "ssmoot@gmail.com"
  s.rubyforge_project = PROJECT
  s.homepage = "http://datamapper.org"

  s.files = PACKAGE_FILES.map { |f| f.to_s }

  s.require_path = "lib"
  s.requirements << "none"
  s.executables = ["dm"]
  s.bindir = "bin"
  s.add_dependency("english")
  s.add_dependency("json_pure")
  s.add_dependency("rspec")
  s.add_dependency("data_objects", ">=0.9.0")
  s.add_dependency("english")

  s.has_rdoc = true
  s.rdoc_options << "--line-numbers" << "--inline-source" << "--main" << "README"
  s.extra_rdoc_files = DOCUMENTED_FILES.map { |f| f.to_s }
end

Rake::GemPackageTask.new(gem_spec) do |p|
  p.gem_spec = gem_spec
  p.need_tar = true
  p.need_zip = true
end

desc "Publish to RubyForge"
task :rubyforge => [ :rdoc, :gem ] do
  Rake::SshDirPublisher.new("#{ENV['RUBYFORGE_USER']}@rubyforge.org", "/var/www/gforge-projects/#{PROJECT}", 'doc').upload
end

task :install => :package do
  sh %{sudo gem install pkg/#{PROJECT}-#{PACKAGE_VERSION}}
end

namespace :dev do
  desc "Install for development (for windows)"
  task :winstall => :gem do
    system %{gem install --no-rdoc --no-ri -l pkg/#{PROJECT}-#{PACKAGE_VERSION}.gem}
  end
end
