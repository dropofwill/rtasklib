# Rtasklib

[![Coverage Status](https://travis-ci.org/dropofwill/rtasklib.svg?branch=master)](https://travis-ci.org/dropofwill/rtasklib) [![Coverage Status](https://coveralls.io/repos/dropofwill/rtasklib/badge.svg?branch=master)](https://coveralls.io/r/dropofwill/rtasklib?branch=master) [![yard docs](http://b.repl.ca/v1/yard-docs-blue.png)](http://will-paul.com/rtasklib)


## Description

A Ruby wrapper around the TaskWarrior command line tool.


## Installation

### Using `bundle` or `gem`

#### With Bundler

Add this line to your application's Gemfile:

```ruby
gem 'rtasklib'
```

And then execute:

    $ bundle

#### With Rubygems

Or install it yourself as:

    $ gem install rtasklib

With this method you will need to install TaskWarrior (version 2.4 or above) yourself.

**On OSX:**
    
    $ brew install task

**On Fedora:**

    $ yum install task

**On Debian/Ubuntu:**

The major repos TaskWarrior packages are extremely outdated, so you will have to install from source. The following is what we're using to build on Travis CI, your mileage may vary:

    $ sudo add-apt-repository ppa:ubuntu-toolchain-r/test -y
    $ sudo apt-get update -qq
    $ sudo apt-get install -qq build-essential cmake uuid-dev g++-4.8
    $ sudo update-alternatives --install /usr/bin/g++ g++ /usr/bin/g++-4.8 50
    $ git clone https://git.tasktools.org/scm/tm/task.git
    $ cd task
    $ git checkout $TASK_VERSION
    $ git clean -dfx
    $ cmake .
    $ make
    $ sudo make install

### Using the RPM

If you are running Fedora there is an RPM available, this comes with the advantage of being managed by `yum` and installing TaskWarrior for you. Simply get the desired version RPM from the `pkg/` dir:

    $ sudo yum install rubygem-rtasklib-VERSION.rpm

### Configure TaskWarrior

Once you install TaskWarrior a database still needs to be created, luckily this is as simple as running `task` and answer `yes` when it asks you about creating a `.taskrc` file.


## Dependencies

* Ruby > 2.0 (Uses keyword args)

* TaskWarrior > 2.4, require custom UDAs, recurrences, and duration data types (MIT license)

* ISO8601 gem, for dealing with duration and datetimes from TaskWarrior (MIT license)

* Virtus gem, for simple Ruby object based domain modeling (TaskModel and TaskrcModel) (MIT license)

* multi_json gem, for parsing JSON objects (MIT license)

* See `./rtasklib.gemspec` to verify the latest Ruby dependencies


## Usage

```ruby
require 'rtasklib'

tw = Rtasklib::TW.new('../path/to/.task')

# do some stuff with the task database
# available commands are documented in the Controller class

tw.all
```

[Controller docs](http://will-paul.com/rtasklib/Rtasklib/Controller.html)


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
