# This is the same test as:
# https://github.com/fiedl/neo4j_ancestry_vs_acts_as_dag/blob/master/spec/performance_spec.rb
#
require 'rails_helper'

ENV['BACKEND'] ||= "neo4j gem, HasNeoNode module"

describe "performance: " do
  
  $number_of_groups = 100
  $number_of_users = 10
  
  before :each do
    clear_db
  end
  
  let(:groups) { (1..$number_of_groups).map { |n| Group.create(name: "Group #{n}") } }
  let(:parent_group) { Group.create name: "Parent Group" }
  let(:ancestor_group) { Group.create name: "Ancestor Group" }
  
  specify "creating #{$number_of_groups} groups" do
    benchmark do
      groups
    end
    groups.count.should == $number_of_groups
  end
  
  specify "adding #{$number_of_users} users to each of the #{$number_of_groups} groups" do
    benchmark do
      groups.each do |group|
        (1..$number_of_users).each { |n| group.neo_node.children << User.create.neo_node }
      end
    end
    groups.last.neo_node.children.count.should == $number_of_users
  end
  
  describe "with child users" do
  
    before do
      # create $number_of_users users per group
      groups.each do |group|
        (1..$number_of_users).each { |n| group.neo_node.children << User.create.neo_node }
      end
    end
    
    specify "moving #{$number_of_groups} groups into a parent group" do
      benchmark do
        groups.each do |group|
          parent_group.neo_node.children << group.neo_node
        end
      end
      parent_group.neo_node.children.count.should == $number_of_groups
    end
    
    describe "with parent group" do
      before do
        groups.each do |group|
          parent_group.neo_node.children << group.neo_node
        end
      end
      
      specify "moving the group structure into an ancestor group" do
        benchmark do
          ancestor_group.neo_node.children << parent_group.neo_node
        end
        ancestor_group.neo_node.query_as(:self).match("self-[*]->(g:Group)").pluck(:g).count.should > $number_of_groups
      end
      
      describe "with ancestor group" do
        before { ancestor_group.neo_node.children << parent_group.neo_node }
      
        specify "removing the link to the ancestor group" do
          benchmark do
            ancestor_group.neo_node.children.destroy(parent_group.neo_node)
          end
          ancestor_group.neo_node.query_as(:self).match("self-[*]->(n)").pluck(:n).count.should == 0
        end
        
        specify "destroying the ancestor group" do
          benchmark do
            ancestor_group.destroy
          end
          parent_group.neo_node.query_as(:self).match("self<-[*]-(n)").pluck(:n).count.should == 0
        end
        
        specify "finding all descendants" do
          benchmark do
            ancestor_group.neo_node.query_as(:self).match("self-[*]->(n)").pluck(:n).collect { |n| n.to_active_record }
          end
          ancestor_group.neo_node.query_as(:self).match("self-[*]->(n)").pluck(:n).count.should > $number_of_groups
        end
        
        specify "finding all descendant users" do
          benchmark do
            User.find(ancestor_group.neo_node.query_as(:self).match("self-[*]->(u:User)").pluck('u.active_record_id'))
          end
          User.find(ancestor_group.neo_node.query_as(:self).match("self-[*]->(u:User)").pluck('u.active_record_id')).count.should > $number_of_groups
          User.find(ancestor_group.neo_node.query_as(:self).match("self-[*]->(u:User)").pluck('u.active_record_id')).first.should be_kind_of User
        end
      end
    end
  end
   
  after(:all) do
    print_results
  end
  
  $results = []
  def benchmark
    duration_in_seconds = Benchmark.realtime do
      yield
    end
    
    description = RSpec.current_example.metadata[:description]
    duration = "#{duration_in_seconds} seconds"
    
    $results << [description, "#{duration_in_seconds.to_s} s"]
    print "#{description}: #{duration}.\n".blue
  end
  
  def print_results
    print "\n\n## Results for #{ENV['BACKEND']}\n\n".blue.bold
    
    print "$number_of_groups = #{$number_of_groups}\n".blue
    print "$number_of_users  = #{$number_of_users}\n\n".blue
    
    print results_table.blue.bold
  end
  def results_table
    t = TableFormatter.new
    t.source = $results
    t.labels = ['Description', 'Duration']
    t.display.to_s
  end
  
  def clear_db
    # clear_model_memory_caches
    Neo4j::Session.current._query('MATCH (n) OPTIONAL MATCH (n)-[r]-() DELETE n,r')
  end
  
end