# frozen_string_literal: true

# Version file for ValidateWebsite
module ValidateWebsite
  VERSION = '1.12.0'

  def self.jruby? # :nodoc:
    defined?(RUBY_ENGINE) && RUBY_ENGINE == 'jruby'
  end
end
