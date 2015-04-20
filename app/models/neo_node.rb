class NeoNode
  include Neo4j::ActiveNode
  
  property :active_record_type, index: :exact
  property :active_record_id, type: Integer, index: :exact
  property :title
  
  # Example:
  #   neo_node.sync_from(user)
  #
  def sync_from(active_record_object)
    self.active_record_type = active_record_object.class.name
    self.active_record_id = active_record_object.id || raise('active_record_object must have an id')
    self.title = active_record_object.title if active_record_object.respond_to?(:title)
    self.save
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