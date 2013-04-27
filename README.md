# Dassets

Digest and serve HTML asset files.

## Usage

You have some css, js, images, etc files.  You want to update, deploy, and serve them in an efficient way.  Dassets can help.

### Setup

```ruby
# in config/dassets.rb
require 'dassets'

Dassets.configure do |c|

  # tell Dassets what the root path of your app is
  c.root_path '/path/to/app/root'

  # tell Dassets where to write the digests
  c.digests_path '/path/to/.digests' # default: '{source_path}/.digests'

  # tell Dassets where to look for source files and (optionally) how to filter those files
  c.source_path 'lib/asset_files' # default: '{root_path}/app/assets'
  c.source_filter proc{ |paths| paths.select{ |p| ... } }
  # --OR--
  c.sources 'lib/asset_files' do |paths|
    # return the filtered source path list
    paths.select{ |p| ... }
  end

  # tell Dassets where to write output files to
  # it works best to *not* output to your public dir if using fingerprinting
  c.output_path '/lib/assets_output' # default: '{source_path}/public'

end
```

### Digest

You can use the CLI to digest your source files on demand:

```
$ dassets digest                       # digest all source files, OR
$ dassets digest /path/to/source/file  # digest some specific files
```

Or you can programmatically digest files as needed:

```ruby
Dassets.digest_source_files                           # digest all source files, OR
Dassets.digest_source_files ['/path/to/source/file']  # digest just some specific files
```

Digesting involves combining, compiling, fingerprinting, and outputting each source file.  Once a source has been digested, it is available for linking, serving, and/or caching.

### Link To

```rb
Dassets.init
Dassets['css/site.css'].href       # => "/css/site-123abc.css"
Dassets['img/logos/main.jpg'].href # => "/img/logos/main-a1b2c3.jpg"
```

### Serve

In development, use the Dassets middleware to serve your digested asset files:

```ruby
# `app` is a rack application
require 'dassets/server'
app.use Dassets::Server
```

In production, use the CLI to cache your digested asset files to the public dir:

```
# call the CLI in your deploy scripts or whatever
$ dassets cache /path/to/public/dir
```

TODO: programmatically cache asset files

## Compiling

Dassets can handle compiling your asset source as part of its digest pipeline.  It does this via "engines".  Engines transform source extensions and content.

Engines are "registered" with dassets based on source extensions.  Name your source file with registered extensions and those engines will be used to compile your source content.

### Some Dassets Engines

Examples are key here, so check out some of the Dasset's engines available:

TODO

### Creating your own Engine

* create a class that subclasses `Dassets::Engine`
* override the `ext` method to specify how the input source extension should be handled
* override the `compile` method to specify how the input content should be transformed
* register your engine class with Dassets

## Combinations

TODO

## Installation

Add this line to your application's Gemfile:

    gem 'dassets'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install dassets

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
