# coding: utf-8
require 'git'
require 'github_api'
require 'highline/import'
require 'erb'
require 'kamelcase'
require 'net/http'
require 'uri'

require 'fileutils'
require 'pathname'

require 'juwelier/version'

class Juwelier
  class NoGitUserName < StandardError
  end
  class NoGitUserEmail < StandardError
  end
  class FileInTheWay < StandardError
  end
  class NoGitHubRepoNameGiven < StandardError
  end
  class NoGitHubUser < StandardError
  end
  class GitInitFailed < StandardError
  end    
  class GitRepoCreationFailed < StandardError
  end

  # Generator for creating a juwelier-enabled project
  class Generator    
    require 'juwelier/generator/options'
    require 'juwelier/generator/application'

    require 'juwelier/generator/github_mixin'

    require 'juwelier/generator/bacon_mixin'
    require 'juwelier/generator/micronaut_mixin'
    require 'juwelier/generator/minitest_mixin'
    require 'juwelier/generator/rspec_mixin'
    require 'juwelier/generator/shoulda_mixin'
    require 'juwelier/generator/testspec_mixin'
    require 'juwelier/generator/testunit_mixin'
    require 'juwelier/generator/riot_mixin'
    require 'juwelier/generator/shindo_mixin'

    require 'juwelier/generator/rdoc_mixin'
    require 'juwelier/generator/yard_mixin'

    attr_accessor :target_dir, :user_name, :user_email, :summary, :homepage,
                  :description, :project_name, :github_username,
                  :repo, :should_create_remote_repo, 
                  :testing_framework, :documentation_framework,
                  :should_use_cucumber, :should_use_bundler, :should_use_semver,
                  :should_setup_rubyforge, :should_use_reek, :should_use_roodi,
                  :development_dependencies, :production_dependencies,
                  :options, :require_ruby_version, :should_create_bin,
                  :git_remote, :use_readme_format, :should_use_pry,
                  :should_be_rusty

    def initialize(options = {})
      self.options = options
      extracted_directory = nil

      self.project_name   = options[:project_name]
      if self.project_name.nil? || self.project_name.squeeze.strip == ""
        raise NoGitHubRepoNameGiven
      else
        path = File.split(self.project_name)

        if path.size > 1
          extracted_directory = File.join(path[0..-1])
          self.project_name = path.last
        end
      end

      self.development_dependencies = []
      self.production_dependencies = []
      self.testing_framework  = options[:testing_framework]
      self.documentation_framework = options[:documentation_framework]
      begin
        generator_mixin_name = "#{self.testing_framework.to_s.capitalize}Mixin"
        generator_mixin = self.class.const_get(generator_mixin_name)
        extend generator_mixin
      rescue NameError => e
        raise ArgumentError, "Unsupported testing framework (#{testing_framework})"
      end

      begin
        generator_mixin_name = "#{self.documentation_framework.to_s.capitalize}Mixin"
        generator_mixin = self.class.const_get(generator_mixin_name)
        extend generator_mixin
      rescue NameError => e
        raise ArgumentError, "Unsupported documentation framework (#{documentation_framework})"
      end

      self.target_dir             = options[:directory] || extracted_directory || self.project_name

      self.summary                = options[:summary] || 'TODO: one-line summary of your gem'
      self.description            = options[:description] || 'TODO: longer description of your gem'
      self.should_use_cucumber    = options[:use_cucumber]
      self.should_use_reek        = options[:use_reek]
      self.should_use_roodi       = options[:use_roodi]
      self.should_setup_rubyforge = options[:rubyforge]
      self.should_use_bundler     = options[:use_bundler]
      self.should_use_semver      = options[:use_semver]
      self.require_ruby_version   = options[:use_required_version]
      self.should_create_bin      = options[:create_bin]
      self.should_be_rusty        = options[:be_rusty]
      self.should_use_pry         = options[:use_pry]
      self.use_readme_format      = options[:readme_format]

      development_dependencies << ["cucumber", ">= 0"] if should_use_cucumber

      development_dependencies << ["bundler", ">= 1.0"]
      development_dependencies << ["juwelier", "~> #{Juwelier::Version::STRING}"]
      development_dependencies << ["simplecov", ">= 0"]
      
      development_dependencies << ["reek", "~> 1.2.8"] if should_use_reek
      development_dependencies << ["roodi", "~> 2.1.0"] if should_use_roodi
      
      development_dependencies <<
        ["pry",                "~> 0"] <<
        ["pry-byebug",         "~> 3"] <<
        ["pry-doc",            "~> 0"] <<
        ["pry-remote",         "~> 0"] <<
        ["pry-rescue",         "~> 1"] <<
        ["pry-stack_explorer", "~> 0"] if should_use_pry
                                         
      production_dependencies << ["semver2", "~> 3"] if should_use_semver
      production_dependencies << ['ffi', '~> 1'] if should_be_rusty
      
      self.user_name       = options[:user_name]
      self.user_email      = options[:user_email]
      self.homepage        = options[:homepage]
      
      self.git_remote      = options[:git_remote]

      raise NoGitUserName unless self.user_name
      raise NoGitUserEmail unless self.user_email

      extend GithubMixin
    end

    def run
      create_files
      create_version_control
      $stdout.puts "Juwelier has prepared your gem in #{target_dir}"
      if should_create_remote_repo
        create_and_push_repo
        $stdout.puts "Juwelier has pushed your repo to #{git_remote}"
      end
    end

    def constant_name
      self.project_name.snake.camel
    end

    def extension_name
      "lib#{self.project_name.snake}.so"
    end
    
    def lib_filename ; "#{project_name}.rb" ; end
    def bin_filename ; "#{should_create_bin}" ; end

    def require_name
      self.project_name
    end

    def file_name_prefix
      self.project_name.gsub('-', '_')
    end

    def lib_dir      ; 'lib'      ; end
    def bin_dir      ; 'bin'      ; end    
    def rust_dir     ; 'rust'     ; end
    def rust_src_dir ; rust_dir + '/src' ; end

    def feature_filename
      "#{project_name}.feature"
    end

    def steps_filename
      "#{project_name}_steps.rb"
    end

    def features_dir
      'features'
    end

    def features_support_dir
      File.join(features_dir, 'support')
    end

    def features_steps_dir
      File.join(features_dir, 'step_definitions')
    end

  private

    def create_files
      unless File.exist?(target_dir) || File.directory?(target_dir)
        FileUtils.mkdir target_dir
      else
        raise FileInTheWay, "The directory #{target_dir} already exists, aborting. Maybe move it out of the way before continuing?"
      end

      output_template_in_target '.gitignore'
      output_template_in_target 'Rakefile'
      if should_use_bundler
        output_template_in_target 'Gemfile'
        system 'bundle install'
      end
      output_template_in_target 'LICENSE.txt'
      output_template_in_target "README.#{use_readme_format}"
      output_template_in_target '.document'

      mkdir_in_target           lib_dir
      unless should_be_rusty
        touch_in_target           File.join(lib_dir, lib_filename)
      else
        output_template_in_target File.join(lib_dir, 'rustygem.rb'),
                                  File.join(lib_dir, lib_filename)
      end

      if should_use_semver
        output_template_in_target '.semver'
      end
      
      if should_create_bin
        mkdir_in_target           bin_dir
        touch_in_target           File.join(bin_dir, bin_filename)

        mkdir_in_target           test_dir
        output_template_in_target File.join(testing_framework.to_s, 'helper.rb'),
                                  File.join(test_dir, test_helper_filename)
        output_template_in_target File.join(testing_framework.to_s, 'flunking.rb'),
                                  File.join(test_dir, test_filename)
      end

      if should_be_rusty
        mkdir_in_target rust_dir
        output_template_in_target File.join(rust_dir, 'Cargo.toml')
        output_template_in_target File.join(rust_dir, 'extconf.rb')
        output_template_in_target File.join(rust_dir, 'Makefile')
        mkdir_in_target rust_src_dir
        output_template_in_target File.join(rust_src_dir, 'lib.rs')
      end
      
      if testing_framework == :rspec
        output_template_in_target File.join(testing_framework.to_s, '.rspec'),
                                  '.rspec'
      end

      if should_use_cucumber
        mkdir_in_target           features_dir
        output_template_in_target File.join(%w(features default.feature)), File.join('features', feature_filename)

        mkdir_in_target           features_support_dir
        output_template_in_target File.join(features_support_dir, 'env.rb')

        mkdir_in_target           features_steps_dir
        touch_in_target           File.join(features_steps_dir, steps_filename)
      end
    end

    def render_template(source)
      template_contents = File.read(File.join(template_dir, source))
      template          = ERB.new(template_contents, nil, '<>')

      # squish extraneous whitespace from some of the conditionals
      template.result(binding).gsub(/\n\n\n+/, "\n\n")
    end

    def output_template_in_target(source, destination = source)
      final_destination = File.join(target_dir, destination)
      template_result   = render_template(source)

      File.open(final_destination, 'w') {|file| file.write(template_result)}

      $stdout.puts "\tcreate\t#{destination}"
    end

    def template_dir
      File.join(File.dirname(__FILE__), 'templates')
    end

    def mkdir_in_target(directory)
      final_destination = File.join(target_dir, directory)

      FileUtils.mkdir final_destination

      $stdout.puts "\tcreate\t#{directory}"
    end

    def touch_in_target(destination)
      final_destination = File.join(target_dir, destination)
      FileUtils.touch  final_destination
      $stdout.puts "\tcreate\t#{destination}"
    end

    def create_version_control
      Dir.chdir(target_dir) do
        begin
          @repo = Git.init()
        rescue Git::GitExecuteError => e
          raise GitInitFailed, "Encountered an error during gitification. Maybe the repo already exists, or has already been pushed to?"
        end

        begin
          @repo.add('.')
        rescue Git::GitExecuteError => e
          #raise GitAddFailed, "There was some problem adding this directory to the git changeset"
          raise
        end

        begin
          @repo.commit "Initial commit to #{project_name}."
        rescue Git::GitExecuteError => e
          raise
        end

        begin
          @repo.add_remote('origin', git_remote)
        rescue Git::GitExecuteError => e
          puts "Encountered an error while adding origin remote. Maybe you have some weird settings in ~/.gitconfig?"
          raise
        end
      end
    end
    
    def create_and_push_repo
      puts "Please provide your Github password to create the Github repository"
      begin
        login = github_username
        password = ask("Password: ") { |q| q.echo = false }
        github = Github.new(:login => login.strip, :password => password.strip)
        github.repos.create(:name => project_name, :description => summary)
      rescue Github::Error::Unauthorized
        puts "Wrong login/password! Please try again"
        retry
      rescue Github::Error::UnprocessableEntity
        raise GitRepoCreationFailed, "Can't create that repo. Does it already exist?"
      end
      # TODO do a HEAD request to see when it's ready?
      @repo.push('origin')
    end
  end
end
