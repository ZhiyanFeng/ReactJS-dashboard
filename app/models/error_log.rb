class ErrorLog < ActiveRecord::Base
  attr_accessible :file, :function, :error
  
  validates_presence_of :file, :on => :create
  validates_presence_of :function, :on => :create
  validates_presence_of :error, :on => :create
end
