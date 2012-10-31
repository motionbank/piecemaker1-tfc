$(function(){

// any link with class jsc will pass through here
// other classes will determine further actions
$('#body a.jsc').live('click', function(){
    if($(this).hasClass('ignore')){return}
    if($(this).hasClass('pause')){$f('rtmpPlayer').pause();}
    if($(this).parents().hasClass('menu-link')){
      DropMenu($(this),event)
      return false
    }
    var theUrl = $(this).attr('href') // I don't like all this but it's to add the time if necessary

    if($(this).hasClass('player-time')){
     var player = $f('rtmpPlayer')
     player.pause();
     time = Math.round(player.getTime());
     theUrl = theUrl + '?time=' + time
   }
    if($(this).hasClass('go_to')){
     var seekto = $(this).data('seek') - 0
     $f('rtmpPlayer').seek(seekto);
     return false;
   }
    var side = $(this).hasClass('pause') ? true : false
    theUrl = theUrl + '.js';

      // main decisions
    if($(this).data('confirmation') ){ //actions with confirmations
      if(confirm($(this).data('confirmation')) ){
        postFunction(theUrl);
        $(".hdble").show();
      }else{

      }
    }else if($(this).hasClass('get-form')){ //actions which put up a form
      $.get(theUrl, function(data) {
        loadFormDiv(data,side);
        });
    }else if($(this).hasClass('get-sc')){ //put upthe scratchpad
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













});