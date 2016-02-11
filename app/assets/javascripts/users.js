$(document).ready(initialize_users_js);
//$(document).on('page:load', initialize_users_js);

function initialize_users_js() {
  
  $('#user_avatar').fileupload({
    url: $('#user_avatar').attr("data-target"),
    method: 'post',
    dataType: 'json',
    done: function (e, data) {
      file = $.parseJSON(data.jqXHR.responseText);
      $("#progress").hide();
      $("#successful-avatar-upload").show();
      //$(".fileinput-button").remove();
      var url_test = file[0].url;
      $("#user_avatar_img").attr("src", url_test).hide().fadeIn("slow");
      $("#main-header-avatar-img").attr("src", url_test).hide().fadeIn("slow");
      //generateMessageBox($($(this).attr("data-errorbox")), file[0].status, "success");
      renderGrowl(file[0].status, "success");
    },
    progressall: function (e, data) {
      $("#progress").show();
      var progress = parseInt(data.loaded / data.total * 100, 10);
      $('#progress .progress-bar').css('width', progress + '%');
    }
  });
  
  $("body").on("change", ".submit-notification-settings", function() {
    $("#notification_settings").submit();
  });
  
}