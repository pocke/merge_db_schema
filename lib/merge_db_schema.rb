require 'pathname'
require 'rainbow'
require "merge_db_schema/version"

module MergeDbSchema
  class << self
    RE_DEFINE_STR = '^ActiveRecord::Schema.define\\(version:\\s(\\d+)\\)\\sdo$'
    RE_DEFINE = Regexp.new(RE_DEFINE_STR)
    RE_VERSION = /
      ^\<{7,}\s.+$\n
      #{RE_DEFINE_STR}\n
      ^={7,}$\n
      #{RE_DEFINE_STR}\n
      ^\>{7,}\s.+$
    /x
    RE_EQ = /^={7,}$/

    # Usage: merge_db_schema %O %A %B
    # @param argv [Array<String>]
    # @return [Integer] status code
    def main(argv)
      original = argv[0]
      current = argv[1]
      other = argv[2]

      diffed = `git merge-file -pq #{current} #{original} #{other}`
      return 1 if diffed.scan(RE_EQ).size != 1
      match = diffed.match(RE_VERSION)
      return 1 unless match

      version1 = match[1].to_i
      version2 = match[2].to_i
      version = [version1, version2].max

      current_text = Pathname(current).read
      current_text[RE_DEFINE, 1] = version.to_s
      Pathname(current).write(current_text)
      return 0
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

  end
end
