  /*$.Isotope.prototype._getMasonryGutterColumns = function() {
    var gutter = this.options.masonry && this.options.masonry.gutterWidth || 0;
    containerWidth = this.element.width();

    this.masonry.columnWidth = this.options.masonry && this.options.masonry.columnWidth ||
    // or use the size of the first item
    this.$filteredAtoms.outerWidth(true) ||
    // if there's no items, use size of container
    containerWidth;

    this.masonry.columnWidth += gutter;

    this.masonry.cols = Math.floor((containerWidth + gutter) / this.masonry.columnWidth);
    this.masonry.cols = Math.max(this.masonry.cols, 1);
  };

  $.Isotope.prototype._masonryReset = function() {
    // layout-specific props
    this.masonry = {};
    // FIXME shouldn't have to call this again
    this._getMasonryGutterColumns();
    var i = this.masonry.cols;
    this.masonry.colYs = [];
    while (i--) {
        this.masonry.colYs.push(0);
    }
  };

  $.Isotope.prototype._masonryResizeChanged = function() {
    var prevSegments = this.masonry.cols;
    // update cols/rows
    this._getMasonryGutterColumns();
    // return if updated cols/rows is not equal to previous
    return (this.masonry.cols !== prevSegments);
  };

  $('#grid').isotope({
    itemSelector: '.jingle',
    animate: true,
    masonry: {
      columnWidth: function( containerWidth ) {
 
				// do nothing for browsers with no media query support
				// .container will always be 940px
				if($("section.scrollable.wrapper").width() == 940) {
					return 240;
				}	
 
				var width = $(window).width();
				var col = 300;
 
				if(width < 1200 && width >= 980) {
					col = 240;
				}
				else if(width < 980 && width >= 768) {
					col = 186;
				}
 
				return col;
			},
			gutterWidth: 10
		}
  });*/
  
  /* This looks gangsta, but simply calling reLayout on the isotope object isn't enough.
     The problem is, when the click event fires, the new height of the element isn't
     available yet. Instead, the old height is. So you'd have to click twice. Here, I'm
     just waiting a little bit before triggering the reLayout. */
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
  
  
  ////////