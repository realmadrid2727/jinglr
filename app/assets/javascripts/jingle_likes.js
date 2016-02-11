$(document).ready(initialize_jingle_likes_js);
//$(document).on('page:load', initialize_jingle_likes_js);

function initialize_jingle_likes_js() {
  // Liking a jingle
  $('.like-submit-ajax').on("ajax:success", function(evt, data, status, xhr){
    like_counter = $("#likes_count_"+$(this).attr("data-jingle"));
    like_counter.html(xhr.responseText);
  });
  
}