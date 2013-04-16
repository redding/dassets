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

  # it works best to *not* keep the asset files in your public dir
  c.files_path '/path/to/not/public' # default: '{root_path}/app/assets/public'

  # you can choose the file to write the digests to, if you want
  c.digests_file_path '/path/to/.digests' # default: '{files_path}/app/assets/.digests'

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
Dassets['css/site.css'].href       # => "/css/site-123abc.css"
Dassets['img/logos/main.jpg'].href # => "/img/logos/main-a1b2c3.jpg"
```

### Serve

In development, use the Dassets middleware to serve your digested asset files:

TODO: setup code example

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
