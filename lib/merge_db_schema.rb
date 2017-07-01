require 'pathname'
require 'rainbow'
require "merge_db_schema/version"

module MergeDbSchema
  class << self
    RE_DEFINE = /^ActiveRecord::Schema.define\(version:\s(\d+)\)\sdo$/

    # Usage: merge_db_schema %O %A %B
    # @param argv [Array<String>]
    # @return [Integer] status code
    def main(argv)
      original = Pathname(argv[0])
      current = Pathname(argv[1])
      other = Pathname(argv[2])

      current_text = current.read
      other_text   = other.read

      version1 = current_text[RE_DEFINE, 1].to_i
      version2 = other_text[RE_DEFINE, 1].to_i
      version = [version1, version2].max

      update_version(current, version)
      update_version(other, version)
      update_version(original, version)

      `git merge-file -q #{current} #{original} #{other}`
      return $?.exitstatus
    end

    def init(argv)
      force = argv[0] == '--force'

      gitattributes = "db/schema.rb merge=merge_db_schema\n"
      gitconfig = <<~END
        [merge "merge_db_schema"]
        \tname = Merge db/schema.rb
        \tdriver = merge_db_schema %O %A %B
        \trecursive = text
      END

      print 'Initializing .gitattributes ... '
      File.open('.gitattributes', 'a') do |f|
        f.write(gitattributes)
      end
      puts Rainbow('done!').green

      if force
        print 'Initializing .git/config ... '
        File.open('.git/config', 'a') do |f|
          f.write(gitconfig)
        end
        puts Rainbow('done!').green
        puts Rainbow('Successfully initialized!')
      else
        puts 'Add the following code into .git/config, initializing is completed!'
        puts
        puts gitconfig
      end
    end

    private

    def update_version(path, version)
      text = path.read
      text[RE_DEFINE, 1] = version.to_s
      path.write(text)
    end
  end
end
