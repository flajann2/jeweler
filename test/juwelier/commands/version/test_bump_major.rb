require 'test_helper'

class Juwelier
  module Commands
    module Version
      class TestBumpMajor < Test::Unit::TestCase

        should "call bump_major on version_helper in update_version" do
          mock(version_helper = Object.new).bump_major

          command = Juwelier::Commands::Version::BumpMajor.new
          command.version_helper = version_helper

          command.update_version
        end
      end

    end
  end
end


