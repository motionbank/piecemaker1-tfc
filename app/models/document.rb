# == Schema Information
#
# Table name: documents
#
#  id               :integer(4)      not null, primary key
#  doc_file_name    :string(255)
#  doc_content_type :string(255)
#  doc_file_size    :integer(4)
#  piece_id         :integer(4)
#  created_at       :datetime
#  updated_at       :datetime
#

class Document < ActiveRecord::Base

  belongs_to :piece
  acts_as_tenant(:account)
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
