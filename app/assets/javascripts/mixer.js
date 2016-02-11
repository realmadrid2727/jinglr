$(document).ready(initialize_mixer_js);
//$(document).on('page:load', initialize_mixer_js);

function initialize_mixer_js() {
  $track_mixer = $("#track-mixer"); // The sidebar mixer element
  $above_track_mixer = $("#above-track-mixer"); // Div containing everything above the mixer
  $overlay = $track_mixer.children(".drop-overlay"); // Overlay showing the droppable status for tracks
  $tracks = {}
  mix = {
    // Click the play button triggers either a play or a stop
    trigger: function(state) {
      switch (state) {
        case 'play':
          $("#mixer .jingle .track-img").trigger("mouseenter");
          mix.resetProgressBar();
          $(".track-play i").addClass('icon-stop');
          $(".track-play i").removeClass('icon-play');
          $.each($tracks, function(index, track) {
            // Handle any timeline offset tracks
            if (track.settings.offset != undefined) {
              // If it's a negative offset, we'll apply a timeout to the other tracks instead
              if (track.settings.offset < 0) {
                $.each($tracks, function(index2, track2) {
                  if (index2 != index) {
                    mix.controlTrack(track, "play", Math.abs(track.settings.offset));
                  }
                });
              } else {
                track.settings.timer = window.setTimeout(
                  mix.controlTrack,
                  track.settings.offset*1000,
                  track,
                  "play"
                );
              }
            } else {
              mix.controlTrack(track, "play");
            }
          });
          break;
        case 'stop':
          $("#mixer .jingle .track-img").trigger("mouseleave");
          $(".track-play i").addClass('icon-play');
          $(".track-play i").removeClass('icon-stop');
          $.each($tracks, function(index, track) {
            if (track.settings.timer != undefined) {
              clearTimeout(track.settings.timer);
            }
            mix.controlTrack(track, "stop");
          });
          mix.resetProgressBar();
          break;
      }
    },
    // Play/stop track
    controlTrack: function(track, act, playHead) {
      playHead = typeof playHead !== 'undefined' ? playHead : 0;
      track.jPlayer(act, playHead);
    },
    /* Find which track has the highest duration.
       This is used to determine which waveform is used as a reference point for the progress
       bar and to scale other waveforms at percentages below it.
    */
    highestDurationId: function() {
      highest_num = 0;
      highest_id = 0;
      $.each($tracks, function(index, track) {
        if (highest_num > parseFloat(track.settings.duration)) {
          highest_num = highest_num;
        } else {
          highest_num = parseFloat(track.settings.duration);
          highest_id = index;
        }
      });
      return highest_id;
    },
    // Get the index (track_'#') of the element
    getTrackId: function($e) {
      if ($e.length > 0) {
        return parseInt($e.attr("id").split("_")[1]);
      } else {
        return;
      }
    },
    rebind: function(index, value) {
      value.jPlayer("destroy"); // Unbind the handler to reinitialize for rescaling
      mix.attachJPlayerObjects(index, value);
    },
    attachJPlayerObjects: function(index, value) {
      id = mix.getTrackId($(value));
      $waveform = $("img#waveform_"+id);
      duration = $(value).attr("data-duration");
      $tracks[id] = $(value);
      $tracks[id].settings = {};
      $tracks[id].settings.duration = duration;
      
      $tracks[id].jPlayer({
        swfPath: "/swf",
        supplied: "mp3",
        wmode: "window",
        smoothPlayBar: true,
        ready: function(event) {
          id = mix.getTrackId($(value));
          $(value).jPlayer("setMedia", {mp3: $(value).attr("data-path")});
          $waveform = $("img#waveform_"+id);
          
          // If the duration isn't the longest, scale the waveform to a percentage
          if (mix.highestDurationId() != id) {
            $waveform.css("width", (mix.widthPercent($tracks[id]) * $waveform.width()) + "px");
          } else {
            $waveform.css("width", "100%");
          }
        },
        timeupdate: function(event) {
          if (mix.highestDurationId() == mix.getTrackId($(value))) {
      		  //position = parseInt(event.jPlayer.status.currentPercentRelative, 10) + "%";
      		  //$(".progressbar").css("width", position);
      		  // Stop the player if the time exceeds the duration of the highest duration track
      		}
    		},
    		loadstart: function(event) {
      		//console.log("Loading track");
    		},
    		waiting: function(event) {
      		//console.log("Waiting");
    		},
    		playing: function(event) {
    		  //console.log("Playing");
      		$(".progressbar").animate({
            width: "100%"
          }, {
            duration: $tracks[mix.highestDurationId()].settings.duration * 1000,
            easing: "linear",
            step: function(now) {
              //w = parseInt($tracks[mix.highestDurationId()].data().jPlayer.status.currentTime);
              //$(".progressbar").css("width", w + "%");
              //console.log(now);
              //console.log(event);
              //console.log($tracks[mix.highestDurationId()].data().jPlayer.status);
            }
          });
    		},
    		stop: function(event) {
      		$(".progressbar").stop();
      		$(".progressbar").css("width","0");
    		},
    		pause: function(event) {
      		$(".progressbar").stop();
    		},
    		ended: function(event) {
          if (mix.highestDurationId() == mix.getTrackId($(value))) {
            $(".track-play i").addClass('icon-play');
            $(".track-play i").removeClass('icon-stop');
            $.each($tracks, function(index, track) {
              mix.controlTrack(track, "stop");
            });
            $(".progressbar").stop();
            $(".progressbar").css("width","0");
          }
    		}
      });
    },
    // Calculate the percentage to scale the waveform down to
    // duration / highest_duration = percent
    widthPercent: function(track) {
      percent = track.settings.duration / $tracks[mix.highestDurationId()].settings.duration;
      return percent;
    },
    // Calculate the offset (in seconds) of the track in the timeline
    durationOffset: function(track, left, width) {
      percent = left / width;
      return percent * track.settings.duration;
    },
    setDuration: function($e) {
      if ($e.length > 0) {
        eWidth = $e.parent().width();
        id = mix.getTrackId($e);
        duration = mix.durationOffset(
          $tracks[mix.highestDurationId()],
          $e.position().left, eWidth
        );
        $tracks[id].settings.offset = duration;
        $(".track_"+id+" .info .offset span").html(parseFloat(duration).toFixed(3));
        $("#track_offset_"+id).val(parseFloat(duration).toFixed(3));
      } else {
        return;
      }
    },
    getDuration: function($e) {
      if ($e) {
        eWidth = $e.parent().width();
        id = mix.getTrackId($e);
        return mix.durationOffset($tracks[id], $e.position().left, eWidth);
      } else {
        return;
      }
    },
    trackMixerState: function(state, message) {
      if (state == "on") {
        $overlay.addClass("bg-success");
        $overlay.removeClass("bg-warning bg-danger");
      } else if (state == "off") {
        $overlay.removeClass("bg-success bg-danger");
        $overlay.addClass("bg-warning");
      } else if (state == "exceed") {
        $overlay.removeClass("bg-success bg-warning");
        $overlay.addClass("bg-danger");
      }
      $overlay.children("span").html(message);
    },
    resetProgressBar: function() {
      $(".progressbar").stop();
      //$(".progressbar").animate({width: "0px"}, 100);
      $(".progressbar").css("width", "0px");
    }
  }; // The tracks
  
  // Fixed track mixer
  $("section.scrollable.wrapper").scroll(function() {
    $this = $(this);
    $sidebar = $("#browser-sidebar");
    if ($sidebar.length > 0) {
      pos = $above_track_mixer.position().top + $above_track_mixer.height() + 10;
      // Correct the height position
      if ($this.scrollTop() >= pos) {
        $track_mixer.addClass("affixed");
        $track_mixer.css("width", $sidebar.width()-30+"px");
      } else {
        $track_mixer.removeClass("affixed");
      }
      // Readjust the width if resized
      if ($track_mixer.width() != $sidebar.width()-30) {
        $track_mixer.css("width", $sidebar.width()-30+"px");
      }
    }
  });
  
  // Droppable tracks into mixer
  $track_mixer.droppable({
    accept: ".jingle .panel.draggable",
    tolerance: "touch",
    activate: function(e, ui) {
      $track_mixer.removeClass("active");
      $overlay.fadeIn(200).css(
        "width", $track_mixer.width()+"px",
        "height", $track_mixer.height()+"px"
      ).children("span").css(
        "line-height", $track_mixer.height()+"px"
      );
      if ($track_mixer.children(".jingle").length >= parseInt($track_mixer.attr("data-max"))) {
        mix.trackMixerState("exceed", $track_mixer.data().error);
      } else {
        mix.trackMixerState("off", $track_mixer.data().success);
      }
    },
    deactivate: function(e, ui) {
      $track_mixer.removeClass("active");
      $overlay.fadeOut(200);
    },
    drop: function(e, ui) {
      $track_mixer.removeClass("active");
      $(ui.helper).effect("transfer", { to: "#track-mixer span:last-child" }, 250);
      $(ui.helper).fadeOut(200);
      $.ajax({
        url: ui.draggable.attr("data-path"),
        data: "jingle_id="+ui.draggable.attr("data-jingle"),
        type: "PUT",
        context: document.body
      }).success(function(data) {
        $track_mixer.append(data);
      });
    },
    over: function(e, ui) {
      $track_mixer.addClass("active");
      if ($track_mixer.children(".jingle").length >= parseInt($track_mixer.attr("data-max"))) {
        mix.trackMixerState("exceed", $track_mixer.data().error);
      } else {
        mix.trackMixerState("on", $track_mixer.data().success);
      }
    },
    out: function(e, ui) {
      $track_mixer.removeClass("active");
      if ($track_mixer.children(".jingle").length >= parseInt($track_mixer.attr("data-max"))) {
        mix.trackMixerState("exceed", $track_mixer.data().error);
      } else {
        mix.trackMixerState("off", $track_mixer.data().success);
      }
    }
  });
  
  
  $("body").on("mouseover", ".jingle .panel.draggable", function() {
    // Draggable jingles that go into mixer
    $(this).draggable({
      revert: true,
      helper: "clone",
      appendTo: "body",
      containment: "window",
      start: function(e, ui) {
      
        $e = ui.helper;
        $e.animate({
          opacity: 0.5
        }, 200);
        $e.css("z-index", "9999", "width", $($e.context).width()+"px");
      },
      drag: function(e, ui) {
        $e.css("width", $($e.context).width()+"px");
      }
    });
  });
  
  // Fixed track info boxes
  $("#mixer .panel-body.scrollable").scroll(function() {
    $this = $(this);
    $track_info = $(".track .info");
    $track_label = $(".track .jingle .track-img .jingle-desc");
    pos = $track_info.parent().position().left + 30;
    // Correct the left position
    if ($this.scrollLeft() >= pos) {
      $track_info.addClass("affixed");
      $track_info.css("left", "0");
      if ($track_info.css("opacity") == 1) {
        $track_info.animate({
          opacity: 0.8
        }, 200);
      }
      
      $track_label.css("left", Math.abs($this.scrollLeft())-20+"px");
      if ($track_label.css("opacity") == 1) {
        $track_label.animate({
          opacity: 0.8
        }, 200);
      }
    } else {
      $track_info.removeClass("affixed");
      if ($track_info.css("opacity") != 1) {
        $track_info.animate({
          opacity: 1.0
        }, 200);
      }
      if ($track_label.css("opacity") != 1) {
        $track_label.animate({
          opacity: 1.0
        }, 200);
      }
      $track_label.css("left", "10px");
    }
    
    if ($this.scrollLeft() > 0) {
      $("i.icon-arrow-left").show();
      $("i.icon-arrow-right").show();
    }
    if ($this.scrollLeft() >= $this.width()) {
      $("i.icon-arrow-left").show();
      $("i.icon-arrow-right").hide();
    }
    if ($this.scrollLeft() < 60) {
      $("i.icon-arrow-left").hide();
      $("i.icon-arrow-right").show();
    }
  });
  
  $(".mixer-scroll-right").on("click", function() {
    $scroll = $("#mixer .panel-body.scrollable");
    $scroll.stop().animate({
      'scrollLeft': $scroll.scrollLeft() + 400
      }, {
        duration: 300,
        specialEasing: 'easeInOutExpo'
    });
  });
  
  $(".mixer-scroll-left").on("click", function() {
    $scroll = $("#mixer .panel-body.scrollable");
    $scroll.stop().animate({
      'scrollLeft': $scroll.scrollLeft() - 400
      }, {
        duration: 300,
        specialEasing: 'easeInOutExpo'
    });
  });
  
  
  // Dragging a track along the mixer timeline
  $("body").on("mouseover", "#mixer .jingle .track-img img", function() {
    $(this).draggable({
      axis: 'x',
      start: function(e, ui) {
        // Only allow dragging if there are two tracks
        if ($tracks[1] == undefined) {
          return false;
        } else {
          $e = $(this);
          $e.animate({
            opacity: 0.5
          }, 200);
        }
      },
      drag: function(e, ui) {
        $e = $(this);
        $e2 = $("img[id^='waveform_']").not($e);
        // Reset the other track if it is moved when another moves
        if ($e2.length > 0 && $e2.position().left > 0) {
          $e2.css("left", "0px");
          mix.setDuration($e2);
        }
        // Limit scrolling too far right
        if (ui.position.left > ($e.parent().width()-10)) {
          ui.position.left = 0;
          return false;
        }
        // Limit dragging too far left
        /*if (ui.position.left < (eWidth - (eWidth * 2)) + 150) {
          ui.position.left = (eWidth - (eWidth * 2)) + 150;
          return false;
        }*/
        if (ui.position.left < 0) {
          ui.position.left = 0;
          return false;
        }
        mix.setDuration($e);
      },
      stop: function(e, ui) {
        $e = $(this);
        $e2 = $("img[id^='waveform_']").not($e);
        $e.animate({
          opacity: 1
        }, 200);
        
        $.each([$e, $e2], function(index, value) {
          mix.setDuration(value);
        })
      }
    });
  });
  
 
  $("body").on("mouseenter", "#mixer .jingle .track-img", function() {
    $(this).children(".jingle-desc").fadeOut(200);
  }).on("mouseleave", "#mixer .jingle .track-img", function() {
    $(this).children(".jingle-desc").fadeIn(200);
  });
  
  
  // Initialize all tracks and attach jPlayer objects to them
  $("#mixer .panel .panel-body").children("div[id^='track_']").each(function(index, value) {
    mix.attachJPlayerObjects(index, value);
  });
  
  
  // Play and pause audio in the mixer
  $("body").on('click', '.track-play', function(e) {
    e.preventDefault();
    if (($tracks[1] != undefined && ($tracks[0].data().jPlayer.status.paused && $tracks[1].data().jPlayer.status.paused)) ||
        ($tracks[1] == undefined && $tracks[0].data().jPlayer.status.paused)) {
      mix.trigger('play');
    } else {
      mix.trigger('stop');
    }
  });
  
  
  // Typing in the track mixer description form
  $("body").on("keyup", "#jingle_desc_mixer", function() {
    if ($("#jingle_desc_mixer").val() != "") {
      $("#merge-submit-button").removeClass("disabled");
    } else {
      $("#merge-submit-button").addClass("disabled");
    }
  });
  
  // Clicking the button to view the track mixer
  $("#view-track-mixer-button").on("click", function(e) {
    if ($track_mixer.children(".jingle").length < parseInt($track_mixer.attr("data-max"))) {
      e.preventDefault();
      renderGrowl($(this).data().error, "danger");
    }
  });
  
  // Remove a track from sidebar mixer
  $("body").on("ajax:success", ".track-delete", function(xhr, data, status) {
    $(this).parent().fadeOut().remove();
  });
  
  // Remove a track from mixer
  $("body").on("ajax:success", ".track-mixer-delete", function(xhr, data, status) {
    id = $(this).attr("data-index");
    $tracks[id].remove();
    $(".track_"+id).fadeOut();
    delete $tracks[id]; // Remove the track object itself
  });

}