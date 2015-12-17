# Dassets

Digest and serve HTML asset files.

## Usage

You have some css, js, images, etc files.  You want to update, deploy, and serve them in an efficient way.  Dassets can help.

### Setup

```ruby
# in config/dassets.rb
require 'dassets'

Dassets.configure do |c|

  # tell Dassets where to look for source files
  c.source '/path/to/app/assets'

  # (optional) tell Dassets where to store digested asset files
  # if none given, Dassets will not write any digested output
  # use this to "cache" digested assets to the public dir so that
  # your web server can serve them directly
  c.file_store '/path/to/public' # default: `FileStore::NullStore.new`

end
```

### Link To

```rb
Dassets['css/site.css'].url       # => "/css/site-123abc.css"
Dassets['img/logos/main.jpg'].url # => "/img/logos/main-a1b2c3.jpg"
```

### Serve

Use the Dassets middleware to serve your digested asset files:

```ruby
# `app` is a rack application
require 'dassets/server'
app.use Dassets::Server
```

## Compiling

Dassets compiles your asset source as part of its digest pipeline using "engines".  Engines transform source extensions and content.

Engines are "registered" with dassets based on source extensions.  Name your source file with registered extensions and those engines will be used to compile your source content.

### Some Dassets Engines

Examples are key here, so check out some of the Dasset engines available:

* **Erb**:       https://github.com/redding/dassets-erb
* **Sass**:      https://github.com/redding/dassets-sass
* **Less (v1)**: https://github.com/redding/dassets-lessv1

### Creating your own Engine

* create a class that subclasses `Dassets::Engine`
* override the `ext` method to specify how the input source extension should be handled
* override the `compile` method to specify how the input content should be transformed
* register your engine class with Dassets

## Sources

Sources model a root location for asset files.  They also provide configuration for how assets in that location should be processed and handled.

You can specify filters that control which paths in the location are considered.  You can also register engines which determine how the contents of assets files are handled.  For example:

```ruby
Dassets.configure do |c|
  c.source /path/to/assets do |s|
    s.filter{ |paths| paths.reject{ |p| File.basename(p) =~ /^_/ } }

    s.engine 'erb',  Dassets::Erb::Engine
    s.engine 'scss', Dassets::Sass::Engine, {
      :syntax => 'scss'
      # any other engine-specific options here
    }
  end
end
```

This configuration says that Dassets, for assets in `/path/to/assets`, should 1) ignore any files beginning in `_` 2) process any files ending in `.erb` with the Erb engine and 3) process any files ending in `.scss` with the Sass engine (using 'scss' syntax).

The goal here is to allow you to control how certain asset files are handled based on their location root.  This is handy for 3rd-paty gems that provide asset source files (such as [Romo](https://github.com/redding/romo)).  See https://github.com/redding/romo/blob/master/lib/romo/dassets.rb for an example of how Romo integrates with Dassets.

## Combinations

Combinations are a way to alias many asset files as a single asset.  Dassets responds to requests for the combined asset by concatenating the combination's asset files into a single response.  For example:

```ruby
Dassets.configure do |c|
  c.combination "css/special.css", [
    'css/romo/normalize.css',
    'css/romo/base.css',
    'css/romo/component1.css'
  ]
end
```

This example tells Dassets that if it receives a request for the `css/special.css` asset it should return the content of the 3 files concatenated in that order.

Combinations are treated just like regular asset files (think of them as a kind of alias).  They can be cached/digested/etc just as if they were a true asset file.  Again, see https://github.com/redding/romo/blob/master/lib/romo/dassets.rb for an example of using combinations to abstract the composition of 3rd-party asset files.

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
