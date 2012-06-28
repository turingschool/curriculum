$(document).ready(function (){
    var back_to_top = "<a href='#top'>Back to Top</a>";
    $("div.article").append(back_to_top);

    var top_anchor = "<a name='top'/>";
    $("h1").append(top_anchor);

    var toc_header = "<h2><a name='toc'>Table of Contents</a></h2>";
    $("h1").after(toc_header);

    var toc_list = "<ul id='toc'></ul>";
    $("h2:first").after(toc_list);

    $("div.article h2").each(function (){
      var title = $(this).text();
      var slug = title.trim().toLowerCase().replace(" ", "_");
      var target_anchor = "<a name='" + slug + "'/>";
      $(this).before(target_anchor);
      var list_item = "<li><a href='#" + slug + "'>" + title + "</a></li>";
      $("ul#toc").append(list_item);

      var toggle_link = $("<a href='#'>(hide)</a>");

      toggle_link.click(function (event){
        event.preventDefault();
        $(this).siblings('p').toggle();

        var old_text = $(this).text();
        var new_text = (old_text == '(hide)') ? '(show)' : '(hide)'
        $(this).text(new_text);
      });

      $(this).after(toggle_link);
    });
});