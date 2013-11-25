---
---
var docs =
[
{% for page in site.pages limit:10 %}
  {% include post.json %},
{% endfor %}
];
// init lunr
var idx = lunr(function () {
  this.field('title', 10);
  this.field('content');
})
// add each document to be index
for(var index in docs) {
  idx.add(docs[index]);
}

$(function() {
  $("#search button").click(function() {
    search();
  });

  $("#search input").keypress(function(e) {
    if(e.which == 13) {
      e.preventDefault();
      search();
    }
  });
})

function search() {
  var result = idx.search($("#search input").val());
  if(result && result.length > 0) {
    window.location.replace(result[0].ref);
  } else {
    alert("Found Nothing");
  }
}