require 'test_helper'

class TestMain < Minitest::Test
  def test_main_simple
    mktmpdir do |dir|
      original = dir / 'original.rb'
      current  = dir / 'current.rb'
      other    = dir / 'other.rb'
      data_original = DataDir / 'simple/original.rb'
      data_current  = DataDir / 'simple/patched1.rb'
      data_other    = DataDir / 'simple/patched2.rb'
      FileUtils.cp(data_original, original)
      FileUtils.cp(data_current, current)
      FileUtils.cp(data_other, other)

      status = MergeDbSchema.main([original.to_s, current.to_s, other.to_s])

      assert status == 0
      assert original.read == data_original.read
      assert other.read == data_other.read
      assert current.read != data_current.read

      assert !data_current.read.match(/version: 20170628094212/)
      assert current.read.match(/version: 20170628094212/)
      assert !current.read.match(/\={7,}/)
      assert !current.read.match(/\<{7,}/)
      assert !current.read.match(/\>{7,}/)
    end
  end

  def test_main_simple_reverse
    mktmpdir do |dir|
      original = dir / 'original.rb'
      current  = dir / 'current.rb'
      other    = dir / 'other.rb'
      data_original = DataDir / 'simple/original.rb'
      data_current  = DataDir / 'simple/patched2.rb'
      data_other    = DataDir / 'simple/patched1.rb'
      FileUtils.cp(data_original, original)
      FileUtils.cp(data_current, current)
      FileUtils.cp(data_other, other)

      status = MergeDbSchema.main([original.to_s, current.to_s, other.to_s])

      assert status == 0
      assert original.read == data_original.read
      assert other.read == data_other.read
      assert current.read == data_current.read

      assert current.read.match(/version: 20170628094212/)
      assert !current.read.match(/\={7,}/)
      assert !current.read.match(/\<{7,}/)
      assert !current.read.match(/\>{7,}/)
    end
  end
end
