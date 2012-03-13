require 'test_helper'

class ApplicationHelperTest < ActionView::TestCase
  context 'capture helper' do
    context 'my_tags' do
      should 'return correctly same text if no text' do
        assert_equal my_tags(nil), ''
      end
      should 'return same text if no tags in there' do
        sample_text = 'Hello this is a text'
        assert_equal my_tags(sample_text), sample_text
      end
      should 'replace new lines with break tags' do
        sample_text = "Hi\nThere\n"
        assert_equal my_tags(sample_text), 'Hi<br />There<br />'
      end
      should 'replace @- with inline class' do
        sample_text = "Hi @-there-@ Sally!"
        assert_equal my_tags(sample_text), 'Hi <div class = "inline">there</div> Sally!'
      end
      should 'replace * with strong' do
        sample_text = "Hi *there* Sally!"
        assert_equal my_tags(sample_text), 'Hi <strong>there</strong> Sally!'
      end
      should 'replace ~ with <b> tag' do
        sample_text = "Hi ~there~ Sally!"
        assert_equal my_tags(sample_text), 'Hi <b>there</b> Sally!'
      end
      should 'replace ~* with <i> tag' do
        sample_text = "Hi ~*there*~ Sally!"
        assert_equal my_tags(sample_text), 'Hi <i>there</i> Sally!'
      end
      should 'do all tags in one text' do
        sample_text = "Hi ~*there*~ Sally! and ~fred my friend~ ~ole "
        assert_equal my_tags(sample_text), 'Hi <i>there</i> Sally! and <b>fred my friend</b> ~ole '
      end
    end
    should 'return cancel path correctly' do
      @create = nil
      assert_equal cancel_path, 'cancel_modify'
      @create = true
      assert_equal cancel_path, 'cancel_new_ev'
    end

  end
end