$(document).ready(initialize_notifications_js);
//$(document).on('page:load', initialize_notifications_js);

function initialize_notifications_js() {
  var $no_notifications = $("<div class='bg-light panel text-center m-n'><div class='panel-body'><i class='icon-ban-circle'></i></div></div>");
  var $num = $("#notifications_indicator_number");
  
  $('#notifications_indicator').click(function() {
    if ($(this).attr("data-necessary") == "true") {
      $.ajax({
        url: $(this).attr("data-href"),
        type: "PUT",
        context: document.body
      }).done(function() {
        $("#notifications_indicator_number").remove();
      });
    }
  });
  
  // Clicking the indicator icon to load the menu with ajax
  $("#notifications_indicator").on("click", function() {
    $(".notifications-bar").html("");
    $spinner.appendTo(".notifications-bar");
    $("<div>").load(this.href+"/remote", function() {
      $(".notifications-bar").html($(this).html());
      updateNotificationCount("refresh");
    });
  });
  
  // Bind success of marking a notification as viewed (from header)
  $("body").on("ajax:success", ".notifications-bar .notification_status", function() {
    target = $(this).attr("data-id");
    id = target.split("_")[1];
    previous_notification_path = $(".notifications-list").attr("data-prev");
    toggleNotificationReadStatus(true, id);
    // The toggling class script needs to be here because 
    // when you mark a notification as viewed from the header
    // it doesn't switch the checkmarks in the rest of the page
    var $toggle = $("#notification_page_status_"+id), $class , $target;
    if ($toggle.length > 0) {
      !$toggle.data('toggle') && ($toggle = $toggle.closest('[data-toggle^="class"]'));
      $class = $toggle.data()['toggle'].split(':')[1];
      $target = $( $toggle.data('target') );
      $target.toggleClass($class);
      $toggle.toggleClass('active');
    }
    $(this).hide(200);
    if (previous_notification_path != "0") {
      $("<div>").load(previous_notification_path, function() {
        $new_notification = $(".notifications-list").append($(this).html());
        $(".notifications-list").attr("data-prev", $($(this)[0].childNodes[0]).attr("data-prev"));
      });
    } else {
      if (num-1 == 0) {
        $(".notifications-list").append($no_notifications);
      }
    }
  });
  
  // Bind success of marking notification as viewed (from notifications page)
  $("body").on("ajax:success", "#notifications .notification_status", function(xhr, data, status) {
    target = $(this).attr("data-id");
    toggleNotificationReadStatus(data.viewed, target.split("_")[2]);
  });
  
  // Marking all items to view
  $("body").on("ajax:beforeSend", ".notifications-mark-all-viewed", function() {
    $spinner.appendTo(".notifications-list");
  }).on("ajax:success", ".notifications-mark-all-viewed", function() {
    $(".notifications-list").html($no_notifications);
    $num.html("").fadeOut(200);
    $spinner.fadeOut(200);
  });
  
  // Clicking a notification triggers its view
  $("body").on("click", ".notifications-bar a[id^='notification_']", function() {
    id = $(this).attr("id").split("_")[1];
    $("#notification_status_"+id).trigger("click");
  });
  
  // Clicking a notification triggers its view
  $("body").on("click", "#notifications a[id^='notification_link_']", function() {
    id = $(this).attr("id").split("_")[2];
    if ($("#notification_link_"+id).attr("data-viewed") == "false") {
      $("#notification_page_status_"+id).trigger("click");
    }
  });
  
  // Refreshing the notifications count indicator
  function updateNotificationCount(kind) {
    if (kind == "refresh") {
      num = parseInt($(".notifications-list").attr("data-count"));
      if (num > 0) {
        $num.css("display",""); // show() triggers inline display
        $num.html(num);
      }
    } else if (kind == "decrement") {
      num = parseInt($num.html());
      $num.html(num - 1);
      if (num-1 == 0) {
        $num.html("").fadeOut(200);
      }
    } else if (kind == "increment") {
      num = parseInt($num.html()) || 0;
      $num.css("display","");
      $num.html(num + 1);
    }
  }
  
  // Renders the viewed/unviewed notification classes
  function toggleNotificationReadStatus(state, id) {
    if (state) {
      $("#notification_page_"+id).switchClass("bg-white", "bg-light");
      $("#notification_"+id).hide(200);
      updateNotificationCount("decrement");
      $("#notification_link_"+id).attr("data-viewed", "true");
    } else {
      $("#notification_page_"+id).switchClass("bg-light", "bg-white");
      updateNotificationCount("increment");
      $("#notification_link_"+id).attr("data-viewed", "false");
    }
  }

}