require 'test/unit'
require 'rr'
require 'test/unit/rr'
require 'rubygems'

require 'bundler'
require 'coveralls'
Coveralls.wear!

begin
  Bundler.setup(:default, :xzibit, :test)
rescue Bundler::BundlerError => e
  $stderr.puts e.message
  $stderr.puts "Run `bundle install` to install missing gems"
  exit e.status_code
end

require 'rake'
require 'shoulda'
#require 'redgreen'
require 'test_construct'
require 'git'
require 'time'

require 'juwelier'

$LOAD_PATH.unshift(File.dirname(__FILE__))
require 'shoulda_macros/juwelier_macros'

TMP_DIR = '/tmp/juwelier_test'
FIXTURE_DIR = File.expand_path('../fixtures', __FILE__)

class RubyForgeStub
  attr_accessor :userconfig, :autoconfig
  def initialize
    @userconfig = {}
    @autoconfig = {}
  end
end

class Test::Unit::TestCase
  include TestConstruct::Helpers

  def tmp_dir
    TMP_DIR
  end

  def fixture_dir
    File.join(FIXTURE_DIR, 'bar')
  end

  def remove_tmpdir!
    FileUtils.rm_rf(tmp_dir)
  end

  def create_tmpdir!
    FileUtils.mkdir_p(tmp_dir)
  end

  def build_spec(*files)
    Gem::Specification.new do |s|
      s.name = "bar"
      s.summary = "Simple and opinionated helper for creating Rubygem projects on GitHub"
      s.email = "fred.mitchell@gmx.com"
      s.homepage = "http://github.com/flajann2/juwelier"
      s.description = "Simple and opinionated helper for creating Rubygem projects on GitHub"
      s.authors = ["Josh Nichols"]
      s.files = FileList[*files] unless files.empty?
      s.version = '0.1.1'
    end
  end

  def self.gemcutter_command_context(description, &block)
    context description do
      setup do
        @command = eval(self.class.name.gsub(/::Test/, '::')).new

        if @command.respond_to? :gemspec_helper=
          @gemspec_helper = Object.new
          @command.gemspec_helper = @gemspec_helper
        end

        if @command.respond_to? :output
          @output = StringIO.new
          @command.output = @output
        end
      end

      context "", &block
    end
  end

  def self.rubyforge_command_context(description, &block)
    context description do
      setup do
        @command = eval(self.class.name.gsub(/::Test/, '::')).new

        if @command.respond_to? :gemspec=
          @gemspec = Object.new
          @command.gemspec = @gemspec
        end

        if @command.respond_to? :gemspec_helper=
          @gemspec_helper = Object.new
          @command.gemspec_helper = @gemspec_helper
        end

        if @command.respond_to? :rubyforge=
          @rubyforge = RubyForgeStub.new
          @command.rubyforge = @rubyforge
        end

        if @command.respond_to? :output
          @output = StringIO.new
          @command.output = @output
        end

        if @command.respond_to? :repo
          @repo = Object.new
          @command.repo = @repo 
        end
      end

      context "", &block
    end
  end

  def self.build_command_context(description, &block)
    context description do
      setup do

        @repo           = Object.new
        @version_helper = Object.new
        @gemspec        = Object.new
        @commit         = Object.new
        @version        = Object.new
        @output         = Object.new
        @base_dir       = Object.new
        @gemspec_helper = Object.new
        @rubyforge      = Object.new

        @juwelier        = Object.new

        stub(@juwelier).repo           { @repo }
        stub(@juwelier).version_helper { @version_helper }
        stub(@juwelier).gemspec        { @gemspec }
        stub(@juwelier).commit         { @commit }
        stub(@juwelier).version        { @version }
        stub(@juwelier).output         { @output }
        stub(@juwelier).gemspec_helper { @gemspec_helper }
        stub(@juwelier).base_dir       { @base_dir }
        stub(@juwelier).rubyforge    { @rubyforge }
      end

      context "", &block
    end

  end

  def stub_git_config(options = {})
    stub(Git).global_config() { options }
  end

  def set_default_git_config
    @project_name = 'the-perfect-gem'
    @git_name = 'foo'
    @git_email = 'bar@example.com'
    @github_user = 'flajann2'
  end

  def valid_git_config
    { 'user.name' => @git_name, 'user.email' => @git_email, 'github.user' => @github_user }
  end
end
