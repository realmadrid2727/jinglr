/*
 * Copyright? Nope!
 * Author: Orlando de Frias
 * https://github.com/realmadrid2727/jquery.lilCharacterCount
 * Version: 2.4.0
 * Date: September 24, 2013
 */
 
(function($) {
  $.fn.lilCharacterCount = function() {
    var supportOnInput = 'oninput' in document.createElement('input');
    var $this = $(this);
    var maxLength = parseInt($this.attr('maxlength'));
    var $counter = $("<span class=\"character-count label bg-success\">" + maxLength + "</span>");
    $counter.insertAfter($this);
    
    $this.on(supportOnInput ? 'input' : 'keyup', function() {
      var cc = $this.val().length;
      
      $counter.text(maxLength - cc);
      if(maxLength <= cc) {
        $counter.addClass("bg-danger");
      } else {
        $counter.removeClass("bg-danger");
        $(".error_message").html("");
      }
      if ($("#id").val()) {
        if(cc > 0 && $("#id").val().length > 0) {
          $("#submit-jingle-button").removeClass("disabled");
          $(".modal-submit").removeClass("disabled");
        } else {
          $("#submit-jingle-button").addClass("disabled");
          $(".modal-submit").addClass("disabled");
        }
      }
    });
  }
}(jQuery));