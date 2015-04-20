class Group < ActiveRecord::Base
  has_neo_node
  
  def <<(object)
    neo_node.children << object.neo_node
  end
  
  def members
    User.find neo_node.member_ids
  end
  
  
  def title
    self.name
  end
  
end