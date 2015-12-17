require 'assert/factory'

module Factory
  extend Assert::Factory

  def self.base_url
    Factory.boolean ? Factory.url : nil
  end

end
