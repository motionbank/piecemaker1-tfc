var showType = ['Markers','Others'];

function filter_listing_type(){
  $('.one-listing').hide();
  $.each(showType,function(i,tp){
    if(tp == 'Markers'){
      $('.one-listing').each(function(){
        if($(this).hasClass('typemarker')){
          $(this).show();
        }
      })
    }
    if(tp == 'Others'){
      $('.one-listing').each(function(){
        if(!$(this).hasClass('typemarker')){
          $(this).show();
        }
      })
    }
  })
  $('.type-select').each(function(){
    if($.inArray($(this).html(),showType) >= 0){
        $(this).removeClass('reddish')
        $(this).addClass('greenish')
      }else{
        $(this).removeClass('greenish')
        $(this).addClass('reddish')
      }
  })
};
function listOfNames(){
  var names = [];
  $('.name-toggle').each(function(){
    names.push($(this).html())
  })
  return names;
};
function filter_listing_div(){
  var nameList = $('#listing_div').data('hide');
  $('.one-listing').show();
  $.each(nameList,function(ind,x){
    var st = ".user-" + x
    $(st).hide();
  })
  $('.name-toggle').each(function(){
    if($.inArray($(this).html(),nameList) < 0){
        $(this).removeClass('reddish')
        $(this).addClass('greenish')
      }else{
        $(this).removeClass('greenish')
        $(this).addClass('reddish')
      }
  })
}
function addToHideList(personName){
  var nameList = $('#listing_div').data('hide');
  if($.inArray(personName, nameList) < 0){
    nameList.push(personName);
  }
  $('#listing_div').data('hide', nameList);
};
function removeFromHideList(personName){
  var nameList = $('#listing_div').data('hide');
  nameList.splice($.inArray(personName, nameList), 1);
  $('#listing_div').data('', nameList);
};

function makeAnnotation(vidid,pieceid){
  var player = $f('rtmpPlayer');
  player.pause();
  time = Math.round(player.getTime());
  var x = "/add_annotation/"+pieceid+'/'+vidid+'/'+time+'.js';
  getFunction(x,true);
};
function makeSubAnnotation(vidid,pieceid){
  var player = $f('rtmpPlayer');
  player.pause();
  time = Math.round(player.getTime());
  var x = "/add_sub_annotation/"+pieceid+'/'+vidid+'/'+time+'.js';
  getFunction(x,true);
};
function makeMarker(vidid,pieceid){
  var player = $f('rtmpPlayer');
  time = Math.round(player.getTime());
  var x = "/add_marker/"+pieceid+'/'+vidid+'/'+time+'.js';
  $.ajax({
    type: "POST",
    url: x,
    dataType: 'script'
  });
};

