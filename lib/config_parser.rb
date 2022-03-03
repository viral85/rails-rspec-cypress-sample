require "yaml"
require "erb"

class ConfigParser
  def self.parse(file, environment)
    YAML.safe_load(ERB.new(IO.read(file)).result, aliases: true)[environment]
  end
end
