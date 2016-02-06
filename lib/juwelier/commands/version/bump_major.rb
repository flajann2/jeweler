class Juwelier
  module Commands
    module Version
      class BumpMajor < Base

        def update_version
          self.version_helper.bump_major
        end

      end
    end
  end
end
