$(function(){

  $('.menclose').live('click', function(){
    $('.menu-box').hide();
    $('.removable').remove();
  });
  
  // this make the drop down menu drop down
  // 
  $('.menu-link a').live('click', function(event){
    var id = $(this).data('id');
    $("#main").data('event-id', id);
    $('.show-id').html('<span style = "color:#fcc">'+id+'</span>');

    // calculate position and move all menus to the right place
    $('.removable').remove();
    $('.menu-box').hide();
    var difference = ($(window).scrollTop() + $(window).height()) - event.pageY
    if(difference < 260){
      top_pos = event.pageY - (260 - difference);
    }else{
      top_pos = event.pageY;
    }
    $('.menu-box').css('top',top_pos + 'px');
    $('.menu-box').css('left',event.pageX-150 + 'px');

    // evdm vidm sevdm vevdm vsevdm
    //decide which menu to drop down
    $("#"+$(this).data('menuName')).show();
    if($(this).data('menuName') == 'vidm'){
      var pieceId = $(this).parents('#events_presentation').data('pieceid')
      $.get('/capture/fill_video_menu/'+id+'?pieceid='+pieceId,function(data){
        $('#video-dropdown').append(data);
      });
    }
    return false;
  });

// click in menu does the right thing 
  $('.dropdown a').live('click', function(){
    if($(this).hasClass('ignore')){return}
    var id = $("#main").data('event-id');
    var side = $(this).hasClass('pause') ? true : false
    var urlWithId = $(this).attr('href') + id + '.js';

      // main decisions
    if($(this).data('confirmation') ){ //actions with confirmations
      if(confirm($(this).data('confirmation')) ){
        ajaxFunction($(this),urlWithId);
        $(".hdble").show();
      }else{
        alert('cancelled 79')
      }
    }else if($(this).hasClass('get-form')){ //actions which put up a form
      $.get(urlWithId, "_method=post", function(data) {
        loadFormDiv(data,side);
        });
    }else{ //highlight or rating actions which just act and update
      ajaxFunction($(this),urlWithId);
    }

    $('.menu-box').hide();
    $('.removable').remove();
    return false;
  });

});