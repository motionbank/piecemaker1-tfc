require 'test_helper'

class PieceTest < ActiveSupport::TestCase
  Piece.send(:public, *Piece.protected_instance_methods)
  context 'a piece with scenes and subscenes' do
    setup do
      @t = Time.now
      @p1 = Factory.create(:piece, :title => 'sam1')
      @p2 = Factory.create(:piece, :title => 'sam2')
      @e1 = Factory.create(:event, :piece_id => @p1.id, :event_type => 'scene',:happened_at => @t + 1)
      @e2 = Factory.create(:event, :piece_id => @p1.id, :event_type => 'scene',:happened_at => @t + 2)
      @e3 = Factory.create(:event, :piece_id => @p1.id, :event_type => 'sub_scene',:happened_at => @t + 3)
      @e4 = Factory.create(:event, :piece_id => @p2.id, :event_type => 'scene',:happened_at => @t + 1) #not same piece
      @e5 = Factory.create(:event, :piece_id => @p1.id, :event_type => 'scene',:happened_at => @t + 4) #
    end
    should 'find active events' do
      assert_equal @p1.active_events.length, 4
    end
    should 'not show inactive' do
      @e2.state = 'deleted'
      @e1.save
      @e2.save
      assert_equal @p1.active_events.length, 3
    end
    should 'get latest scene' do
      assert_equal @p1.latest_scene().id, @e5.id
    end
    should 'get latest scene rejecting greater positions' do
      assert_equal @p1.latest_scene(@t+2).id, @e2.id
    end

  end
  
  context 'a piece with tags' do
    setup do
      @p1 = Factory.create(:piece, :title => 'sam1')
      @t1 = Factory.create(:tag, :name => 'tag1')
      @t2 = Factory.create(:tag, :name => 'tag2')
      @p1.tags << @t1
      @p1.tags << @t2
    end
    should 'give back correct tag count' do
      assert_equal @p1.tags.length, 2
    end
    should 'give tag list' do
      assert_equal @p1.owned_tags.sort, ['tag1','tag2']
    end
  end
  

  context 'piece video list, dates and locations' do
    setup do
      @t = Time.now
      @p1 = Factory.create(:piece)
      @e4 = Factory.create(:event, :event_type => 'scene',:happened_at => (@t + 60*60*24))
      @e5 = Factory.create(:event, :event_type => 'headline',:happened_at => (@t+ 400 + 60*60*24),:location => 'panama')
      @e6 = Factory.create(:event, :event_type => 'headline',:happened_at => (@t+ 470 + 60*60*24),:location => 'san francisco')
      @p1.events << @e4
      @p1.events << @e5
      @p1.events << @e6
      @u1 = Factory.create(:performer,:login => 'sam')
      @u2 = Factory.create(:performer,:login => 'roger')
      @p1.performers << @u1
    end
    
    should 'get date list' do
      assert_equal @p1.date_list.map{|x| x.to_i}, [(@t + 60*60*24).at_midnight.to_i]
    end
    should 'get location list' do
      locations = @p1.location_list.map{|x| x[:location]}
      assert_equal locations, ['panama','san francisco']
      dates = @p1.location_list.map{|x| x[:date].to_i}
      assert_equal dates, [(@t+ 400 + 60*60*24).to_i,(@t+ 470 + 60*60*24).to_i]
    end
    should 'get user list' do
      assert_equal @p1.performers, [@u1]
    end
    should 'add a user' do
      @p1.add_performer(@u2)
      assert_equal @p1.performers, [@u1,@u2]
    end
    should 'add remove user' do
      @p1.add_performer(@u2)
      @p1.remove_performer(@u1)
      assert_equal @p1.performers, [@u2]
    end
  end
end


# == Schema Information
#
# Table name: pieces
#
#  id           :integer(4)      not null, primary key
#  created_at   :datetime
#  title        :string(255)
#  updated_at   :datetime
#  modified_by  :string(255)
#  short_name   :string(255)
#  is_active    :boolean(1)      default(TRUE)
#

