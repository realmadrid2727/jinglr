$(document).ready(function() {
  initialize_registrations_js();
});

function initialize_registrations_js() {
  // Check email typed into registration form and offer suggestions
  $('#user_email').on('blur', function() {
    $(this).mailcheck({
      suggested: function(element, suggestion) {
        $(".email-suggestion").remove();
        element.parent().append("<div class='email-suggestion'>"+
          element.data().suggest+
          "<span class='text-danger'><strong id='suggestion'>"+
          suggestion.full+
          "</strong></span>?</div>")
        $(".email-suggestion").hide().fadeIn(300);
      },
      empty: function(element) {
        // callback code
      }
    });
  });
  
  $("#user_username.register-user").on('blur', function() {
    $.ajax({
      url: "/username_check",
      context: document.body,
      data: "username="+$(this).val(),
      dataType: "json",
      type: "GET",
      global: false
    }).success(function(e) {
      //console.log(e.username_exists);
      $("#username_check").addClass("bg-success");
      $("#username_check").removeClass("bg-danger");
    }).error(function(e) {
      $("#username_check").addClass("bg-danger");
      $("#username_check").removeClass("bg-success");
    });
  })
  
  $("body").on("click", ".email-suggestion", function() {
    $("#user_email").val($("#suggestion").html());
    $(this).remove();
  });
}