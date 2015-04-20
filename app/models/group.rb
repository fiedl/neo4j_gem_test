class Group < ActiveRecord::Base
  
  after_save :sync_to_neo_node
  
  def neo_node
    @neo_node ||= (NeoNode.where(active_record_type: self.class.name, active_record_id: self.id).first || NeoNode.create)
  end
  def sync_to_neo_node
    neo_node.sync_from(self)
  end
  
  
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