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

def sh!(*commands)
  puts commands.join(' ')
  system(*commands)
  raise "command execution is failed. status: #{$?.exitstatus}" unless $?.success?
end

DataDir = Pathname(__dir__) / 'data'
