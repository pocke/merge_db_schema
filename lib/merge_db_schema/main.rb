module MergeDBSchema
  module Main
    RE_DEFINE = /^ActiveRecord::Schema.define\(version:\s([\d,_]+)\)\sdo$/

    class << self
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

      private

      def update_version(path, version)
        text = path.read
        text[RE_DEFINE, 1] = version.to_s
        path.write(text)
      end
    end
  end
end
