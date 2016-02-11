$(document).ready(initialize_followers_js);
//$(document).on('page:load', initialize_followers_js);

function initialize_followers_js() {
  // Following someone
  $('.follow-submit-ajax').on("ajax:success", function(evt, data, status, xhr){
    follow_counter = $(".follows_count_"+$(this).attr("data-user"));
    follow_counter.html(xhr.responseText);
  });
  
}