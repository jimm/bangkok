require 'rake/clean'
if RUBY_VERSION >= '1.9'
  require 'rdoc/task'
  require 'rubygems/package_task'
  require 'rake/testtask'
else
require 'rake/rdoctask'
  require 'rake/gempackagetask'
  require 'rake/runtest'
end

PROJECT_NAME = 'bangkok'
RUBYFORGE_USER = 'jimm'
RDOC_DIR = 'html'

PKG_FILES = FileList['ChangeLog', 'Credits', 'README', 'Rakefile', 'TODO',
                     'examples/**/*',
                     'html/**/*',
                     'install.rb',
                     'lib/**/*.rb',
                     'test/**/*.rb']
CLEAN.include('game.mid', 'game.txt')

task :default => [:package]

spec = Gem::Specification.new do |s|
  s.platform = Gem::Platform::RUBY
  s.name = PROJECT_NAME
  s.version = `ruby -Ilib -e 'require "bangkok/info"; puts Version'`.strip
  s.requirements << 'midilib'
  s.add_dependency('midilib', '>= 0.8.4')

  s.require_path = 'lib'
  s.autorequire = PROJECT_NAME

  s.files = PKG_FILES.to_a
  s.executables = ['bangkok']
  s.bindir = 'bin'

  s.has_rdoc = true
  s.rdoc_options << '--main' << 'README'
  s.extra_rdoc_files = ['README', 'TODO']

  s.author = 'Jim Menard'
  s.email = 'jim@jimmenard.com'
  s.homepage = 'https://github.com/jimm/bangkok'
  s.rubyforge_project = PROJECT_NAME

  s.summary = "Chess game file reader and player; can turn games into MIDI files"
  s.description = <<EOF
Bangkok can read chess game descriptions and re-play the games. Notice of
events (moves, captures, checks, etc.) are sent to a listener. Bangkok comes
with a listener that generates a MIDI file. In other words, the chess game is
turned into music.
EOF
end

if RUBY_VERSION >= '1.9'
  # Creates a :package task (also named :gem). Also useful are
  # :clobber_package and :repackage.
  Gem::PackageTask.new(spec) do |pkg|
    pkg.need_zip = true
    pkg.need_tar = true
  end
else
  # Creates a :package task (also named :gem). Also useful are
  # :clobber_package and :repackage.
  Rake::GemPackageTask.new(spec) do |pkg|
    pkg.need_zip = true
    pkg.need_tar = true
  end
end

# creates an "rdoc" task
Rake::RDocTask.new do | rd |
  rd.main = 'README'
  rd.title = PROJECT_NAME
  rd.rdoc_files.include('README', 'TODO', 'lib/**/*.rb')
end

task :rubyforge => [:rdoc] do
  Rake::RubyForgePublisher.new(PROJECT_NAME, RUBYFORGE_USER).upload
end

if RUBY_VERSION >= '1.9'
  Rake::TestTask.new do |t|
    t.libs << File.join(File.dirname(__FILE__), 'test')
    t.libs << File.join(File.dirname(__FILE__), 'lib')
    # Lets me use local dev version of midilib
    t.libs << File.join(ENV['MIDILIB_HOME'], 'lib') if ENV['MIDILIB_HOME']
    t.ruby_opts << '-rubygems'
    t.pattern = "test/**/test_*.rb"
  end
else
  task :test do
    Rake::run_tests
  end
end
