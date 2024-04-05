# frozen_string_literal: true

module Codalio
  # Returns the currently loaded version of \Rails as a +Gem::Version+.
  def self.gem_version
    Gem::Version.new VERSION::STRING
  end

  module VERSION
    MAJOR = 0
    MINOR = 1
    TINY  = 0
    PRE   = "beta.1"

    STRING = [MAJOR, MINOR, TINY, PRE].compact.join(".")
  end
end
