require 'test_helper'

class TestMain < Minitest::Test
  def test_main_simple
    mktmpdir do |dir|
      original = dir / 'original.rb'
      current  = dir / 'patched1.rb'
      other    = dir / 'patched2.rb'
      data_current = DataDir / 'simple/patched1.rb'
      copy(DataDir / 'simple', dir)

      status = MergeDBSchema::Main.main([original.to_s, current.to_s, other.to_s])

      assert status == 0
      assert_merged(current, data_current, DataDir.join('simple/expected.rb'))
    end
  end

  def test_main_simple_reverse
    mktmpdir do |dir|
      original = dir / 'original.rb'
      current  = dir / 'patched2.rb'
      other    = dir / 'patched1.rb'
      data_current = DataDir / 'simple/patched2.rb'
      copy(DataDir / 'simple', dir)

      status = MergeDBSchema::Main.main([original.to_s, current.to_s, other.to_s])

      assert status == 0
      assert_merged(current, data_current, DataDir.join('simple/expected.rb'))
    end
  end

  def test_main_conflict
    mktmpdir do |dir|
      original = dir / 'original.rb'
      current  = dir / 'patched1.rb'
      other    = dir / 'patched2.rb'
      data_current = DataDir / 'conflict/patched1.rb'
      copy(DataDir / 'conflict', dir)

      status = MergeDBSchema::Main.main([original.to_s, current.to_s, other.to_s])

      assert status == 1
      assert_conflict(current, data_current, DataDir.join('conflict/expected.rb'))
    end
  end

  def test_main_conflict_reverse
    mktmpdir do |dir|
      original = dir / 'original.rb'
      current  = dir / 'patched2.rb'
      other    = dir / 'patched1.rb'
      data_current = DataDir / 'conflict/patched2.rb'
      copy(DataDir / 'conflict', dir)

      status = MergeDBSchema::Main.main([original.to_s, current.to_s, other.to_s])

      assert status == 1
      assert_conflict(current, data_current, DataDir.join('conflict/expected.rb'))
    end
  end

  # @param src [Pathname]
  # @param dst [Pathname]
  def copy(src, dst)
    files = Dir.glob(src / '*')
    FileUtils.cp files, dst
  end

  # @param current [Pathname]
  # @param current_original [Pathname]
  # @param expected [Pathname]
  def assert_merged(current, current_original, expected)
    assert current.read != current_original.read
    assert_equal current.read, expected.read

    assert_match(/version: 20170628094212/, current.read)
    refute current.read.match(/\={7,}/)
    refute current.read.match(/\<{7,}/)
    refute current.read.match(/\>{7,}/)
  end

  # @param current [Pathname]
  # @param current_original [Pathname]
  # @param expected [Pathname]
  def assert_conflict(current, current_original, expected)
    assert current.read != current_original.read

    assert_match(/version: 20170701093311/, current.read)
    assert current.read.match(/\={7,}/)
    assert current.read.match(/\<{7,}/)
    assert current.read.match(/\>{7,}/)
  end
end
