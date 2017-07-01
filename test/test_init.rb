require 'test_helper'

class TestMain < Minitest::Test
  def test_init_without_git_dir
    mktmpdir do |dir|
      ex = assert_raises { MergeDBSchema::Init.init([]) }
      assert ex.is_a?(MergeDBSchema::Init::NotGitDirectoryError)
    end
  end
end
