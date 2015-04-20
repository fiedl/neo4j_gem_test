class User < ActiveRecord::Base
  has_neo_node

  def title
    self.name
  end
end
