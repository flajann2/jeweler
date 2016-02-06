require 'pathname'

class Juwelier
  module Commands
    module Version
      class Base

        attr_accessor :repo, :version_helper, :gemspec, :commit, :base_dir

        def run
          update_version

          self.version_helper.write
          self.gemspec.version = self.version_helper.to_s

          commit_version if self.repo && self.commit
        end

        def update_version
          raise "Subclasses should implement this"
        end

        def commit_version
          if self.repo
            self.repo.add(working_subdir.join(version_helper.path).to_s)
            self.repo.commit("Version bump to #{self.version_helper.to_s}")
          end
        end

        def working_subdir
          return @working_subdir if @working_subdir
          cwd = base_dir_path
          @working_subdir = cwd.relative_path_from(Pathname.new(repo.dir.path))
          @working_subdir
        end

        def base_dir_path
          Pathname.new(base_dir).realpath
        end


        def self.build_for(juwelier)
          command = new
          command.repo = juwelier.repo
          command.version_helper = juwelier.version_helper
          command.gemspec = juwelier.gemspec
          command.commit = juwelier.commit
          command.base_dir = juwelier.base_dir

          command
        end
      end
    end
  end
end
