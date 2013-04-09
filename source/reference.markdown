---
layout: page
title: Layout Verification for Printing
---

# H1

Lorem *ipsum* **dolor** `sit amet`, [consectetur](http://google.com) _adipiscing_ __elit__. In scelerisque volutpat volutpat.

> Etiam porta luctus odio vitae interdum. Curabitur sed augue lectus, ut auctor elit. Aliquam erat volutpat. Phasellus in diam eu dolor iaculis fringilla sed et nulla. Aliquam a ipsum orci, in consequat tellus.

Pellentesque orci lacus, porttitor a scelerisque nec, pharetra ut odio. In interdum volutpat varius. Donec interdum eros in lectus mollis nec suscipit diam tincidunt. Sed sagittis tincidunt tortor ut posuere. Etiam viverra rhoncus metus a ornare.

---

Sed id justo felis. Cras sit amet nisi ipsum, vel semper urna. Suspendisse tristique, tortor vitae dapibus porta, libero justo blandit urna, in sagittis metus lorem vestibulum tortor.

{% terminal %}
$ gem install rails
Fetching: i18n-0.6.1.gem (100%)
Fetching: multi_json-1.3.6.gem (100%)
Fetching: activesupport-3.2.8.gem (100%)
Fetching: builder-3.0.3.gem (100%)
Fetching: activemodel-3.2.8.gem (100%)
Fetching: rack-cache-1.2.gem (100%)
Fetching: rack-test-0.6.1.gem (100%)
...
{% endterminal %}

Aliquam a ipsum orci, in consequat tellus. Maecenas consequat tempus elit sit amet vulputate. Vestibulum in diam suscipit lorem feugiat dapibus at et nisi.

```ruby
class EventManager
  def initialize
    puts "EventManager Initialized."
    filename = "event_attendees.csv"
    @file = CSV.open(filename)
  end
end
```

Quisque urna ipsum, faucibus id imperdiet et, vehicula sit amet nunc:

{% irb %}
$ require './event_manager.rb'
$ EventManager.new
EventManager Initialized.
{% endirb %}

{% exercise %}

### Exercise

What do you think `a` equals?

What do you think `b` equals?

What do you think `c` equals?

### Bonus

What do you think second `b` equals?

{% endexercise %}

## H2

Suspendisse potenti. Phasellus nisl diam, pellentesque vitae lobortis a, accumsan vitae odio.

* Duis vestibulum hendrerit pretium. Pellentesque vestibulum placerat diam eu ultrices.
  * Donec mattis, augue eu aliquet auctor, risus turpis tristique velit, quis hendrerit est velit eget ligula.
* Aliquam consequat consequat dignissim. Nullam nulla ligula, feugiat non iaculis quis, tincidunt a turpis. Quisque urna ipsum, faucibus id imperdiet et, vehicula sit amet nunc.

    >  Etiam porta luctus odio vitae interdum. Curabitur sed augue lectus, ut auctor elit. Aliquam erat volutpat. Phasellus in diam eu dolor iaculis
    >
    > > fringilla sed et nulla. Aliquam a ipsum orci, in consequat tellus. Maecenas consequat tempus elit sit amet vulputate. Vestibulum in diam suscipit lorem feugiat dapibus at et nisi. Morbi a turpis nec risus vehicula gravida.

### H3

<div class="note">
<p>This document is used to determine quickly if the styles will be able to be viewed on the web correctly. This is also important before going to print.</p>
</div>

#### H4

![Image](/images/ruby.png)

Code samples from a file can be imported from a github respository.

{% codesample github JumpstartLab@blogger_advanced 2f96d94:app/models/article.rb %}

Creating a link to the download of a file based on a github repository tag (the tag below does not appear when printing).

{% archive JumpstartLab@blogger_advanced starting-point Download this Code! %}
This contains all the source code for all the steps up to this point.
{% endarchive %}