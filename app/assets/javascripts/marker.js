jQuery.ajaxSetup({
	'beforeSend': function(xhr) {xhr.setRequestHeader("Accept", "text/javascript")}
});
function ajaxFunction(obj,urly){
	obj.ajaxSubmit({url: urly,dataType:'script'});
};

$(function(){
	$(document).bind('keydown', 'Ctrl+m', function(){
		ajaxFunction($(this),$('#marker').attr('href')+'.js')
		return false;
	});

	$('#quick a').bind('click', function(event){
			ajaxFunction($(document),$('#marker').attr('href')+'.js')
			return false;
		});

	$('.a-marker a').live('click',function(){
		ajaxFunction($(document),$(this).attr('href')+'.js')
		return false;
	})
});