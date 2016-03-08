 #   :url => ":s3_domain_url",
 #   :path => "/:class/avatars/:id_:basename.:style.:extension"

#Paperclip::Attachment.default_options[:url] = ':s3_domain_url'
#Paperclip::Attachment.default_options[:path] = '/images/:style/:id_:basename.:extension'
#Paperclip::Attachment.default_options[:styles] = {}
#Paperclip::Attachment.default_options[:default_url] = ''
#Paperclip::Attachment.default_options[:default_style] = :original
#Paperclip::Attachment.default_options[:validations] = {}
#Paperclip::Attachment.default_options[:storage] = '/images/:style/:id_:basename.:extension'
#Paperclip::Attachment.default_options[:path] = '/images/:style/:id_:basename.:extension'
#Paperclip::Attachment.default_options[:path] = '/images/:style/:id_:basename.:extension'

#module Paperclip
  # The Attachment class manages the files for a given attachment. It saves
  # when the model saves, deletes when the model is destroyed, and processes
  # the file upon assignment.
#  class Attachment
#    
#    def self.default_options
#      @default_options ||= {
#        :url => "/system/:class/:attachment/:id/:style/:basename.:extension",
#        :path => ":rails_root/public/system/:class/:attachment/:id/:style/:basename.:extension",
#        :styles => {},
#        :default_url => "",
#        :default_style => :original,
#        :validations => {},
#        :storage => :filesystem, # if you wish to use S3 everywhere, change this to :storage => :s3
#        :s3_credentials => "#{RAILS_ROOT}/config/s3.yml"
#      }
#    end
#  end
#end