require 'rubygems'
require_gem 'rake'
require 'rake/clean'
require 'rake/rdoctask'
require 'rake/gempackagetask'
require 'rake/contrib/rubyforgepublisher'
require 'rake/runtest'

PROJECT_NAME = 'bangkok'
RUBYFORGE_USER = 'jimm'
RDOC_DIR = 'html'

PKG_FILES = FileList[ 'ChangeLog', 'Credits', 'README', 'Rakefile', 'TODO',
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
  s.email = 'jimm@io.com'
  s.homepage = 'http://bangkok.rubyforge.org'
  s.rubyforge_project = PROJECT_NAME

  s.summary = "Chess game file reader and player; can turn games into MIDI files"
  s.description = <<EOF
Bangkok can read chess game descriptions and re-play the games. Notice of
events (moves, captures, checks, etc.) are sent to a listener. Bangkok comes
with a listener that generates a MIDI file. In other words, the chess game is
turned into music.
EOF
end

# Creates a :package task (also named :gem). Also useful are :clobber_package
# and :repackage.
Rake::GemPackageTask.new(spec) do |pkg|
  pkg.need_zip = true
  pkg.need_tar = true
end

# require 'rbconfig'
# if Config::CONFIG['target_os'] =~ /mswin/i
#   RDOC_FILES = FileList['README', 'TODO', 'lib/**/*.rb']
#   RDOC_FILES.each { | f | file f }
#   task :rdoc => RDOC_FILES do
#     ruby "#{File.join(Config::CONFIG['bindir'], 'rdoc')} -o html " +
#       " --main 'README' --title '#{PROJECT_NAME}' -T 'html' #{RDOC_FILES}"
#   end
# else
  # creates an "rdoc" task
  Rake::RDocTask.new do | rd |
    rd.main = 'README'
    rd.title = PROJECT_NAME
    rd.rdoc_files.include('README', 'TODO', 'lib/**/*.rb')
  end
# end

task :rubyforge => [:rdoc] do
  Rake::RubyForgePublisher.new(PROJECT_NAME, RUBYFORGE_USER).upload
end

task :test do
  Rake::run_tests
end
