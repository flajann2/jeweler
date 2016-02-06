require 'shellwords'

class Juwelier
  class Generator
    class Application
      class << self
        include Shellwords

        def run!(*arguments)
          options = build_options(arguments)

          if options[:invalid_argument]
            $stderr.puts options[:invalid_argument]
            options[:show_help] = true
          end

          if options[:show_version]
            $stderr.puts "Version: #{Juwelier::Version::STRING}"
            return 1
          end

          if options[:show_help]
            $stderr.puts options.opts
            return 1
          end

          if options[:project_name].nil? || options[:project_name].squeeze.strip == ""
            $stderr.puts options.opts
            return 1
          end

          begin
            generator = Juwelier::Generator.new(options)
            generator.run
            return 0
          rescue Juwelier::NoGitUserName
            $stderr.puts %Q{No user.name found in ~/.gitconfig. Please tell git about yourself (see http://help.github.com/git-email-settings/ for details). For example: git config --global user.name "mad voo"}
            return 1
          rescue Juwelier::NoGitUserEmail
            $stderr.puts %Q{No user.email found in ~/.gitconfig. Please tell git about yourself (see http://help.github.com/git-email-settings/ for details). For example: git config --global user.email mad.vooo@gmail.com}
            return 1
          rescue Juwelier::NoGitHubUser
            $stderr.puts %Q{Please specify --github-username or set github.user in ~/.gitconfig (see http://github.com/blog/180-local-github-config for details). For example: git config --global github.user defunkt}
            return 1
          rescue Juwelier::FileInTheWay
            $stderr.puts "The directory #{options[:project_name]} already exists. Maybe move it out of the way before continuing?"
            return 1
          end
        end

        def build_options(arguments)
          env_opts_string = ENV['JUWELIER_OPTS'] || ""
          env_opts        = Juwelier::Generator::Options.new(shellwords(env_opts_string))
          argument_opts   = Juwelier::Generator::Options.new(arguments)

          env_opts.merge(argument_opts)
        end

      end

    end
  end
end
