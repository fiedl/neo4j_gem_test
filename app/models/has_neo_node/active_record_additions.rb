module HasNeoNode
  module ActiveRecordAdditions
    
    # Use this method in order to connect an ActiveRecord model to a node representation
    # in the neo4j database.
    #
    #     Group < ActiveRecord::Base
    #       has_neo_node
    #     end
    #
    # Then, you have access to the methods defined in `HasNeoNode::InstanceMethods`,
    # for example:
    # 
    #     group.neo_node
    #     group.sync_to_neo_node  # which will be triggered after save.
    #
    # Through `neo_node`, you have access to the graph traversing methods.
    # 
    #     group.neo_node.children.first.to_active_record
    #     User.find group.neo_node.member_ids
    #     group.neo_node.member_ids
    # 
    #     # The latter is the same as:
    #     group.neo_node.query_as(:self).match("path = (member:User)<-[*]-self")
    #      .where("all(node in tail(nodes(path)) where ('Group' in labels(node)))")
    #      .pluck('member.active_record_id')
    #
    # These are documented in `HasNeoNode::NeoNode`.
    #
    def has_neo_node
      after_save :sync_to_neo_node
      
      include HasNeoNode::InstanceMethods
    end
  end
  module InstanceMethods
    def neo_node
      @neo_node ||= (find_neo_node || NeoNode.create)
    end
    def find_neo_node
      NeoNode.where(active_record_type: self.class.name, active_record_id: self.id).first
    end
    def sync_to_neo_node
      neo_node.sync_from(self)
    end
  end
end

ActiveRecord::Base.extend HasNeoNode::ActiveRecordAdditions