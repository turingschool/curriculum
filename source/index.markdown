---
layout: page
title: Tutorials
---

<div id="search">
  <form action="/search" method="get">
    <input type="text" id="search-query" name="q" placeholder="Search" autocomplete="off">
  </form>
</div>

<section id="search-results" style="display: none;">
  <p>Search results</p>
  <div class="entries">
  </div>
</section>

{% raw %}
<script id="search-results-template" type="text/mustache">
  {{#entries}}
    <article>
      <h3>
        {{#date}}<small><time datetime="{{pubdate}}" pubdate>{{displaydate}}</time></small>{{/date}}
        <a href="{{url}}">{{title}}</a>
      </h3>
    </article>
  {{/entries}}
</script>
{% endraw %}

<script type="text/javascript">
  $(function() {
    $('#search-query').lunrSearch({
      indexUrl: '/search.json',             // URL of the `search.json` index data for your site
      results:  '#search-results',          // jQuery selector for the search results container
      entries:  '.entries',                 // jQuery selector for the element to contain the results list, must be a child of the results element above.
      template: '#search-results-template'  // jQuery selector for the Mustache.js template
    });
  });
</script>

{% section projects/ruby.markdown /images/ruby.png Ruby and Rails %}
{% section projects/javascript/index.markdown /images/js.png JavaScript %}
{% section projects/arduino/index.markdown /images/arduino.png Arduino & Dino %}
{% section projects/gschool.markdown /images/gschool.jpg gSchool %}
{% section academy/workshops/index.markdown /images/hungry-academy.png Workshops %}
{% section reading/index.markdown /images/hungry-academy.png Reading %}

