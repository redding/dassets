# This takes a path string relative to the configured root path and tranforms
# to the full qualifed root path.  The goal here is to specify path options
# with root-relative path strings.

module Dassets; end
class Dassets::RootPath < String

  def initialize(path_string)
    super(Dassets.config.root_path.join(path_string).to_s)
  end

end
