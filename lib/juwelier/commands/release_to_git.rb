class Juwelier
  module Commands
    class ReleaseToGit
      attr_accessor :gemspec, :version, :repo, :output, :gemspec_helper, :base_dir

      def initialize(attributes = {})
        self.output = $stdout

        attributes.each_pair do |key, value|
          send("#{key}=", value)
        end
      end

      def run(args = {})
        remote = args[:remote] || 'origin'
        branch = args[:branch] || 'master'
        local_branch = args[:local_branch] || branch
        remote_branch = args[:remote_branch] || branch

        unless clean_staging_area?
          system "git status"
          raise "Unclean staging area! Be sure to commit or .gitignore everything first. See `git status` above."
        end

        repo.checkout(local_branch)
        repo.push(remote, "#{local_branch}:#{remote_branch}")

        if release_not_tagged?
          output.puts "Tagging #{release_tag}"
          repo.add_tag(release_tag)

          output.puts "Pushing #{release_tag} to #{remote}"
          repo.push(remote, release_tag)
        end
      end

      def clean_staging_area?
        `git ls-files --deleted --modified --others --exclude-standard` == ""
      end

      def release_tag
        "v#{version}"
      end

      def release_not_tagged?
        tag = repo.tag(release_tag) rescue nil
        tag.nil?
      end

      def self.build_for(juwelier)
        command = self.new

        command.base_dir = juwelier.base_dir
        command.gemspec = juwelier.gemspec
        command.version = juwelier.version
        command.repo = juwelier.repo
        command.output = juwelier.output
        command.gemspec_helper = juwelier.gemspec_helper

        command
      end
    end
  end
end
