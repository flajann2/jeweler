require 'test_helper'

class Juwelier
  module Commands
    class TestValidateGemspec < Test::Unit::TestCase

      build_command_context "build context" do
        setup do
          @command = Juwelier::Commands::ValidateGemspec.build_for(@juwelier)
        end

        should "assign gemspec_helper" do
          assert_same @gemspec_helper, @command.gemspec_helper
        end

        should "assign output" do
          assert_same @output, @command.output
        end

        should "return Juwelier::Commands::ValidateGemspec" do
          assert_kind_of Juwelier::Commands::ValidateGemspec, @command
        end

      end
    end
  end
end
