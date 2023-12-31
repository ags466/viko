# validate-website

## Description

Web crawler for checking the validity of your documents

![validate website](https://raw.github.com/spk/validate-website/master/validate-website.png)

## Installation

### Debian

```
apt install ruby-dev libxslt1-dev libxml2-dev
```

If you want complete local validation look [tidy
packages](https://binaries.html-tidy.org/)

### RubyGems

```
gem install validate-website
```

## Synopsis

```
validate-website [OPTIONS]
validate-website-static [OPTIONS]
```

## Examples

```
validate-website -v -s https://www.ruby-lang.org/
validate-website -v -x tidy -s https://www.ruby-lang.org/
validate-website -v -x nu -s https://www.ruby-lang.org/
validate-website -h
```

## Description

validate-website is a web crawler for checking the markup validity with XML
Schema / DTD and not found urls (more info [doc/validate-website.adoc](https://github.com/spk/validate-website/blob/master/doc/validate-website.adoc)).

validate-website-static checks the markup validity of your local documents with
XML Schema / DTD (more info [doc/validate-website-static.adoc](https://github.com/spk/validate-website/blob/master/doc/validate-website-static.adoc)).

HTML5 support with [libtidy5](http://www.html-tidy.org/) or [Validator.nu Web
Service](https://checker.html5.org/).

## Exit status

* 0: Markup is valid and no 404 found.
* 64: Not valid markup found.
* 65: There are pages not found.
* 66: There are not valid markup and pages not found.

## On your application

``` ruby
require 'validate_website/validator'
body = '<!DOCTYPE html><html></html>'
v = ValidateWebsite::Validator.new(Nokogiri::HTML(body), body)
v.valid? # => false
```

## Jekyll static site validation

You can add this Rake task to validate a
[jekyll](https://github.com/jekyll/jekyll) site:

``` ruby
desc 'validate _site with validate website'
task validate: :build do
    Dir.chdir("_site") do
      system("validate-website-static",
               "--verbose",
               "--exclude", "examples",
               "--site", HTTP_URL)
      exit($?.exitstatus)
    end
  end
end
```

## More info

### HTML5

#### Tidy5

If the libtidy5 is found on your system this will be the default to validate
your html5 document. This does not depend on a tier service everything is done
locally.

#### nokogiri

nokogiri can validate html5 document without tier service but reports less
errors than tidy.

#### Validator.nu web service

When `--html5-validator nu` option is used HTML5 support is done by using the
Validator.nu Web Service, so the content of your webpage is logged by a tier.
It's not the case for other validation because validate-website use the XML
Schema or DTD stored on the data/ directory.

Please read <http://about.validator.nu/#tos> for more info on the HTML5
validation service.

##### Use validator standalone web server locally

You can download [validator](https://github.com/validator/validator) jar and
start it with:

```
java -cp PATH_TO/vnu.jar nu.validator.servlet.Main 8888
```

Then you can use validate-website option:

```
--html5-validator-service-url http://localhost:8888/
# or
export VALIDATOR_NU_URL="http://localhost:8888/"
```

This will prevent you to be blacklisted from validator webservice.

## Tests

With standard environment:

```
bundle exec rake
```

## Credits

* Thanks tenderlove for Nokogiri, this tool is inspired from markup_validity.
* And Chris Kite for Anemone web-spider framework and postmodern for Spidr.

## Contributors

See [GitHub](https://github.com/spk/validate-website/graphs/contributors).

## License

The MIT License

Copyright (c) 2009-2022 Laurent Arnoud <laurent@spkdev.net>

---
[![Build](https://img.shields.io/gitlab/pipeline/spkdev/validate-website/master)](https://gitlab.com/spkdev/validate-website/-/commits/master)
[![Coverage](https://gitlab.com/spkdev/validate-website/badges/master/coverage.svg)](https://gitlab.com/spkdev/validate-website/-/commits/master)
[![Version](https://img.shields.io/gem/v/validate-website.svg)](https://rubygems.org/gems/validate-website)
[![Documentation](https://img.shields.io/badge/doc-rubydoc-blue.svg)](http://www.rubydoc.info/gems/validate-website)
[![License](https://img.shields.io/badge/license-MIT-blue.svg)](http://opensource.org/licenses/MIT "MIT")
[![Inline docs](https://inch-ci.org/github/spk/validate-website.svg?branch=master)](http://inch-ci.org/github/spk/validate-website)
