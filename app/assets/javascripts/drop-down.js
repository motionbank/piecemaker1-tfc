$(function(){


// any link with class jsc will pass through here
// other classes will determine further actions
$('#body a.jsc').live('click', function(){

    if($(this).hasClass('ignore')){return}
    if($(this).parents().hasClass('menu-link')){
      DropMenu($(this),event)
      return false
    }
    var side = $(this).hasClass('pause') ? true : false
    var theUrl = $(this).attr('href')+ '.js';

      // main decisions
    if($(this).data('confirmation') ){ //actions with confirmations
      if(confirm($(this).data('confirmation')) ){
        postFunction(theUrl);
        $(".hdble").show();
      }else{
        alert('cancelled 22')
      }
    }else if($(this).hasClass('get-form')){ //actions which put up a form
      $.get(theUrl, function(data) {
        loadFormDiv(data,side);
        });
    }else if($(this).hasClass('get-sc')){ //actions which put up a form
      $.get(theUrl, function(data){
        $('#scratchpad').html(data);
        $('#scratchpad').show();
      });
    }else{ //highlight or rating actions which just act and update
      postFunction(theUrl);
    }

    $('.menu-box').hide();
    $('.removable').remove();
    return false;
  });



//   $('#body a').live('click', function(event){


//    var theUrl = $(this).attr('href')+'.js';
//    if($(this).hasClass('pause')){
//      var player = $f('rtmpPlayer')
//        player.pause();
//      }

//    if($(this).hasClass('get')){

//      if($(this).hasClass('vout')){
//        if(confirm('Do you wish to stop the video?')){
//          ajaxFunction($(this),$('#vidinout').attr('href')+'.js')
//        }
//        $(".hdble").hide();
//          return false;
//      };

//      getFunction(theUrl,false);
//      return false;
//    }//if class get


//    if($(this).hasClass('dg')){
//      ajaxFunction($(this),theUrl)
//      return false;
//    }

//    if($(this).hasClass('ajx')){
//      var player = $f('rtmpPlayer')
//      player.pause();
//      time = Math.round(player.getTime());
//      if(confirm($(this).data('confirm'))){
//        ajaxFunction($(this),$(this).attr('href')+'?time='+time+'.js')
//      }
//      return false;
//    }

//    if($(this).hasClass('go_to')){
//      var player = $f('rtmpPlayer')
//      var seekto = $(this).attr('id').replace('go-','') - 0
//      player.seek(seekto);
//      return false;
//    }


//    if($(this).hasClass('dgdelp')){
//      if(confirm('Are you sure you wish to delete this photo?')){
//        var y = $(this).attr('id');
//                $.post(theUrl, "_method=post", function(data) {
//                    jQuery('#ph-'+y).remove();
//                });
//      }
//      return false;
//    }
//    if($(this).hasClass('dged')){
//      $.get(theUrl, "_method=post", function(data) {
//        loadFormDiv(data,false);
//        });
//        return false;
//    }

//    if($(this).attr('class')=='more'){
//      var x = $(this).attr('href')
//      address = '/capture/more_description/'+x+'.js';
//      $.get(address, function(data) {
//        $('#event-'+x).replaceWith(data);
//      });
//      return false;
//    }
//    if($(this).attr('class')=='less'){
//      var x = $(this).attr('href')
//      address = '/capture/less_description/'+x+'.js';
//      $.get(address, function(data) {
//        $('#event-'+x).replaceWith(data);
//      });
//      return false;
//    }

//    if($(this).attr('class') == 'photo-link'){
//      var x = $(this).attr('href');
//      var y = '<img src = "'+x+'" width ="700"></img>'
//      $('#ph').css("top",(event.pageY -200 + 'px'))
//      $('#ph').css("left",('0px'))
//      $('#ph1').html(y)
//      $("#ph").show();
//      return false;
//    }
//    if($(this).attr('class') == 'photo-link-close'){
//      $("#ph").hide();
//      return false;
//    }
//   });
// // end first live block   body a













});