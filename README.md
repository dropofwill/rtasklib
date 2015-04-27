# Rtasklib

[![Coverage Status](https://travis-ci.org/dropofwill/rtasklib.svg?branch=master)](https://travis-ci.org/dropofwill/rtasklib) [![Coverage Status](https://coveralls.io/repos/dropofwill/rtasklib/badge.svg?branch=master)](https://coveralls.io/r/dropofwill/rtasklib?branch=master) [![yard docs](http://b.repl.ca/v1/yard-docs-blue.png)](http://will-paul.com/rtasklib)


## Description

A Ruby wrapper around the TaskWarrior CLI, based on the Python tasklib. Requires a working TaskWarrior install.


## Installation

Add this line to your application's Gemfile:

```ruby
gem 'rtasklib'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install rtasklib


## Dependencies

* Taskwarrior > 2.4 (require custom UDAs, recurrences, and duration data types)

* Ruby > 2 (currently untested on older versions)

* See `./rtasklib.gemspec` for the latest Ruby dependencies


## Usage

TODO: Write usage instructions here


## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release` to create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).


## License

Release under the MIT License (MIT) Copyright (&copy;) 2015 Will Paul


## Contributing

1. Fork it ( https://github.com/[my-github-username]/rtasklib/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
