module CodalioAi
  # Returns the currently loaded version of CodalioAi core as a +Gem::Version+.
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
