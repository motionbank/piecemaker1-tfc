require 'test_helper'

class HtmlColorsTest < ActiveSupport::TestCase

  context "a Color instance" do
      setup do
        @new_color = HtmlColor.new('fff')
      end
      should 'get the right color' do
        assert @new_color == 'fff'
      end
      should 'report  non rgb as nil' do
        assert !@new_color.is_rgb?
      end
      should 'report rgb correctly' do 
        @rgb_color = HtmlColor.new('rgb(100,10,1)')
        assert @rgb_color.is_rgb?
      end
      should 'convert to rgb correctly' do 
        x = [1,10,255]
        assert HtmlColor.rgbize(x) == 'rgb(1,10,255)'
      end
      should 'sixize properly if # is present' do
        x = HtmlColor.new('#ffffff')
        s = HtmlColor.standardize(x)
        assert HtmlColor.six_ize([255,255,255]) == '#ffffff'
      end
      should 'sixize properly if # absent' do
        x = HtmlColor.new('ffffff')
        s = HtmlColor.standardize(x)
        assert HtmlColor.six_ize([255,255,255]) == 'ffffff'
      end
      should ' convert rgb to array correctly' do 
        @rgb_color = HtmlColor.new('rgb(100,10,1)')
        assert @rgb_color.convert_rgb_to_array == [100,10,1]
      end
      should 'convert 3 place hex to array correctly' do
        assert @new_color.color_convert_to_array == [255,255,255]
      end
      should 'convert 4 place hex to array correctly' do
        @new_color = HtmlColor.new('#fff')
        assert @new_color.color_convert_to_array == [255,255,255]
      end
      should 'convert 6 place hex to array correctly' do
        @new_color = HtmlColor.new('ffffff')
        assert @new_color.color_convert_to_array == [255,255,255]
      end
      should 'convert 7 place hex to array correctly' do
        @new_color = HtmlColor.new('#ffffff')
        assert @new_color.color_convert_to_array == [255,255,255]
      end
      should 'standardize and back to original 3 place properly' do
        @new_color = HtmlColor.new('1da')
        assert  HtmlColor.back_to_original(HtmlColor.standardize(@new_color)) == '11ddaa'
      end
      should 'standardize and back to original 6 place properly' do
        @new_color = HtmlColor.new('11dfac')
        assert  HtmlColor.back_to_original(HtmlColor.standardize(@new_color)) == '11dfac'
      end
      should 'standardize and back to original rgb properly' do
        @new_color = HtmlColor.new('rgb(100,2,255)')
        assert  HtmlColor.back_to_original(HtmlColor.standardize(@new_color)) == @new_color
      end
      
  end

end
