class HtmlColor < String
  
  
  
  def self.color_convert(number)
    number = number.to_s
    if number.length == 3
      newnumber = ''
      2.times {newnumber << number[0]}
      2.times {newnumber << number[1]}
      2.times {newnumber << number[2]}
      number = newnumber
    end
    red = number.slice!(0..1).hex
    green = number.slice!(0..1).hex
    blue = number.slice!(0..1).hex
    answer = 'rgb('+red.to_s+','+green.to_s+','+blue.to_s+')'
    answer = [red,green,blue]
  end
  def self.saturate(color)
    strongest = color.sort[2]
    weakest = color.sort[0]
    color.each_index do |key|
      if color[key] == strongest
        color[key] = color[key] * 2
        if color[key] > 256
          color[key] = 256
        end
      end
      if color[key] == weakest
        color[key] = color[key] / 2
        color[key] = color[key].to_i
      end
    end
    color
  end
  def self.darken(number)
    factor = 0.4
    color = HtmlColor.color_convert(number)
    newcolor = [(color[0].to_f*factor).to_i,(color[1].to_f*factor).to_i,(color[2].to_f*factor).to_i]
    answer = HtmlColor.rgbize(HtmlColor.saturate(newcolor))
  end

  def self.rgbize(color)
    red = color[0]
    green = color[1]
    blue = color[2]
    answer = 'rgb('+red.to_s+','+green.to_s+','+blue.to_s+')'
  end
  
  
  
  
  
  
  
  
  def color_convert_to_array #tested
    number = self.to_s.sub('#','')
    if number.length == 3
      newnumber = ''
      2.times {newnumber << number[0]}
      2.times {newnumber << number[1]}
      2.times {newnumber << number[2]}
      number = newnumber
    end
    red = number.slice!(0..1).hex
    green = number.slice!(0..1).hex
    blue = number.slice!(0..1).hex
    answer = [red,green,blue]
  end
  
  def is_rgb? #tested
    self =~ /rgb\(([0-9]{1,3}?),([0-9]{1,3}?),([0-9]{1,3}?)\)/
  end
  def convert_rgb_to_array #tested
  /rgb\(([0-9]{1,3}?),([0-9]{1,3}?),([0-9]{1,3}?)\)/.match(self)
  array = [$1.to_i,$2.to_i,$3.to_i]
  end
  def self.standardize(color) #tested
    if color.is_rgb?
      @@original_form = 0
      color.convert_rgb_to_array
    else
      @@original_form = color.length
      color.color_convert_to_array
    end
  end
  
  def self.back_to_original(array)#tested
    if @@original_form == 0
      new(rgbize(array))
    else
      new(six_ize(array))
    end
  end

  def self.six_ize(array)#tested
    prefix = @@original_form == 7 ? '#' : ''
    a = array[0].to_s(16)
    a = '0'+ a if a.length == 1
    b = array[1].to_s(16)
    b = '0'+ b if b.length == 1
    c = array[2].to_s(16)
    c = '0'+ c if c.length == 1
    prefix << a+b+c
  end
  
  def saturate
    converted = HtmlColor.standardize(self)
    sorted = converted.sort
    strongest = sorted[2]
    medium = sorted[1]
    weakest = sorted[0]
    converted.each_index do |key|
      if converted[key] == strongest
        converted[key] = converted[key] * 2
        if converted[key] > 255
          converted[key] = 255
        end
      end
      if converted[key] == weakest
        converted[key] = converted[key] / 2
        converted[key] = converted[key].to_i
      end
    end
    HtmlColor.back_to_original(converted)
  end

  def darken(factor = 0.5)
    color = HtmlColor.standardize(self)
    newcolor = [(color[0].to_f*factor).to_i,(color[1].to_f*factor).to_i,(color[2].to_f*factor).to_i]
    new_color = HtmlColor.back_to_original(newcolor)
  end


  def self.rgbize(array)#tested
    red = array[0]
    green = array[1]
    blue = array[2]
    answer = 'rgb('+red.to_s+','+green.to_s+','+blue.to_s+')'
  end
end
