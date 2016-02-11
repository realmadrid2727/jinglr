// Persistent audio player
var persistent_audio_player_container = null;
var persistent_audio_player = null;
var persistent_audio_player_details = null;
var persistent_audio_player_paused = true;

$(document).ready(function() {
  initialize_site_js();
});

$(document).on('page:fetch', function() {
  $("#loading").fadeIn(300);
  persistent_audio_player_container = $("#audio_player_container");
  persistent_audio_player = $("#audio_player");
  persistent_audio_player_details = $("#audio_player_details");
  persistent_audio_player_paused = persistent_audio_player.data().jPlayer.status.paused;
});
$(document).on('page:change', function() {
  $("#loading").fadeOut(300);
  //$("#audio_player_container").detach();
  $("#audio_player_container").replaceWith(persistent_audio_player_container);
  $("#audio_player").replaceWith(persistent_audio_player);
  $("#audio_player_details").replaceWith(persistent_audio_player_details);
  if (persistent_audio_player_paused == false) {
    $("#audio_player").jPlayer("play");
  }
});

// All ajax loading
$(document).ajaxStart(function() {
  $("#loading").fadeIn(300);
}).ajaxComplete(function() {
  $("#loading").fadeOut(300);
}).ajaxError(function(event, jqxhr, settings) {
  renderGrowl(jqxhr.responseText, "danger");
});

// A spinner to use wherever
$spinner = $("<div class='text-center m-lg'><i class='icon-spinner icon-spin'></i></div>")

// Fade in waveform images
function fade_in_images() {
  $(".jingle .track-img img").on("load", function () {
    $(this).hide();
    $(this).fadeIn('slow');
  });
}

function initialize_site_js() {
  messageBoxTimerId = 0;
  
  sizeContent();
  //Every resize of window
  $(window).resize(sizeContent);
  
  
  $(".jingle").resize(function() {
    setTimeout(resetGrid, 10);
  });
  
  $(window).resize(function() {
    setTimeout(resetGrid, 10);
  });
  
  $(".realign-grid").click(function() {
    var par = $(this).parents(".jingle");
    par.resize();
  });
  
  function resetGrid() {
    //$('#grid').isotope('reLayout')
  }
  
  
  // Activate best_in_place
  $(".best_in_place").best_in_place();
  // Activate lilcharactercount
  $("input[maxlength], textarea[maxlength], .maxlength").lilCharacterCount();
  //Activate datepicker
  $(".datepicker-input").datepicker();
  // Activate slimscroll
  $(".comment-list.scrollable").slimScroll({height: '200px'});
  
  $('.dropdown-menu input, .dropdown-menu label').click(function(e) {
    e.stopPropagation();
  });
  
  // Class toggle
  $("body").on('click', '[data-toggle^="class"]', function(e){
  		e && e.preventDefault();
  		var $this = $(e.target), $class , $target;
  		!$this.data('toggle') && ($this = $this.closest('[data-toggle^="class"]'));
      	$class = $this.data()['toggle'].split(':')[1];
      	$target = $( $this.data('target') ); //  || $this.attr('href')
      	$target.toggleClass($class);
      	$this.toggleClass('active');
  	});
  
  
  //Dynamically assign height
  function sizeContent() {
    var newHeight = $("html").height() - $("header.header").height() + "px";
    $(".full-height").css("height", newHeight);
    $("section.scrollable.wrapper").trigger("scroll");
  }
  
  // Tabs
  $("body").on('click', ".ajax-tab", function (e) {
    e.preventDefault();
    target_pane = $($(this).attr("data-target"));
    var pageTarget = $(this).attr('href');
    target_pane.load(pageTarget);
  });

  
  // Never-ending scroll loader
  // No need for a plugin, this solves it all
  $('section.scrollable.wrapper').scroll(function() {
    var $this = $(this);
    var $inf_ = $('section.scrollable.wrapper .infinite-page');
    var hitBottom = false;
    if ( ($this.scrollTop() + $this.height() + 50 >= $inf_.height() && $this.scrollTop() + $this.height() <= $inf_.height() + 100) && hitBottom == false ) {
      hitBottom = true;
      if ($("nav.pagination").length != 0) {
        nextPage = $("nav.pagination a[rel=next]").attr("href");
        lastPage = $("nav.pagination span.last a").attr("href");
        $inf_.append("<div id='load_more' class='panel bg-light text-center'><i class='icon-spinner icon-spin icon-large'></i></div>");
        //window.history.pushState(nil, nil, "/new-url");
        $("nav.pagination").remove();
        if (lastPage == undefined) {
          $("#load_more").remove();
          $inf_.append("<div class='panel bg-warning text-center'><div class='panel-body'><i class='icon-ban-circle'></i></div></div>");
        } else {
          $("<div>").load(nextPage + "&partial=true", function() {
            $inf_.append($(this).html());
            $("#load_more").remove();
          });
        }
      }
    }
  });
  
  // Feedback submit form
  $("body").on("ajax:beforeSend", "#new_site_feedback_form", function() {
    $(this).css("opacity", "0.5");
    console.log($(this));
  }).on("ajax:success", "#new_site_feedback_form", function(e, xhr, settings) {
    $("#ajaxModal").modal('hide');
    $("#ajaxModal").remove();
    $(".modal-backdrop").fadeOut(300);
    renderGrowl(xhr.message, "success");
  }).on("ajax:error", "#new_site_feedback_form", function(e, xhr, settings) {
    $("#new_site_feedback_form").css("opacity", "1");
  });
  
  // General submit forms
  $("body")
	  .on("ajax:beforeSend", ".remote_submit_form", function() {
			//$(".loading_dialog").css('display', 'inline');
		})
    .on("ajax:success", ".remote_submit_form", function(xhr, data, status) {
			if ($(this).attr("data-alerts") == "off") {
			  // ..
  		} else {
  			renderGrowl(data.message, "success");
  		}
		})
		.on("ajax:error", ".remote_submit_form", function(xhr, status) {
			//$(this).parent().parent().effect("shake", {times: 4}, 800);
		})
		.on("ajax:complete", ".remote_submit_form", function(xhr, status) {
		  //generateMessageBox($($(this).attr("data-errorbox")), status.responseText, "success");
	});
  
}

// Error box
function generateMessageBox(box, message, message_type) {
  // Get the original bg class
  clearTimeout(messageBoxTimerId);
  var classList = box.attr('class').split(/\s+/);
  $.each( classList, function(index, item){
    if (item.match("^bg-")) {
      original_box_class = item;
    }
  });
  // Find the box with the text, along with the original text
  text_box = box.children(".wrapper")
  original_text = text_box.html();
    
  text_box.html(message.replace (/(^")|("$)/g, ''));
    
  switch (message_type) {
    case "error":
      new_class = "bg-danger";
      break;
    case "success":
      new_class = "bg-success";
      break;
    case "info":
      new_class = "bg-info";
      break;
  }
  box.stop();
  box.switchClass(original_box_class, new_class, 500, "easeInOutQuad");
  messageBoxTimerId = setTimeout(function() {
    box.switchClass(new_class, original_box_class, 500, "easeInOutQuad");
    text_box.html(original_text);
  }, 5000);
}

function renderGrowl(message, message_type) {
  message = message.replace(/(^")|("$)/g, '');
  $.jGrowl(message, {
    life: 7000,
    theme: message_type
  });
}