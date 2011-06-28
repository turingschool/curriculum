h4. Fabrication

I've use a gem named *Fabrication* by our friend Paul Elliot. You can learn more about it here: "https://github.com/paulelliott/fabrication":https://github.com/paulelliott/fabrication

You can check out the fabrication definition in @/spec/fabricators/article_fabricator.rb@. The important take-aways are that you can use the following:

* @Fabricate(:article)@ to create a sample article
* @Fabricate(:article_with_comments)@ to create a sample article with three attached comments

All samples a pre-filled with "Lorem Ipsum" text to pass validations.

Try experimenting with them in the console!
