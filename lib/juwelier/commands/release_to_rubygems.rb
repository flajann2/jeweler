class Juwelier
  module Commands
    class ReleaseToRubygems
      include FileUtils

      attr_accessor :gemspec, :version, :output, :gemspec_helper

      def initialize
        self.output = $stdout
      end

      def run
        command = "gem push #{@gemspec_helper.gem_path}"
        output.puts "Executing #{command.inspect}:"
        sh command
      end

      def self.build_for(juwelier)
        command = new
        command.gemspec        = juwelier.gemspec
        command.gemspec_helper = juwelier.gemspec_helper
        command.version        = juwelier.version
        command.output         = juwelier.output
        command
      end
    end
  end
end
