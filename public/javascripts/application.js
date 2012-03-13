jQuery.ajaxSetup({
	'beforeSend': function(xhr) {xhr.setRequestHeader("Accept", "text/javascript")}
});
$(function(){
	
	
	$('#jump a').live('click',function(){
		var dvNumber = $(this).attr('id').replace('j','');
		$.scrollTo('#vid_'+dvNumber);
		$.scrollTo("-=100");
		return false;
	});
	$('#documentation a').live('click',function(){
		var href = $(this).attr('href').replace("#",'');
		$.scrollTo('#'+href);
		$.scrollTo("-=100");
		return false;
	});

 $('#form_div input:checkbox').live('click',function(){
 	 var modelName = $(this).attr('class').split(' ')[1]
 	 checkAll(this,'check_all_able',modelName);
 });
 $('#main input:checkbox').live('click',function(){
 	 var modelName = $(this).attr('class').split(' ')[1]
 	 checkAll(this,'check_all_able',modelName);
 });

function checkAll(el,cl,mn){
	if($(el).hasClass('check-all')){
		var checkBoxes = $('input:checkbox');
		$.each(checkBoxes,function(i){
			if($(checkBoxes[i]).hasClass(cl) && $(checkBoxes[i]).hasClass(mn)) {
				checkBoxes[i].checked = $(el).attr('checked');
			}
		});
	}
}


	jQuery('#colorpicker td').live('click', function(){
		//this changes the color field when using the color_picker helper in application_helper.rb
		var color = jQuery(this).css('background-color');
		jQuery('#div_class').attr('value',toHex(color));
		jQuery('#color-display').css('background-color',color); 
	});

});

function flashMessage(message){
	if(message.length > 0){
	$('.message').html(message);
	$('.message').show();
	}else{
		$('.message').hide();
	}
}
function flashError(message){
	if(message.length > 0){
	$('.message').html(message);
	$('.message').css('background-color','#faa');
	$('.message').css('border-color','#900');
	$('.message').css('color','#600');
	$('.message').show();
	}else{
		$('.message').hide();
	}
}



function toHex(color){
	if(color.match(/^rgb\(([0-9]|[1-9][0-9]|[1][0-9]{2}|[2][0-4][0-9]|[2][5][0-5]),[ ]{0,1}([0-9]|[1-9][0-9]|[1][0-9]{2}|[2][0-4][0-9]|[2][5][0-5]),[ ]{0,1}([0-9]|[1-9][0-9]|[1][0-9]{2}|[2][0-4][0-9]|[2][5][0-5])\)$/)){
	      var c = ([parseInt(RegExp.$1),parseInt(RegExp.$2),parseInt(RegExp.$3)]);
	      var pad = function(str){
	            if(str.length < 2){
	              for(var i = 0,len = 2 - str.length ; i<len ; i++){
	                str = '0'+str;
	              }
	            }
	            return str;
	      }

	      if(c.length == 3){
	        var r = pad(c[0].toString(16)),g = pad(c[1].toString(16)),b= pad(c[2].toString(16));
	        color = r + g + b;
	      }
	}
	return color;
}

function clearFormDiv(){
	$('#form_div').html('');
	$('#form_div').hide();
}
function loadFormDiv(data,isSide){
	userHasClicked = false;
	if(isSide){
		$('#form_div').html('');
		$('#form_div').css("margin-left",'100px');
		$('#form_div').css("width", '400px');
		$('#form_div').css("top", '105px');
	};
	$('#form_div').html(data);
	$('#form_div').show();
	$("#form_div textarea:first").focus();
	$("#form_div input[type='text']:first").focus();
	//$("textarea:first", document.forms[2]).focus();
	//$("input[type='text']:first", document.forms[2]).focus();
}
