require 'test_helper'

class PiecesHelperTest < ActionView::TestCase
  context 'a piece instance' do
    setup do
      @pref_set = {
        "type1" => {
          "title" => 'on',
          'desc' => ''},
        'type2' => {
          'title' => 'on',
          'desc' => 'on'
        }
      }
    end
    should 'return non selected field view pref' do
      name = "perm[type1-desc]"
      assert_equal("<span style='background:#f66;'><input name='#{name}'type='checkbox'></span>", get_field_view_pref('type1', 'desc',@pref_set))
    end
    should 'return selected field view pref' do
      name = "perm[type1-title]"
      assert_equal("<span style='background:#9f9;'><input name='#{name}'type='checkbox'checked='checked'></span>", get_field_view_pref('type1', 'title',@pref_set))
    end
  end
end