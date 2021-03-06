# == Schema Information
#
# Table name: documents
#
#  id               :integer          not null, primary key
#  doc_file_name    :string(255)
#  doc_content_type :string(255)
#  doc_file_size    :integer
#  piece_id         :integer
#  created_at       :datetime
#  updated_at       :datetime
#  account_id       :integer
#

class Document < ActiveRecord::Base
  
  require 's3_paths'
  include S3Paths
  
  belongs_to :piece
  def update_from_params(params)
    self.doc_file_name = params[:doc_title]
    self.doc_file_size = params[:size]
    self.doc_content_type = params[:contenttype]
  end
  def new_name
    false
  end
  def destroy_all
    if self.delete_s3
      self.destroy
      true
    else
      false
    end
  end
end

    
    #:path => ":rails_root/public/uploads/:attachment/:id/:style/:basename.:extension", :url => "/uploads/:attachment/:id/:style/:basename.:extension"
