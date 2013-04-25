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

```
$ dassets digest                      # rebuild the .digests for all asset files, OR
$ dassets digest /path/to/asset/file  # update the digest for just one file
```

Use the CLI to build your digests file.  Protip: use guard to auto rebuild digests every time you edit an asset file.  TODO: link to some guard tools or docs.

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
