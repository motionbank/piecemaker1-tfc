jQuery.ajaxSetup({
	'beforeSend': function(xhr) {xhr.setRequestHeader("Accept", "text/javascript")}
});
$(function(){
	 $('#form_div input:checkbox').live('click',function(){
	 	 var modelName = $(this).attr('class').split(' ')[1]
	 	 checkAll(this,'check_all_able',modelName);
	 });
	 $('#main input:checkbox').live('click',function(){
	 	 var modelName = $(this).attr('class').split(' ')[1]
	 	 checkAll(this,'check_all_able',modelName);
	 });

	// stops the automatic saving and submits ajax forms
	$('form.ajax input:submit').live('click', function(){
		disableFormElements();
		if($(this).parent().hasClass('timer')){
		 	$("form.timer").stopTime('backup');
		}
		ajaxFunction($(this).parent(),$(this).parent().attr('action'))
		return false;
	});



});


function disableFormElements(){
	$('.formhide').hide();
}

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

function flashMessage(message){
	$('#message').css('background-color','#bfb');
	$('#message').css('border-color','#0a0');
	$('#message').css('color','#060');
	if(arguments[1]){
		$('#message').css('background-color','#faa');
		$('#message').css('border-color','#900');
		$('#message').css('color','#600');
	}
	if(message.length > 0){
	$('#message').html(message);
	$('#message').fadeIn(200).delay( 2500 ).fadeOut(200);
	}else{
		$('#message').hide();
	}
}

function clearStorage(keyName){
	localStorage.removeItem(keyName)
	alert('removed old-app57')
}
function clearFormDiv(messageForFlash){
	$("#form_div").hide();
	$("#form_div").html('');
	$(".hdble").show();
	flashMessage(messageForFlash);
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
	$(".hdble").hide();
	if(typeof(Storage) !== "undefined") {
			var textName = "event[description]"
			var titleName = "event[title]"
			var title = localStorage.getItem(titleName);
			var description = localStorage.getItem(textName);
			if(title && $('input[name="'+titleName+'"]').length > 0){
				alert('Refilling Title with recovered data.');
				$('input[name="'+titleName+'"]').val(title)
			}
			if(description && $('textarea[name="'+textName+'"]').length > 0){
				alert('Refilling Description with recovered data.');
				$('textarea[name="'+textName+'"]').val(description)
			}
			$('form.timer').everyTime(2000,'backup',function (){
				localStorage[titleName] = $('input[name="'+titleName+'"]').val();
				localStorage[textName] = $('textarea[name="'+textName+'"]').val();
			},
			true);
		}
	//$("textarea:first", document.forms[2]).focus();
	//$("input[type='text']:first", document.forms[2]).focus();
}