//functions for highlighting events while video is playing in the viewer
function getEventTimes(){
  var times = new Array();
  $('.one-listing').each(function(){
      times.push([$(this).data('time'),$(this).data('duration'),$(this).data('id')])

  });
  eventTimes = times;
};
function seekMarker(direction){
  var player = $f('rtmpPlayer');
  var x = player.getTime();
  getEventTimes();
  var winner = null;
  var len=eventTimes.length;
  if(direction == 'next'){
    for(var i=0; i<len; i++) {
      if(eventTimes[i][0] > x){
        winner = eventTimes[i];
        break;
      }
    }
  }else{
    len -= 1;
    for(var i=len; i>=0; i--) {
      if(eventTimes[i][0] < x){
        winner = eventTimes[i];
        break;
      }
    }
  }
  if(winner){
    player.seek(winner[0]);
  }
};
function startPolling(){
  getEventTimes();
  eventTimesLength = eventTimes.length;
  vidPlayer = $f('rtmpPlayer');
  moverint = setInterval('checkTime()', 500);
};
function checkTime(){
  if(vidPlayer.isPlaying()){
    var x = vidPlayer.getTime();
    findHighlightable(x);
  }
}
function stopPolling(){
  clearInterval(moverint)
}
function findHighlightable(time){
  var i = 0;
  var winner = -1
  var highlightable = new Array();
  for(i=0;i<eventTimesLength;i++){
    // if the event is before the time and its endtime is after the time
    if(eventTimes[i][0] < time && eventTimes[i][0] + eventTimes[i][1] >= time){
      winner = i;
      highlightable.push(eventTimes[i]);
    }
    if(eventTimes[i][0] > time) break;
  }
  if(winner >= 0){
    highlightListings(highlightable);
    winner = -1
  }else{
    unHighlightListings();
  }
};
function highlightNearest(time){
  var i = 0;
  var winner = -1
  for(i=0;i<eventTimesLength;i++){
    // if the event is before the time and its endtime is after the time
    if(eventTimes[i][0] < time && eventTimes[i][0] + eventTimes[i][1] >= time){
      winner = i;
      break;
    }
  }
  if(winner >= 0){
    highlightListing(eventTimes[winner]);
    winner = -1
  }else{
    unHighlightListings();
  }
};
function highlightListings(selected){
  unHighlightListings();
  var listing = ''
  var last = ''
  var selectedLength = selected.length;
  for(i=0;i<selectedLength;i++){
    listing = $('#listing-'+ selected[i][2]);
    listing.addClass('list-high');
    listing.children('.sb').addClass('list-sub-high');
  }
  listing = $('#listing-' + selected[0][2]);
  var container = listing.get(0).parentNode;
  var nTop = listing.position().top - $(container.childNodes[1]).position().top;
  $(container).scrollTop(nTop);
};
function highlightListing(infor){
  listing = $('#listing-'+ infor[2])
  if ( listing.hasClass('list-high') ) return;

  var container = listing.get(0).parentNode;
  var nTop = listing.position().top - $(container.childNodes[1]).position().top;
  $(container).scrollTop(nTop);

  unHighlightListings();
  listing.addClass('list-high');
  listing.children('.sb').addClass('list-sub-high');
};
function unHighlightListings(){
  $('.one-listing').removeClass('list-high');
  $('.sb').removeClass('list-sub-high');
}

function playerJumpTo(timeCode){
  var player = $f('rtmpPlayer');
  player.seek(timeCode);
}





$(function(){
  $('#listing_div').data('hide',[]);
  $('#listing_div').data('typehide',[]);

  //code for keyboard shortcuts in viewer
  if($('#mark').data('shortcut') == 'enabled'){
    $(document).bind('keydown', 'Ctrl+v', function(){
      var vidid = $('#mark').data('vidid')
      var pieceid = $('#mark').data('pieceid')
      makeMarker(vidid,pieceid);
    });
  }


// viewer name filter and player control
  $(".name-toggle").live('click',function(){
    if($(this).hasClass('greenish')){
      addToHideList($(this).html())
    }else{
      removeFromHideList($(this).html())
    }
    filter_listing_div()
  });

//turns off all listings of all names
  $(".turn_off").live('click',function(){
    $('#listing_div').data('hide',listOfNames())
    filter_listing_div()
  });

// turns on all listings of all names
  $(".turn_on").live('click',function(){
    $('#listing_div').data('hide',[])
    filter_listing_div()
  });




  $('.one-listing').live('click',function(){
      $(this).addClass('list-high');
      $(this).children('.sb').addClass('list-sub-high');
    //highlightListing($(this));
    playerJumpTo($(this).data('time'))
    alert($(this).data('time'))
    return false;
  });





  $("#toggle-markers").bind('click',function(){
    if($(this).hasClass('greenish')){
      showType.splice($.inArray('Markers', showType), 1);
    }else{
      showType.push('Markers')
    }
    filter_listing_type()
  })
  $("#toggle-others").bind('click',function(){
    if($(this).hasClass('greenish')){
      showType.splice($.inArray('Others', showType), 1);
    }else{
      showType.push('Others')
    }
    filter_listing_type()
  })


  $('#nudgers a').live('click', function(event){
    if($(this).hasClass('prev-marker')){
      seekMarker('previous');
    }
    else if($(this).hasClass('next-marker')){
      seekMarker('next');
    }
    else{
      var player = $f('rtmpPlayer');
      var time = Math.round(player.getTime());
      var amount = $(this).attr('id').replace('go-','') - 0
      player.seek(time + amount);
    }
    return false
  })


});// end jquery dom ready block