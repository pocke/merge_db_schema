require 'test_helper'

class TestMain < Minitest::Test
  def test_integration
    bin_path  = Pathname(__dir__) / '../exe/'
    load_path = Pathname(__dir__) / '../lib'
    original_path = ENV["PATH"]
    ENV['PATH'] = "#{bin_path}:#{ENV['PATH']}"
    env = {
      'RUBYOPT' => "-I#{load_path}",
    }

    mktmpdir do |dir|
      db_schema = dir.join('db/schema.rb')
      Dir.chdir(dir) do
        # Initialize the directory
        sh! 'git', 'init'
        sh! 'git', 'commit', '-m', 'first commit', '--allow-empty'

        sh! env, 'merge_db_schema-init', '--force'
        commit('Initialise merge_db_schema')

        dir.join('db').mkdir
        FileUtils.cp(DataDir.join('simple/original.rb'), db_schema)
        commit('Add db/schema.rb')

        sh! 'git', 'checkout', '-b', 'change1'
        FileUtils.cp(DataDir.join('simple/patched1.rb'), db_schema)
        commit('Update db/schema.rb on change1 branch')

        sh! 'git', 'checkout', 'master'
        sh! 'git', 'checkout', '-b', 'change2'
        FileUtils.cp(DataDir.join('simple/patched2.rb'), db_schema)
        commit('Update db/schema.rb on change2 branch')

        sh! 'git', 'branch', 'change2-original'
        assert db_schema.read != DataDir.join('simple/expected.rb').read
        sh! 'git', 'merge', '--no-edit', 'change1'
        assert_equal db_schema.read, DataDir.join('simple/expected.rb').read

        sh! 'git', 'checkout', 'change1'
        assert db_schema.read != DataDir.join('simple/expected.rb').read
        sh! 'git', 'merge', '--no-edit', 'change2-original'
        assert_equal db_schema.read, DataDir.join('simple/expected.rb').read
      end
    end
  ensure
    ENV['PATH'] = original_path
  end

  def commit(msg)
    sh! 'git', 'add', '.'
    sh! 'git', 'commit', '-m', msg
  end
end
