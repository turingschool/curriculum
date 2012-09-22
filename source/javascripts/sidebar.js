$(function() {

  var JSLSidebar = function() { 
    
    $("#content").css('margin-right','240px');
    $("#content div:first").css('border-right','1px solid #E0E0E0');
    
    function _addToggler() {
      $('.toggle-sidebarn').bind('click', function(e) {
        e.preventDefault();
        if ($('body').hasClass('collapse-sidebarn')) {
          $("#content").css('margin-right','240px');
          $('body').removeClass('collapse-sidebarn');
          
        } else {
          $("#content").css('margin-right','20px');
          $('body').addClass('collapse-sidebarn');
        }
      });

      var sections = $('aside.sidebarn > section');
      if (sections.length > 1) {
        sections.each(function(section, index){
          if ((sections.length >= 3) && index % 3 === 0) {
            $(section).addClass("first");
          }
          var count = ((index +1) % 2) ? "odd" : "even";
          $(section).addClass(count);
        });
      }
      if (sections.length >= 3){ $('aside.sidebarn').addClass('thirds'); }
    }
    
    function _followingContent() {
      
      var topSection = $("aside.sidebarn div:first");
  
      var topPosition = topSection.offset().top - parseFloat(topSection.css('margin-top').replace(/auto/, 0));
  
      $(window).scroll(function(event) {
        var y = $(this).scrollTop();

        if (y >= topPosition) {
          topSection.addClass('fixed');
      
          if (topSection.height() > $(this).height()) {
            var contentDifference = $(this).height() - topSection.height() + (y - topPosition)
            if (contentDifference > 40) { contentDifference = 20; }
      
            topSection.css('bottom',contentDifference)
          } else {
            topSection.css('top','20')
          }
      
        } else {
          topSection.removeClass('fixed')
        }
        
      });
      
    }
  
    _addToggler();
    _followingContent();
    
  }

  var sidebar = new JSLSidebar();

})