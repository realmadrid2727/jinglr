$(document).ready(initialize_jingles_js);
//$(document).on('page:load', initialize_jingles_js);

function initialize_jingles_js() {

  var $audio_player_container = $("#audio_player_container");
  var $audio_player_details = $("#audio_player_details");
  var $audio_player = $("#audio_player");
  var $audio_button_i = $("#audio_player_container button i");
  var $audio_waveform = $("#audio_player_container img");
  var $audio_progress = $("#audio_player_container .progress");
  var play_state = false; // Chrome is having trouble with the jPlayer status event
  var current_play_button = current_play_button || 0;
  
  audio = {
    // Animate the progress bar
    animatePlayerProgress: function(position) {
      cookie_json = $.parseJSON($.cookie()['currently_playing']);
  		duration = Math.ceil(cookie_json.duration);
      
      // If a position percent is provided, subtract that percentage to get the new duration
      if (position != undefined) {
        duration = parseFloat(((100 - position) / 100) * duration);
  		}
  		
  		$audio_progress.animate({
    		width: "100%"
  		}, duration * 1000, "linear");
    },
    resetPlayerProgress: function() {
      $audio_progress.stop();
      $audio_progress.css("width", "0");
    },
    playButton: function(state) {
      if (state == 'play') {
        $("#"+current_play_button+" i").removeClass("icon-stop");
        $("#"+current_play_button+" i").addClass("icon-play");
        $audio_button_i.removeClass("icon-pause");
    		$audio_button_i.addClass("icon-play");
      } else if (state == 'pause') {
        $("#"+current_play_button+" i").addClass("icon-stop");
        $("#"+current_play_button+" i").removeClass("icon-play");
        $audio_button_i.addClass("icon-pause");
    		$audio_button_i.removeClass("icon-play");
      }
    },
    play: function() {
      $audio_player.jPlayer("play");
      play_state = true;
    },
    pause: function() {
      $audio_player.jPlayer("pause");
      play_state = false;
    },
    stop: function() {
      $audio_player.jPlayer("stop");
      play_state = false;
    }
  }
  
  
  $("#audio_player").jPlayer({
    swfPath: "/swf",
    supplied: "mp3",
    wmode: "window",
    smoothPlayBar: true,
    ready: function(event) {
      // Load the cookie data if it exists
      yummy_cookie = $.cookie()['currently_playing'];
      if (yummy_cookie != undefined) {
        cookie_json = $.parseJSON(yummy_cookie);
        $audio_player.jPlayer("setMedia", {mp3: cookie_json.href});
        $audio_waveform.attr("src", cookie_json.waveform);
        time = $.jPlayer.convertTime(Math.ceil(cookie_json.duration));
        $(".current-time").html(time);
        originalHref = $audio_player_details.children("a").attr("href");
        $audio_player_details.children("a").attr("href", originalHref+"/"+cookie_json.id);
      }
    },
    timeupdate: function(event) {
		  //position = parseInt(event.jPlayer.status.currentPercentRelative, 10) + "%";
		  //$audio_progress.css("width", position);
		  time = $.jPlayer.convertTime(event.jPlayer.status.currentTime);
		  //console.log(time);
		  $(".current-time").html(time);
		},
		play: function(event) {
		  position = parseInt(event.jPlayer.status.currentPercentRelative, 10);
		  audio.playButton('pause');
		  audio.animatePlayerProgress(position);
		  play_state = true;
		},
		pause: function(event) {
		  audio.playButton('play');
		  $audio_progress.stop();
		  play_state = false;
		},
		stop: function(event) {
		  audio.playButton('play');
		  $audio_progress.stop();
		  play_state = false;
		},
		ended: function(event) {
  		audio.playButton('play');
  		// Add the total duration again
  		$(".current-time").html(
  		  $.jPlayer.convertTime(
  		    Math.ceil(
  		      $.parseJSON(
  		        $.cookie()['currently_playing']
  		      ).duration
  		    )
  		  )
  		);
  		audio.resetPlayerProgress();
  		play_state = false;
		}
  });
  
  
  // Play and pause audio through audio player
  $("body").on('click', '#audio_player_container button', function(e) {
    e.preventDefault();
    if (!play_state) {
      audio.playButton('pause')
      audio.play();
    } else {
      audio.playButton('play')
      audio.pause();
    }
  });
  
  // Update the seek bar on click
  $("body").on('click', '#audio_player_container .track-img img', function(e) {
    var position = Math.floor(parseFloat((e.pageX - $(this).offset().left) / $(this).width()) * 100);
    $audio_progress.stop();
    $audio_progress.css("width", position+"%");
    $audio_player.jPlayer("playHead", position);
    if (play_state) {
      audio.animatePlayerProgress(position);
    }
    
    yummy_cookie = $.cookie()['currently_playing'];
    if (yummy_cookie != undefined) {
      cookie_json = $.parseJSON(yummy_cookie);
      time = $.jPlayer.convertTime(Math.ceil(cookie_json.duration) * position / 100);
      $(".current-time").html(time);
    }
  });
  
  $("body").on("mouseenter", "#audio_player_container, #audio_player_details", function(e) {
    $audio_player_details.stop(); // Stops the animation chain when switching elements
    $audio_player_details.fadeIn(200);
    
  }).on("mouseleave", "#audio_player_container, #audio_player_details", function(e) {
    $audio_player_details.stop();
    $audio_player_details.fadeOut(200);
  });
  
  // Play audio by clicking a jingle
  $("body").on('click', '.jp-play', function(e) {
    e.preventDefault();
    cookie_json = {
      id: $(this).attr("data-id"),
      href: this.href,
      duration: $(this).attr("data-duration"),
      waveform: $(this).attr("data-waveform")
    }
    // If something was playing, disable that button before switching
    if (current_play_button != $(this).attr("id")) {
      $("#"+current_play_button+" i").removeClass("icon-stop");
      $("#"+current_play_button+" i").addClass("icon-play");
      audio.pause();
      audio.resetPlayerProgress();
    }
    
    current_play_button = $(this).attr("id");
    
    
    if (!play_state) {
      audio.playButton('play');
    
      if ($(this).hasClass("original")) {} else {
        audio.playButton('pause');
      }
      $audio_player.jPlayer("setMedia", {mp3: this.href });
      audio.play();
      audio.resetPlayerProgress();
    } else {
      if ($(this).hasClass("original")) {} else {
        audio.playButton('play');
      }
      time = $.jPlayer.convertTime(Math.ceil(cookie_json.duration));
      audio.stop();
      audio.resetPlayerProgress();
      $(".current-time").html(time);
    }
    $.cookie("currently_playing", JSON.stringify(cookie_json), {path: '/'});
    $audio_waveform.attr("src", $(this).attr("data-waveform"));
  });
  
  
  $('#jingle_track').change(function () {
    var ext = this.value.match(/\.(.+)$/)[1];
    switch (ext) {
        case 'mp3':
        case 'm4a':
        case 'm4b':
        case 'm4p':
        case 'm4v':
        case 'm4r':
        case '3gp':
        case 'aac':
        case 'mp4':
        case 'wav':
        case 'aif':
        case 'aiff':
        case 'ogg':
        case 'flac':
            //$('#uploadButton').attr('disabled', false);
            break;
        default:
            //generateMessageBox($($(this).attr("data-errorbox")), $(this).attr("data-error"), "error");
            renderGrowl($(this).attr("data-error"), "danger");
            this.value = '';
    }
  });
  
  
  
  
  // File upload
  $('#jingle_track').fileupload({
    url: $('#jingle_track').attr("data-target"),
    method: 'post',
    dataType: 'json',
    global: false,
    maxNumberOfFiles: 1,
    //acceptFileTypes: /(\.|\/)(mp3|x-mp3|wav|mp4|m4a|x-m4a|aif|aiff|ogg|flac)$/i,
    done: function (e, data) {
      file = $.parseJSON(data.jqXHR.responseText);
      $("#progress").hide();
      $("#file-recorder").hide();
      $("li.file-uploader").hide();
      $("li.file-uploader-details").append("<div class='upload'></div>");
      $("li.file-uploader-details .upload").append("<span class='label bg-info'></span>");
      //$("li.file-uploader-details .upload").append("<div class='waveform'></div>");
      $("li.file-uploader-details .upload").append(
        "<div class='pull-right m-l-xs'><a href='"+file[0].delete_url+"' data-remote='true' data-method='"+file[0].delete_type+
        "' data-type='json' class='btn btn-xs bg-danger' id='delete-upload'><i class='icon-remove'></i></a></div>"
      );
      $("li.file-uploader-details .upload span").html(file[0].name);
      //$("li.file-uploader-details .upload .waveform").append("<img src='"+file[0].waveform_url+"' alt='' style='width: 100%;' />");
      $("li.file-uploader-details .upload").attr("id", "jingle_"+file[0].id);
      $("#id").val(file[0].id);
      if ($("#jingle_desc").val() != "") {
        $("#submit-jingle-button").removeClass("disabled");
        $(".modal-submit").removeClass("disabled");
      }
      
      // Add the track to the mixer
      if ($("#jingle_parent_id").length > 0) {
        $("<div>").load(file[0].add_track_remote_url, function() {
          $("#mixer .panel-body.scrollable").append($(this).html());
        });
      }
      
    },
    progressall: function (e, data) {
      $("#progress").show();
      var progress = parseInt(data.loaded / data.total * 100, 10);
      $('#progress .progress-bar').css('width', progress + '%');
    },
    fail: function(e, data) {
      $("#progress").hide();
      error_message = data.jqXHR.responseText.split(".")[0];
      //generateMessageBox($($(this).attr("data-errorbox")), error_message, "error");
      renderGrowl(error_message, "danger");
    }
    
  });
  
  // Following a jingle
  $("body").on("ajax:success", '.follow-jingle-submit-ajax', function(e, xhr, settings){
    $follow = $(".follow_"+xhr.jingle_id);
    if ($follow.length > 1) {
      $(".follow_"+xhr.jingle_id).toggleClass('active');
      $(this).toggleClass('active');
    }
    renderGrowl(xhr.message, "success");
  });
  
  $("body").on("ajax:success", "#delete-upload", function(e, xhr, settings) {
    $("#jingle_"+xhr.jingle_id).remove().delay(300);
    $("li.file-uploader").show();
    $("#submit-jingle-button").addClass("disabled");
    $(".track_1").fadeOut();
    $(".track_1").remove();
    $tracks[1].remove();
    delete $tracks[1];
    mix.rebind(0, $tracks[0]);
  }).on("ajax:error", "#delete-upload", function() {
    console.log("Error");
  });
  
  
  // If adding a track, make the submit button move the hidden inputs inside the form
  $("body").on("click", "#submit-jingle-button", function(e) {
    if ($("#mixer").length > 0) {
      e.preventDefault();
      $("input[id^='track_offset_']").appendTo("#new_jingle_form");
    }
    $("#new_jingle_form").submit();
  });
  
  /*$("body").on("click", "#track_mixer_form #merge_submit_button", function(e) {
    //e.preventDefault();
    $modal = $('<div class="modal fade" id="ajaxModal"><div class="modal-body"></div></div>');
    $('body').append($modal);
    $modal.modal({backdrop: "static"});
    $modal.load($("#track_mixer_form").attr("data-loader"));
  });*/
  
  // Sorting jingles by time in the main page
  $("body").on("click", "#sort-jingles-button", function(e) {
    e.preventDefault();
    var $inf_ = $('section.scrollable.wrapper .infinite-page');
    var from = $("#sort-jingles-from").val();
    var to = $("#sort-jingles-to").val();
    var new_page = window.location.pathname+"?from="+from+"&to="+to;
    //window.location = new_page;
    
    $("<div>").load(new_page + "&partial=true", function() {
      $inf_.html("");
      $inf_.append($(this).html());
      $(".datepicker-input").datepicker();
    });
  });
  
  /* Merge requests and such */
  $("body").on("ajax:success", ".accept-merge-ajax", function(e, xhr, settings) {
    $(this).parent().parent().removeClass("bg-light");
    $(this).parent().children("strong.user span").remove();
    $(this).parent().children(".removeable").remove();
    renderGrowl(xhr.message, "success");
    //$("#collaborations_count_"+data.id)
  }).on("ajax:error", ".accept-merge-ajax", function() {
    console.log("Error");
  });
}