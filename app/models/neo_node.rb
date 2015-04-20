class NeoNode
  include Neo4j::ActiveNode
  
  property :active_record_type, index: :exact
  property :active_record_id, type: Integer, index: :exact
  property :title
  
  has_many :out, :children, model_class: NeoNode
  has_many :in, :parents, model_class: NeoNode
  
  
  def member_ids
    # TODO: Check for a better syntax here: http://stackoverflow.com/questions/29755869
    self.query_as(:self).match("path = (member:User)<-[*]-self")
      .where("all(node in tail(nodes(path)) where ('Group' in labels(node)))")
      .pluck('member.active_record_id')
  end
  
  
  
  
  # Example:
  #   neo_node.sync_from(user)
  #
  def sync_from(active_record_object)
    self.active_record_type = active_record_object.class.name
    self.active_record_id = active_record_object.id || raise('active_record_object must have an id')
    self.title = active_record_object.title if active_record_object.respond_to?(:title)
    self.add_label self.active_record_type
    self.save
  end
  

  # Returns the corresponding ActiveRecord object.
  #
  def to_active_record
    active_record_object
  end
  def active_record_object
    active_record_class.find self.active_record_id
  end
  def allowed_active_record_types
    %w(Group User Page Event)
  end
  def secure_active_record_type
    (allowed_active_record_types & [self.active_record_type]).first
  end
  def active_record_class
    secure_active_record_type.constantize
  end
end