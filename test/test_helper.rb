require 'tmpdir'
require 'pathname'
require 'fileutils'

require 'minitest'
require 'minitest/autorun'

require 'merge_db_schema'

def mktmpdir(&block)
  Dir.mktmpdir do |dir|
    yield Pathname(dir)
  end
end

DataDir = Pathname(__dir__) / 'data'
