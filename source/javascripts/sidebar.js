$(function() {

  var JSLSidebar = function() {

    var removeSidebarWhenWindowIsTooSmall = function(event) {
      if ( $(window).width() <= 768 ) {
        console.log("Removing Sidebar");
        $("#content").removeClass("sidebar-present");
        $("aside.sidebar").hide();
      } else {
        console.log("Displaying Sidebar");
        $("#content").addClass("sidebar-present");
        $("aside.sidebar").show();
      }

      $("#content").css('height',$("article").height());
    };

    window.onresize = removeSidebarWhenWindowIsTooSmall;
    removeSidebarWhenWindowIsTooSmall();

    function addToggler() {
      $('.toggle-sidebar').bind('click', function(e) {
        e.preventDefault();
        if ($('body').hasClass('collapse-sidebar')) {
          $("#content").css('margin-right','240px');
          $('body').removeClass('collapse-sidebar');

        } else {
          $("#content").css('margin-right','20px');
          $('body').addClass('collapse-sidebar');
        }
      });

      var sections = $('aside.sidebar > section');
      if (sections.length > 1) {
        sections.each(function(section, index){
          if ((sections.length >= 3) && index % 3 === 0) {
            $(section).addClass("first");
          }
          var count = ((index +1) % 2) ? "odd" : "even";
          $(section).addClass(count);
        });
      }
      if (sections.length >= 3){ $('aside.sidebar').addClass('thirds'); }
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
          topSection.css('top','0');
        }

      } else {
        topSection.removeClass('fixed');
      }

    }

    function highlightTheContentItemWhenInTheNeighorhood() {
      var distanceFromTop = $(window).scrollTop() + $(window).height() / 2;

      var itemIndex = 0;

      $("#content article h2").each(function(index,element) {
        var item = $(element)

        if (distanceFromTop > item.offset().top) {
          itemIndex = index;
        }
      });

      $("aside section").each(function(index,element) {
        $(element).css("background","");
      });

      $($("aside section")[itemIndex + 1]).css("background-color","rgba(0,0,0,0.1)");
    }

    function enableContentToFollowWithWindowScrollAndResize() {

      var topSection = $("aside.sidebar div:first");
      var topPosition = topSection.offset().top - parseFloat(topSection.css('margin-top').replace(/auto/, 0));

      $(window).scroll(function(event) {
        positionContentWithinWindow(topSection,topPosition);
        highlightTheContentItemWhenInTheNeighorhood();
      });

      $(window).resize(function(event) {
        positionContentWithinWindow(topSection,topPosition);
      });

    }

    function populateWithContent() {
      generateLinksForContent("aside.sidebar div:first","article header");
      generateLinksForContent("aside.sidebar div:first","#content article h2");
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
