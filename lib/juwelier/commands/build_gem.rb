class Juwelier
  module Commands
    class BuildGem
      attr_accessor :base_dir, :gemspec_helper, :file_utils, :version_helper

      def initialize
        self.file_utils = FileUtils
      end

      def run
        gemspec_helper.update_version(version_helper) unless gemspec_helper.has_version?

        gemspec = gemspec_helper.parse

        if Gem::Version.new(`gem -v`) >= Gem::Version.new("2.0.0.a")
          gem_file_name = Gem::Package.build(gemspec)
        else
          require "rubygems/builder"
          gem_file_name = Gem::Builder.new(gemspec).build
        end

        pkg_dir = File.join(base_dir, 'pkg')
        file_utils.mkdir_p pkg_dir

        gem_file_name = File.join(base_dir, gem_file_name)
        file_utils.mv gem_file_name, pkg_dir
      end

      def self.build_for(juwelier)
        command = new

        command.base_dir = juwelier.base_dir
        command.gemspec_helper = juwelier.gemspec_helper
        command.version_helper = juwelier.version_helper

        command
      end
    end
  end
end
