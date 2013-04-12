require 'assert'
require 'ns-options/assert_macros'
require 'dassets'

class Dassets::Config

  class BaseTests < Assert::Context
    include NsOptions::AssertMacros
    desc "Dassets::Config"
    subject{ Dassets::Config }

    should have_option  :root_path, Pathname, :required => true
    should have_options :files_path, :digests_file_path

    should "should use `apps/assets/public` as the default files path" do
      exp_path = Dassets.config.root_path.join("app/assets/public").to_s
      assert_equal exp_path, subject.files_path
    end

    should "should use `app/assets/.digests` as the default digests file path" do
      exp_path = Dassets.config.root_path.join("app/assets/.digests").to_s
      assert_equal exp_path, subject.digests_file_path
    end

  end

end
