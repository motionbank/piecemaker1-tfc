jQuery.ajaxSetup({
	'beforeSend': function(xhr) {xhr.setRequestHeader("Accept", "text/javascript")}
});
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
  //moverint = setInterval('checkTime()', 500);
};
function checkTime(){
	if(vidPlayer.isPlaying()){
		var x = vidPlayer.getTime();
		findHighlightable(x);
	}
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

function ajaxFunction(obj,urly){
	obj.ajaxSubmit({url: urly,dataType:'script'});
}
function getFunction(urly,loadInSide){
	if(!loadInSide){
		var loadInSide = false;
	}
	$(".hdble").hide();
	$.get(urly, function(data){
		loadFormDiv(data,loadInSide);
		flashMessage('');
	});
}
function cancelUpload(url,title){
	$.ajax({
		type: "POST",
		url: url,
		dataType: 'script'
	})
	flashError('There was an error uploading "'+title+'". Please try again.')
};
// function goToTab(tabid){
// 	$('.css-tabs li a').removeClass('current')
//   $('#'+tabid).addClass('current')
//   $('.css-panes').hide();
// 	showATab(tabid)
// };
// function showATab(tid){
// 	$('.'+ tid).show();
// }
function s3Upload(videoName,fileSize,contenttype,param,url,prefix){
	$.ajax({
		type: "POST",
		url: url,
		data: 'title='+videoName+'&size='+fileSize+'&vid_id='+param+'&prefix='+prefix+'&contenttype='+contenttype,
		dataType: 'script'
	})
};
function updateVideoTime(){
	var x = '/capture/update_vid_time';
	$.get(x, function(data) {	
		$('#vitime').html(data);
    });
};

$(function(){
	$('.pretty').dataTable({
        "aaSorting": [[ 0, "asc" ]]
    });

	showType = ['Markers','Others'];
	$('#listing_div').data('hide',[]);
	$('#listing_div').data('typehide',[]);
	//code for tabs and video time display
	$("ul.css-tabs").tabs("div.panes > div",{history: true});
	$('.css-tabs li a').bind('click',function(){
			goToTab($(this).attr('id'));
	});
	$('#vitime').live('click', function(event){
		updateVideoTime();
		return false;
	});


	//code for capture scrolling and collapsing video blocks
	$('.dates').live('click', function(){
		dat = $(this).attr("id");
		$.scrollTo('#'+dat,500,{offset:{left:0,top:-102}});
	});
	$('.videoshow').live('click', function(){
		dat = $(this).attr("id").replace('vs-','');
		$('#vid_'+ dat).children('.fi').toggle();
		if($('#vs-' + dat).html() == 'Hide'){
			$('#vs-' + dat).html('Show');
		}else{
			$('#vs-' + dat).html('Hide');
		}
	});
	$('.collapse').live('click', function(){
		$('.video-block').children('.fi').hide();
		$('.videoshow').html('Show');
	});
	$('.expand').live('click', function(){
		$('.video-block').children('.fi').show();
		$('.videoshow').html('Hide');
	});
	//code for keyboard shortcuts in capture
	if($('#quick').data('shortcut') == 'enabled'){ 
		$(document).bind('keydown', 'Ctrl+n', function(){
			getFunction('/capture/new_event/scene.js')
			return false;
		});
		$(document).bind('keydown', 'Ctrl+s', function(){
			getFunction('/capture/new_sub_scene.js')
			return false;
		});
		$(document).bind('keydown', 'Ctrl+m', function(){
			ajaxFunction(jQuery(this),$('#marker').attr('href')+'.js')
			return false;
		});
		$(document).bind('keydown', 'Ctrl+b', function(){
			getFunction('/capture/new_auto_video_in?quick_take=true.js')
			return false;
		});
		$(document).bind('keydown', 'Ctrl+i', function(){
			var theUrl = $('#vidinout').attr('href') + '.js';
			if( $('#vidinout').hasClass('vprep') ){
					getFunction(theUrl)
				}else{
					if(confirm('Do you wish to stop the video?')){
					ajaxFunction(jQuery(this),$('#vidinout').attr('href')+'.js')
					}
				}
				return false;
		});		
	};
	//code for keyboard shortcuts in viewer
	if($('#mark').data('shortcut') == 'enabled'){
		$(document).bind('keydown', 'Ctrl+v', function(){
			var vidid = $('#mark').data('vidid')
			var pieceid = $('#mark').data('pieceid')
			//alert(vidid + ' ' + pieceid)
			makeMarker(vidid,pieceid);
			return false;
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

	$(".turn_off").live('click',function(){
		$('#listing_div').data('hide',listOfNames())
		filter_listing_div()
	});
	
	$(".turn_on").live('click',function(){
		$('#listing_div').data('hide',[])
		filter_listing_div()
	});
	$('.one-listing').live('click',function(){
		highlightListing($(this));
		playerJumpTo($(this).data('time'))
		//alert($(this).data('time'))
		return false;
	});

	$("#toggle-markers").bind('click',function(){
		if($(this).hasClass('greenish')){
			showType.splice($.inArray('Markers', showType), 1);
			// $(this).removeClass('greenish');
			// $(this).addClass('reddish');
			// $(".typemarker").hide();
		}else{
			showType.push('Markers')
			// $(this).removeClass('reddish');
			// $(this).addClass('greenish');
			// $('.one-listing').hide();
			// $(".typemarker").show();
		}
		filter_listing_type()
	})
	$("#toggle-others").bind('click',function(){
		if($(this).hasClass('greenish')){
			showType.splice($.inArray('Others', showType), 1);
			// $(this).removeClass('greenish');
			// $(this).addClass('reddish');
			// $('.one-listing').hide();
			// $(".typemarker").show();
		}else{
			showType.push('Others')
			// $(this).removeClass('reddish');
			// $(this).addClass('greenish');
			// $('.one-listing').show();
			// $(".typemarker").hide();
		}
		filter_listing_type()
	})

	

	//start main click events


  $('#body a').live('click', function(event){
		var theUrl = $(this).attr('href')+'.js';
		if($(this).hasClass('pause')){
			var player = $f('rtmpPlayer')
				player.pause();
			}

		// if($(this).hasClass('tabby')){
		// 	alert('tabby');
		// 	return false;
		// };

		if($(this).hasClass('get-sc')){
			$.get(theUrl, function(data){
				$('#scratchpad').html(data);
				$('#scratchpad').show();
			});
			return false;
		};

		if($(this).hasClass('get')){
						
			if($(this).hasClass('vout')){
				if(confirm('Do you wish to stop the video?')){
					ajaxFunction($(this),$('#vidinout').attr('href')+'.js')
				}
				$(".hdble").hide();
					return false;
			};

			getFunction(theUrl,false);
			$(".hdble").hide();
			return false;
		}//if class get



		if($(this).hasClass('promote')){
			if(confirm('Promote this Sub Scene into a Scene')){
			ajaxFunction($(this),theUrl)
			}
			return false;
		}
		if($(this).hasClass('process')){
			if(confirm('Do you really wish to start processing todays videos? This will overwrite the data on piecemaker.org!')){
			ajaxFunction($(this),theUrl)
			}
			return false;
		}
		if($(this).hasClass('dg')){
			ajaxFunction($(this),theUrl)
			return false;
		}
		if($(this).hasClass('dga')){
			$(".hdble").hide();
			ajaxFunction($(this),theUrl)
			return false;
		}
		if($(this).hasClass('ajx')){
			var player = $f('rtmpPlayer')
			player.pause();
			time = Math.round(player.getTime());
			if(confirm($(this).data('confirm'))){
				ajaxFunction($(this),$(this).attr('href')+'?time='+time+'.js')
			}
			return false;
		}

		if($(this).hasClass('go_to')){
			var player = $f('rtmpPlayer')
			var seekto = $(this).attr('id').replace('go-','') - 0
			player.seek(seekto);
			return false;
		}
		if($(this).hasClass('prev-marker')){
			seekMarker('previous');
			return false;
		}
		if($(this).hasClass('next-marker')){
			seekMarker('next');
			return false;
		}
		if($(this).hasClass('nudge')){
			var player = $f('rtmpPlayer');
			var time = Math.round(player.getTime());
			var amount = $(this).attr('id').replace('go-','') - 0
			player.seek(time + amount);
			return false;
		}
		if($(this).hasClass('dgdele')){
			if(confirm('Are you sure you wish to delete this event?')){
				var y = $(this).attr('id');
		    $.post(theUrl, "_method=post", function(data) {
					jQuery('#event-'+y).remove();
		    });
			}
				return false;
		}
		if($(this).hasClass('marker')){ // ?
				ajaxFunction($(this),theUrl);
				return false;
		}
		if($(this).hasClass('dgdeln')){
			if(confirm('Are you sure you wish to delete this note?')){
				var y = $(this).attr('id')
		    	$.post(theUrl, "_method=post", function(data) {
		      		jQuery('#note-'+data).remove();
		    	});
			}
			return false;
		}
		if($(this).hasClass('dgdelp')){
			if(confirm('Are you sure you wish to delete this photo?')){
				var y = $(this).attr('id');
					    	$.post(theUrl, "_method=post", function(data) {
					      		jQuery('#ph-'+y).remove();
					    	});
			}
			return false;
		}
		if($(this).hasClass('dged')){
			$.get(theUrl, "_method=post", function(data) {
		    loadFormDiv(data,false);
		    });
			$(".hdble").hide();
				return false;
		}

		if($(this).attr('class')=='more'){
			var x = $(this).attr('href')
			address = '/capture/more_description/'+x+'.js';
			$.get(address, function(data) {
				$('#event-'+x).replaceWith(data);
		  });
			return false;
		}
		if($(this).attr('class')=='less'){
			var x = $(this).attr('href')
			address = '/capture/less_description/'+x+'.js';
			$.get(address, function(data) {
				$('#event-'+x).replaceWith(data);
		  });
			return false;
		}

		if($(this).attr('class') == 'photo-link'){
			var x = $(this).attr('href');
			var y = '<img src = "'+x+'" width ="700"></img>'
			$('#ph').css("top",(event.pageY -200 + 'px'))
			$('#ph').css("left",('0px'))
			$('#ph1').html(y)
			$("#ph").show();
			return false;
		}
		if($(this).attr('class') == 'photo-link-close'){
			$("#ph").hide();
			return false;
		}
  });
// end first live block   body a


		
		
	// various buttons in form div
	$('.form_div a').live('click', function(){
		if($(this).attr('id') == 'uploadfile'){
			$('#uploadfile').hide();
    }
      
		if($(this).attr('class') == 'cancel'){
      $('#form_div').hide();
      $(".hdble").show();
      return false;
    }
		if($(this).attr('class') == 'cancel-sc'){
          $('#scratchpad').hide();
          return false;
    }
		if($(this).attr('class') == 'cancel_up'){
     	$('#form_div').hide();
      $(".hdble").show();
			ajaxFunction($(this),$(this).attr("href")+'.js')
      return false;
    }
    if($(this).attr('class') == 'cancel_mod'){
    	$('.formhide').hide();
      $("form.timer").stopTime('backup');
			ajaxFunction($(this),$(this).attr("href")+'.js')
      $(".hdble").show();
      return false;
		}
	});
	// select tags in form_div
	$('#form_div select').live('mouseup', function(){
	  if($(this).attr('id') == 'taggs'){
	  	var taggg = $('#event_tags').attr('value');
		if($('#taggs').attr('value') != 'select some tags from this list'){
	  		if(taggg != ''){taggg = taggg + ','};
	  		taggg = taggg + $('#taggs').attr('value');
			$('#event_tags').attr('value',taggg);
		}
	  	
	  }
		if($(this).attr('id') == 'title-taggs'){
	  	var taggg = $('#event_title').attr('value');
		if($('#title-taggs').attr('value') != 'select a title from this list'){
			
			$('#event_title').attr('value',$('#title-taggs').attr('value'));
		}
	  	
	  }
	});
	
  // this is work in progress

$('.form_div input').live('click', function(){
	if($(this).attr('type') == 'submit' && $(this).parent().hasClass('ajax')){
		$('.formhide').hide(); 
		var theUrl = $(this).parent().attr('action');
		if($(this).parent().hasClass('timer')){
		 	$("form.timer").stopTime('backup');
		}
		ajaxFunction($(this).parent(),theUrl)
		return false;
	}	
});


});


    // var fd = parseInt(this.getClip().fullDuration, 10);
    // var pixpersec = 325 / fd
    // var lineplace = 300 * pixpersec // 5 minute line
    // var intline = Math.round(lineplace)
    // 
    // $('#min10').css('left',intline+'px')