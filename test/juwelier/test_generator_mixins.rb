require 'test_helper'

class TestGeneratorMixins < Test::Unit::TestCase

  [Juwelier::Generator::BaconMixin,
   Juwelier::Generator::MicronautMixin,
   Juwelier::Generator::MinitestMixin,
   Juwelier::Generator::RspecMixin,
   Juwelier::Generator::ShouldaMixin,
   Juwelier::Generator::TestspecMixin,
   Juwelier::Generator::TestunitMixin,
  ].each do |mixin|
    context "#{mixin}" do
      %w(default_task feature_support_require feature_support_extend
         test_dir test_task test_pattern test_filename
         test_helper_filename).each do |method|
          should "define #{method}" do
            assert mixin.method_defined?(method)
          end
       end
    end
  end
end
