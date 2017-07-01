module MergeDBSchema
  module Init
    class << self
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
    end
  end
end
