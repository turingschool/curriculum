$(function() {

  var JSLSidebar = function() { 

    $("#content").css('margin-right','240px');
    $("#content div:first").css('border-right','1px solid #E0E0E0');

    function addToggler() {
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

    function positionContentWithinWindow(topSection,topPosition) {

      var y = $(window).scrollTop();

      if (y >= topPosition) {
        topSection.addClass('fixed');

        if (topSection.height() > $(window).height()) {
          var contentDifference = $(window).height() - topSection.height() + (y - topPosition);
          if (contentDifference > 40) { contentDifference = 20; }
          topSection.css('bottom',contentDifference);
        } else {
          topSection.css('bottom','');
          topSection.css('top','20');
        }

      } else {
        topSection.removeClass('fixed');
      }

    }
    
    function enableContentToFollowWithWindowScrollAndResize() {

      var topSection = $("aside.sidebarn div:first");
      var topPosition = topSection.offset().top - parseFloat(topSection.css('margin-top').replace(/auto/, 0));

      $(window).scroll(function(event) {
        positionContentWithinWindow(topSection,topPosition);
      });

      $(window).resize(function(event) {
        positionContentWithinWindow(topSection,topPosition);
      });

    }

    function populateWithContent() {
      generateLinksForContent("aside.sidebarn div:first","article header");
      generateLinksForContent("aside.sidebarn div:first","#content article h2");
    }

    function generateLinksForContent(targetSelector,contentSelector) {

      var contentItemTarget = $(targetSelector);

      $(contentSelector).each(function(index,headerItem) {

        var contentItem = $(headerItem);
        var contentItemSlug = contentItem.text().trim().toLowerCase().replace(/\s/g,'-');

        var anchorName = "<a name='" + contentItemSlug + "' />";
        $(anchorName).insertBefore(contentItem);

        var contentAnchorLink = "<section><h3><a href='#" + contentItemSlug + "'>" + contentItem.text().trim() + "</h3></a></section>";

        contentItemTarget.append(contentAnchorLink);

      });

    }

    addToggler();
    enableContentToFollowWithWindowScrollAndResize();
    populateWithContent();
  }

  var sidebar = new JSLSidebar();

})
