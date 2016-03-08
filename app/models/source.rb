# == Schema Information
#
# Table name: sources
#
#  id         :integer          not null, primary key
#  table_name :string(255)
#  is_valid   :boolean          default(TRUE)
#

class Source < ActiveRecord::Base
	has_one :like, :foreign_key => "source"
	attr_accessible :table_name

	validates_presence_of :table_name, :on => :create
	validates_uniqueness_of :table_name
	
	def self.id_from_name(name)
	  if name == "announcement"
	    return 4
    else
	    r = Source.find_by_table_name(name)
  	  return r.id      
    end
  end
  
  def self.name_from_id(id)
	  r = Source.find(id)
	  return r.table_name
  end
end
