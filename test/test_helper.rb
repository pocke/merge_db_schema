require 'tmpdir'
require 'pathname'
require 'fileutils'

require 'minitest'
require 'minitest/autorun'

require 'merge_db_schema'

def mktmpdir(&block)
  Dir.mktmpdir do |dir|
    Dir.chdir(dir) do
      yield Pathname(dir)
    end
  end
end

class CommandExecutionError < StandardError; end

def sh!(*commands)
  puts commands.join(' ')
  system(*commands)
  raise CommandExecutionError, "command execution is failed. status: #{$?.exitstatus}" unless $?.success?
end

DataDir = Pathname(__dir__) / 'data'
