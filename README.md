# MergeDBSchema

[![Build Status](https://travis-ci.org/pocke/merge_db_schema.svg?branch=master)](https://travis-ci.org/pocke/merge_db_schema)

It is a git merge driver for `db/schema.rb` of Ruby on Rails.
It resolves some of the conflict automatically.

![out](https://user-images.githubusercontent.com/4361134/27761416-665a6ee8-5e96-11e7-852d-5eddc9c2a6b8.gif)

```bash
# Can't merge a branch because schema version is conflicted.
$ git merge change1
Auto-merging db/schema.rb
CONFLICT (content): Merge conflict in db/schema.rb
Automatic merge failed; fix conflicts and then commit the result.

$ git diff
diff --cc db/schema.rb
index bdb07db,da150fc..0000000
--- a/db/schema.rb
+++ b/db/schema.rb
@@@ -10,7 -10,7 +10,11 @@@
  #
  # It's strongly recommended that you check this file into your version control system.
  
++<<<<<<< HEAD
 +ActiveRecord::Schema.define(version: 20170701103541) do
++=======
+ ActiveRecord::Schema.define(version: 20170701103437) do
++>>>>>>> change1
  
    create_table "articles", force: :cascade do |t|
      t.string   "title"

$ git merge --abort

# Install merge_db_schema
$ merge_db_schema-init --force
Initializing .gitattributes ... done!
Initializing .git/config ... done!
Successfully initialized!

# The conflict is resolved automatically!
$ git merge change1
Auto-merging db/schema.rb
Merge made by the 'recursive' strategy.
 db/migrate/20170701103437_add_address_to_user.rb | 5 +++++
 db/schema.rb                                     | 1 +
 2 files changed, 6 insertions(+)
 create mode 100644 db/migrate/20170701103437_add_address_to_user.rb
```



## Installation

Add this line to your application's Gemfile:

```ruby
gem 'merge_db_schema'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install merge_db_schema

### Initializing this gem

Run `merge_db_schema-init` and edit `.git/config`.

```bash
$ merge_db_schema-init
Initializing .gitattributes ... done!
Add the following code into .git/config, initializing is completed!

[merge "merge_db_schema"]
	name = Merge db/schema.rb
	driver = merge_db_schema %O %A %B
	recursive = text
```

If you add `--force` option to the command, it edits `.git/config` automatically.

```bash
$ merge_db_schema-init --force
Initializing .gitattributes ... done!
Initializing .git/config ... done!
Successfully initialized!
```


Note: `.git/config` **is not tracked by Git**. So, other team members should edit `.git/config` to use this gem.



License
-------

Apache License 2.0
See [LICENSE](https://github.com/pocke/merge_db_schema/blob/master/LICENSE)
