jQuery.ajaxSetup({
	'beforeSend': function(xhr) {xhr.setRequestHeader("Accept", "text/javascript")}
});


function ajaxFunction(obj,urly){
	obj.ajaxSubmit({url: urly,dataType:'script'});
}
function getFunction(urly,loadInSide){
	if(!loadInSide){
		var loadInSide = false;
	}
	$.get(urly, function(data){
		loadFormDiv(data,loadInSide);
		flashMessage('');
	});
}
function postFunction(myUrl,mySuccess){
	$.post(myUrl,mySuccess)
}

function cancelUpload(url,title){
	$.ajax({
		type: "POST",
		url: url,
		dataType: 'script'
	})
	flashMessage('There was an error uploading "'+title+'". Please try again.','error')
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
function updateVideoTime(pieceId){
	var x = '/capture/update_vid_time/' + pieceId;
	$.get(x, function(data) {
		$('#vitime').html(data);
    });
};

function DropMenu(clickedLink,theEvent){
	var pieceId =  $('#events_presentation').data('pieceid')
	var musData = {
		id: clickedLink.data('id'),
		thePieceId: $('#events_presentation').data('pieceid')
	}
	$('.removable').remove();
	$('#drop').hide();
	var difference = ($(window).scrollTop() + $(window).height()) - theEvent.pageY
	if(difference < 260){
	  top_pos = theEvent.pageY - (260 - difference);
	}else{
	  top_pos = theEvent.pageY;
	}
	$('.menu-box').css('top',top_pos + 'px');
	$('.menu-box').css('left',theEvent.pageX-150 + 'px');
	//
	$('#show-id').html(clickedLink.data('id'));
	$("#drop-down-list").html(Mustache.to_html($("#"+clickedLink.data('menuName')).html(), musData))
	$("#drop").show();
	if(clickedLink.data('menuName') == 'vidm') {
		$.get( '/capture/fill_video_menu/'+clickedLink.data('id')+'?pieceid='+pieceId+'.js', function(data) {
			$('#drop-down-list').append(data)
		});
	}

}
function truncateDescriptions(){
	var doit = $('#events_presentation').data('truncate') == 'more'
	return doit
}





$(function(){
	$('.pretty').dataTable({
        "aaSorting": [[ 0, "asc" ]]
    });
	if(truncateDescriptions()){
		$('.evdes').jTruncate();
	}
	function truncateShowAll(whichAction){
			$('.evdes').each(function(){
				var obj = $(this)
				var moreLink = $('.truncate_more_link', obj);
				var moreContent = $('.truncate_more', obj);
				var ellipsis = $('.truncate_ellipsis', obj);
				if(whichAction == 'truncate'){
					moreContent.hide();
					moreLink.text('more');
					ellipsis.css("display", "inline");
				}else{
					moreContent.show();
					moreLink.text('less');
					ellipsis.css("display", "none");
				}
		})
	}
	if(false){
		truncateShowAll('truncate')
	}

	// close menus
	  $('.menclose').live('click', function(){
    $('#drop').hide();
    $('.removable').remove();
  });

	//code for video time display
	$('#vitime').live('click', function(event){
		var pieceId =  $('#events_presentation').data('pieceid')
		updateVideoTime(pieceId);
	});

	//code for capture scrolling and collapsing video blocks
	$('.dates').live('click', function(){
		$.scrollTo('#'+$(this).attr("id"), 500 , {offset:{left:0,top:-102}});
	});
	// show and hide video block events
	$('.videoshow').live('click', function(){
		dat = $(this).attr("id").replace('vs-','');
		textToShow = $('#vs-' + dat).html() == 'Hide' ? 'Show' : 'Hide'
		$('#vs-' + dat).html(textToShow);
		$('#vid_'+ dat).children('.fi').toggle();
	});
	$('.collapse').live('click', function(){
		$('.video-block').children('.fi').hide();
		$('.videoshow').html('Show');
	});
	$('.expand').live('click', function(){
		$('.video-block').children('.fi').show();
		$('.videoshow').html('Hide');
	});
	$('.truncate').live('click', function(){
		truncateShowAll('truncate')
	});
	$('.untruncate').live('click', function(){
		truncateShowAll('smith')
	});




	//code for keyboard shortcuts in capture
	if($('#quick').data('shortcut') == 'enabled'){
		$(document).bind('keydown', 'Ctrl+n', function(){
			theUrl = $('#quick-scene').attr('href')+'.js'
			getFunction(theUrl)
			return false;
		});
		$(document).bind('keydown', 'Ctrl+s', function(){
			theUrl = $('#quick-sub').attr('href')+'.js'
			getFunction(theUrl)
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
						alert(theUrl)
						$.post(theUrl)
					}
				}
				return false;
		});
	};








	// various buttons in form div
	$('.form_div a').live('click', function(){
		if($(this).attr('id') == 'uploadfile'){
			$('#uploadfile').hide();
    }

		if($(this).attr('class') == 'cancel'){
			clearFormDiv('');
      return false;
    }
		if($(this).attr('class') == 'cancel-sc'){
          $('#scratchpad').hide();
          return false;
    }
		if($(this).attr('class') == 'cancel_up'){
     	clearFormDiv('');
			ajaxFunction($(this),$(this).attr("href")+'.js')
      return false;
    }
    if($(this).attr('class') == 'cancel_mod'){
    	disableFormElements();
    	clearFormDiv('');
    	localStorage.removeItem('event[title]');
			localStorage.removeItem('event[description]');
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

});


    // var fd = parseInt(this.getClip().fullDuration, 10);
    // var pixpersec = 325 / fd
    // var lineplace = 300 * pixpersec // 5 minute line
    // var intline = Math.round(lineplace)
    //
    // $('#min10').css('left',intline+'px')