class Juwelier
  module Commands
    class InstallGem
      include FileUtils

      attr_accessor :gemspec_helper, :output

      def initialize
        self.output = $stdout
      end

      def run
        command = "#{gem_command} install #{gemspec_helper.gem_path}"
        output.puts "Executing #{command.inspect}:"

        sh command # TODO where does sh actually come from!? - rake, apparently
      end

      def gem_command
        "#{RbConfig::CONFIG['RUBY_INSTALL_NAME']} -S gem"
      end

      def self.build_for(juwelier)
        command = new
        command.output = juwelier.output
        command.gemspec_helper = juwelier.gemspec_helper
        command
      end
    end
  end
end
