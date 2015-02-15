# OperatingReport

A command line tool to handle operating reports.

## Installation

Create a Gemfile in any place:

```ruby
source "https://rubygems.org"
gem 'operating_report',  '~> 0.1.0', github: "artifactsauce/operating_report", branch: 'master'
```

And then execute:

    $ bundle install

## Usage

Firstly, create a config file.

    $ operating_report init

Create the report with a specified period.

    $ operating_report create daily
    $ operating_report create weekly
    $ operating_report create monthly

## Known problems

- If you had registered more than 100 records of the tasks during the month, it will create a wrong monthly report because it can not get all of the records by API restriction.


## Contributing

1. Fork it ( https://github.com/artifactsauce/operating_report/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
