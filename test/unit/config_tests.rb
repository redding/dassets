require 'assert'
require 'ns-options/assert_macros'
require 'dassets'

class Dassets::Config

  class BaseTests < Assert::Context
    include NsOptions::AssertMacros
    desc "Dassets::Config"
    setup do
      @config = Dassets::Config.new
    end
    subject{ @config }

    should have_option :assets_file, Pathname,  :default => ENV['DASSETS_ASSETS_FILE']
    should have_options :file_store

    should have_reader :combinations
    should have_imeth :source, :combination, :combination?

    should "register new sources with the `source` method" do
      path = '/path/to/app/assets'
      filter = proc{ |paths| [] }
      subject.source(path){ |s| s.filter(&filter) }

      assert_equal 1, subject.sources.size
      assert_kind_of Dassets::Source, subject.sources.first
      assert_equal path, subject.sources.first.path
      assert_equal filter, subject.sources.first.filter
    end

    should "know its combinations and return the keyed digest path by default" do
      assert_kind_of ::Hash, subject.combinations
      assert_equal ['some/digest.path'], subject.combinations['some/digest.path']
    end

    should "allow registering new combinations" do
      assert_equal ['some/digest.path'], subject.combinations['some/digest.path']
      exp_combination = ['some/other.path', 'and/another.path']
      subject.combination 'some/digest.path', exp_combination
      assert_equal exp_combination, subject.combinations['some/digest.path']

      assert_equal ['test/digest.path'], subject.combinations['test/digest.path']
      subject.combination 'test/digest.path', ['some/other.path']
      assert_equal ['some/other.path'], subject.combinations['test/digest.path']
    end

    should "know which digest paths are actual combinations and which are just pass-thrus" do
      subject.combination 'some/combination.path', ['some.path', 'another.path']

      assert     subject.combination? 'some/combination.path'
      assert_not subject.combination? 'some/non-combo.path'
    end

  end

end
