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

require 'test_helper'

class DocumentTest < ActiveSupport::TestCase
  Document.send(:public, *Document.protected_instance_methods)
  context 'a document instance' do
    setup do
      @d = Document.create
    end
    should 'be true' do
      assert @d
    end
  end
end

