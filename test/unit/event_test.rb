require 'test_helper'

class EventTest < ActiveSupport::TestCase
  Event.send(:public, *Event.protected_instance_methods)

  context 'simple methods' do
    setup do
      @event = Event.create
    end
    should 'make normal' do
      @event.make_normal
      assert @event.state == 'normal'
    end
    should 'report hidden or not' do
      assert !@event.is_hidden?
      @event.hide
      assert @event.is_hidden?
      @event.unhide
      assert !@event.is_hidden?
    end

    should 'report needs_performers_field? if true or not' do
      @event.event_type = 'scene'
      assert @event.needs_performers_field? == true
      @event.event_type = 'light_cue'
      assert @event.needs_performers_field? == false
    end
    should 'report highlightable? if true or not' do
      @event.event_type = 'scene'
      assert @event.highlightable? == true
      @event.event_type = 'dvd_in'
      assert@event.highlightable? == false
    end
    should 'toggle highlight correctly to true' do
      @event.highlighted = false
      assert !@event.highlighted
      @event.toggle_highlight!
      assert @event.highlighted
      @event.toggle_highlight!
      assert !@event.highlighted
    end
    should 'delete and undelete correctly' do
      assert !@event.is_deleted?
      @event.delet
      assert @event.is_deleted?
      @event.undelet
      assert !@event.is_deleted?
    end
    should 'pad numbers' do
      assert_equal Event.pad_number(2),'002'
      assert_equal Event.pad_number(32),'032'
      assert_equal Event.pad_number(222),'222'
    end
    
    should 'say a draft is a draft or not' do
      assert !@event.is_draft?
      @event.make_draft(100)
      assert @event.is_draft?
    end

    should 'return original id' do
      @event.make_draft(101)
      assert_equal @event.draft_original, 101
    end
    should 'return nil original if not a draft' do
      assert_nil @event.draft_original
    end
    should 'create draft' do
      @ev2 = @event.create_draft
      assert_equal @ev2.draft_original, @event.id
    end
    should 'get original return self if not draft' do
      assert_equal @event.id,@event.get_original.id
    end
    should 'get original return original if draft' do
      @ev2 = @event.create_draft
      assert_equal @event.id, @ev2.get_original.id
    end
    should 'get time difference' do
      tim = Time.now
      @event.happened_at = tim
      @event.save
      assert_equal @event.happened_at.to_i, tim.to_i
      @event2 = Event.create
      @event2.happened_at = tim + 700
      @event2.save
      assert_equal @event.time_difference(@event2), -700
    end
    
  end #simple methods
  
  context 'location functionality' do
    setup do

    end

  end
  
  context 'casting methods' do
    setup do
      @piece = Piece.create
      @event = Event.create
      @piece.events << @event
      
      @performer1 = Performer.create(:short_name => 'Alan')
      @performer2 = Performer.create(:short_name => 'Bob')
      @performer3 = Performer.create(:short_name => 'Chris',:first_name => '')
      @performer4 = Performer.create(:short_name => 'Dan',:first_name => 'Daniel')
      @performer5 = Performer.create(:short_name => 'Ed')
      @performer6 = Performer.create(:short_name => 'Fred')

      @piece.performers << @performer1
      @piece.performers << @performer2
      @piece.performers << @performer3
      @piece.performers << @performer4
      @event.event_type = 'scene'
    end
    context 'parsing from description' do

      should 'parse performer from description' do
        @event.description = 'alan gives an apple to bob and david'
        @event.performers = []
        @event.get_performers_from_description
        assert_equal @event.performers, ['Alan','Bob']
      end
      should 'parse performer from description ignoring case' do
        @event.description = 'Alan gives an apple to BOB and david'
        @event.performers = []
        @event.get_performers_from_description
        assert_equal @event.performers, ['Alan','Bob']
      end
      should 'parse performer from description no duplicates' do
        @event.description = 'Alan gives an apple to BOB and alan.'
        @event.performers = ['Alan']
        @event.get_performers_from_description
        assert_equal @event.performers, ['Alan','Bob']
      end
      should 'parse performer from description ignoring embedded matches' do
        @event.description = 'Alan gives an apple to victor and bobbing'
        @event.performers = []
        @event.get_performers_from_description
        assert_equal @event.performers, ['Alan']
      end
      should 'parse performer from description ignoring embedded matches2' do
        @event.description = 'Alan gives an apple to victor and bobbing bob chris'
        @event.performers = []
        @event.get_performers_from_description
        assert_equal @event.performers, ['Alan','Bob','Chris']
      end
      should 'parse performer from description or title' do
        @event.description = 'Alan bobbing'
        @event.title = 'Christoph dan Alan'
        @event.performers = []
        @event.get_performers_from_description
        assert_equal @event.performers, ['Alan','Dan']
      end
      should 'parse performer from description or title including previous' do
        @event.description = 'Alan'
        @event.title = 'Christoph dan Alan'
        @event.performers = ['Bob']
        @event.get_performers_from_description
        assert_equal @event.performers, ['Alan','Bob','Dan']
      end
    end
    should 'report has_everyone? false if cast is not full' do
      @event.performers = ['Alan','Bob']
      assert !@event.has_everyone?
    end
    should 'report has_everyone? false if cast is too small' do
      @event.performers = ['Alan','Bob','Chris','Dan']        
      assert !@event.has_everyone?
    end
    should 'report has_everyone? true if cast is full and big' do
      @piece.performers << @performer5
      @piece.performers << @performer6
      @event.performers = ['Alan','Bob','Chris','Dan','Ed','Fred']        
      assert @event.has_everyone?
    end
    
    should 'report has_everyone? true if cast is "Everyone"' do
      @event.performers = ['Everyone']
      assert @event.has_everyone?
    end
    should 'change cast to Everyone if cast full' do
      @piece.performers << @performer5
      @piece.performers << @performer6
      @event.performers = ['Alan','Bob','Chris','Dan','Ed','Fred']
      @event.check_for_everyone
      assert @event.performers == ['Everyone']
    end
    should 'change cast to Everyone if cast is Everyone' do
      @event.performers = ['Everyone']
      @event.check_for_everyone
      assert @event.performers == ['Everyone']
    end
    should 'not change cast to Everyone if cast is not full' do
      @event.performers = ['Alan','Bob','Chris']
      @event.check_for_everyone
      assert(@event.performers != ['Everyone'], "hi #{@event.performers.join(', ')}")
    end
  end

  context 'with tags' do
    setup do
      @p = Factory.create(:piece)
      @ev = Factory.create(:event,:title => 'event1')
      @t1 = Factory.create(:tag,:name => 'Tag1')
      @t2 = Factory.create(:tag,:name => 'Tag2')
      @t3 = Factory.create(:tag,:name => 'Tag3')
      @p.events << @ev
      @p.tags << @t1
      @p.tags << @t2
      @ev.tags << @t1
      @ev.tags << @t2
    end
    should 'list tag names' do
      assert_equal @ev.tag_names, ['tag1','tag2']
    end
    should 'make tag list' do
      assert_equal @ev.tag_list , 'Tag1,Tag2'
    end
    should 'tag with title' do
      @ev.tag_with_title
      assert_equal @ev.tag_names, ['tag1','tag2','event1']
      assert @ev.tagged_with_title?
    end
    should 'return correct tagged with' do
      assert @ev.tagged_with?('tag2')
    end
    should 'return false if not tagged with' do
      assert !@ev.tagged_with?('tag3')
    end
    should 'parse tagstring' do
      assert_equal Event.parse_tagstring(''),[]
    end
    should 'parse tagstring again' do
      assert_equal Event.parse_tagstring('why,fly ,so high'),['why','fly','so high']
    end
    should 'add tag' do
      @ev.add_tag(@t3)
      assert @ev.tags.include?(@t3)
    end
    should 'not add tag if already tagged' do
      assert_equal @ev.tags.length, 2
      @ev.add_tag(@t2)
      assert_equal @ev.tags.length, 2
    end
    should 'create tag if needed' do
      @t4 = @ev.get_tag_or_create('tag4')
      assert_equal Tag.find(:all).length,4
    end
    should ' not create tag if not needed' do
      assert_equal Tag.find(:all).length,3
      @t4 = @ev.get_tag_or_create('Tag1')
      assert_equal Tag.find(:all).length,3
    end
    should 'do tag process adding a tag' do
      @ev.do_tag_process(['Tag1','Tag2','heaven'])
      assert @ev.tag_names.include?('heaven')
    end
    should 'do tag process removing a tag' do
      @ev.do_tag_process(['Tag1','heaven'])
      assert !@ev.tag_names.include?('Tag2')
      assert @ev.tag_names.include?('heaven')
    end
    should 'process tags' do
      @ev.process_tags('Tag2,heaven')
      assert !@ev.tag_names.include?('Tag1')
      assert @ev.tag_names.include?('heaven')
      assert @ev.tag_names.include?('tag2')
    end
    should 'report performer picked false when not picked' do
      assert !@ev.performer_picked?
    end
    should 'report performer picked when picked add liker' do
      @ev.add_liker('Sam')
      assert @ev.performer_picked?
    end
    
  end

  context 'dvd actions' do
    should 'pad_number(num)'do
      assert_equal Event.pad_number(1), '001'
      assert_equal Event.pad_number(21), '021'
      assert_equal Event.pad_number(189), '189'       
    end
  end

  context 'new repositioning' do
    setup do
      @t = Time.now
      @ev1 = Factory.create(:event,:title => 'scene1',:video_id => 0,:happened_at => @t)
      
      @ev2 = Factory.create(:event,:title => 'scene1',:video_id => 0,:happened_at => @t + 1)
    end
    should 'insert at' do
      @ev1.insert_at_time(@t+1)
      assert_equal(@t+1,@ev1.happened_at)
    end
    should 'nudge other if time is the same' do
      #@ev1.insert_at_time(@ca1)
      #@ev1.reload
      #@ev2.reload
      #assert_equal(@ca1,@ev1.created_at)
      #assert_equal(@ca1+1,@ev2.created_at)
    end
  end

  context 'repositioning' do
    setup do

    end
     should 'return nil if event has no video parent' do
     end
     should 'return nil if event is a video_in' do
     end
     should 'orphanize event if media time is too great' do
     end
     should 'insert and sort events if time is ok' do
     end
  end
  
  
  context 'video parent' do
    setup do
      
      @piece = Piece.create
      @event = Event.create
      @piece.events << @event
      
      @video = Video.new
      @video.save
      
      @vid_parent = Event.new
      @vid_parent.id = 6
      @vid_parent.title = '19'
      @vid_parent.save
      
      @vid_parent.save
      @vid_sibling1 = Event.new
      @vid_sibling2 = Event.new
      @vid_sibling3 = Event.new
      @vid_sibling1.piece_id = @event.piece_id
      @vid_sibling2.piece_id = @event.piece_id
      @vid_sibling3.piece_id = @event.piece_id
      @vid_sibling1.title = 'sibling 1'
      @vid_sibling2.title = 'sibling 2'
      @vid_sibling3.title = 'sibling 3'
      @vid_sibling1.save
      @vid_sibling2.save
      @vid_sibling3.save
      @non_sibling1 = Event.new
      @non_sibling2 = Event.new
      @non_sibling1.piece_id = @event.piece_id + 1 
      @non_sibling2.piece_id = @event.piece_id
      @non_sibling1.title = 'non_sibling1'
      @non_sibling2.title = 'non_sibling2'
      @non_sibling1.save
      @non_sibling2.save
    end
      should 'report if video not uploaded or missing' do
        assert !@vid_parent.video_uploaded?
        @vid_parent.video_id = @video.id
        @vid_parent.save
        assert !@vid_parent.video_uploaded?

      end
      should 'report if uploaded' do
        @video.fn_s3 = '.mp4'
        @video.save
        @vid_parent.video_id = @video.id
        @vid_parent.save
        assert @vid_parent.video_uploaded?
      end


      should 'report correctly no dvd' do
        assert @event.fixed_media_number == SetupConfiguration.no_video_string
      end

  end
  
  context 'event performer searches' do
    setup do
      @t = Time.now
      #hi
      @p = Factory.create(:piece)
      ['alalal','bobobo','carlcarl','dadada','ededed'].each do |n|
        @p.performers << Factory.create(:performer,:short_name => n)
      end
      @ev1 = Factory.create(:event,:title => 'scene1',:event_type => 'scene',:happened_at => @t + 1)
      @p.events << @ev1
      @ev1.performers = ['alalal','bobobo','carlcarl','dadada','ededed']
      @ev1.save
      
      @ev2 = Factory.create(:event,:title => 'scene2',:event_type => 'scene',:happened_at => @t + 2)
      @p.events << @ev2
      @ev2.performers = ['alalal']
      @ev2.save
      
      @ev3 = Factory.create(:event,:title => 'scene3',:event_type => 'scene',:happened_at => @t + 3)
      @p.events << @ev3
      @ev3.performers = ['alalal','carlcarl']
      @ev3.save
      
      @ev4 = Factory.create(:event,:title => 'scene4',:event_type => 'scene',:happened_at => @t + 4)
      @p.events << @ev4
      @ev4.performers = ['Everyone']
      @ev4.save

      @events = [@ev1,@ev2,@ev3,@ev4]
    end
    should 'find everyone' do
      assert_equal @events.select{|x| x.performer_everyone?},[@ev1,@ev4]
    end
    should 'find performers exclusive' do
      assert_equal @events.select{|x| x.performer_exclusive?(['alalal'])},[@ev2]
      assert_equal @events.select{|x| x.performer_exclusive?(['alalal','carlcarl'])},[@ev3]
    end
    should 'find performers non_exclusive' do
      assert_equal @events.select{|x| x.performer_non_exclusive?(['alalal'])}.sort_by{|x| x.title},[@ev2,@ev3]
    end
    should 'find performers non_exclusive with everyone' do
      assert_equal @events.select{|x| x.performer_non_exclusive_with_everyone?(['alalal','carlcarl'])}.sort_by{|x| x.title},[@ev1,@ev3,@ev4]
    end
    should 'find performers semi_exclusive' do
      assert_equal @events.select{|x| x.performer_semi_exclusive?(['alalal','carlcarl'])}.sort_by{|x| x.title},[@ev2,@ev3]
    end
  end

  context 'scenes and their subscenes' do
    setup do

    end
    
  end
end


# == Schema Information
#
# Table name: events
#
#  id              :integer(4)      not null, primary key
#  created_at      :datetime
#  created_by      :string(255)
#  title           :string(255)
#  description     :text
#  event_type      :string(255)
#  modified_by     :string(255)
#  updated_at      :datetime
#  locked          :string(255)     default("none"), not null
#  performers      :text
#  media_time      :integer(4)
#  piece_id        :integer(4)
#  video_id        :integer(4)      default(0)
#  video_parent_id :integer(4)
#  highlighted     :boolean(1)      default(FALSE)
#  inherits_title  :boolean(1)      default(FALSE)
#  location        :string(255)
#  state           :string(255)     default("normal")
#  rating          :integer(4)      default(0)
#  is_definitive   :boolean(1)      default(FALSE)
#  happened_at     :datetime
#

