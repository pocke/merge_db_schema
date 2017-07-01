require 'pathname'
require 'rainbow'
require "merge_db_schema/version"

module MergeDBSchema
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


      init_gitattribute
      init_gitconfig(force)
    end

    private

    def init_gitattribute
      print 'Initializing .gitattributes ... '
      gitattributes_content = "db/schema.rb merge=merge_db_schema\n"
      gitattr = Pathname('.gitattributes')
      if gitattr.exist? && gitattr.read.include?(gitattributes_content)
        puts Rainbow('skip').orange
      else
        gitattr.open('a') do |f|
          f.write(gitattributes_content)
        end
        puts Rainbow('done!').green
      end
    end

    def init_gitconfig(force)
      gitconfig_content = <<~END
        [merge "merge_db_schema"]
        \tname = Merge db/schema.rb
        \tdriver = merge_db_schema %O %A %B
        \trecursive = text
      END

      unless force
        puts 'Add the following code into .git/config, initializing is completed!'
        puts
        puts gitconfig_content
        return
      end

      gitconfig = Pathname('.git/config')
      print 'Initializing .git/config ... '
      if gitconfig.exist? && gitconfig.read.include?(gitconfig_content)
        puts Rainbow('skip').orange
      else
        gitconfig.open('a') do |f|
          f.write(gitconfig_content)
        end
        puts Rainbow('done!').green
      end

      puts Rainbow('Successfully initialized!')
    end

    def update_version(path, version)
      text = path.read
      text[RE_DEFINE, 1] = version.to_s
      path.write(text)
    end
  end
end
