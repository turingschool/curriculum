---
layout: page
title: JSCart
---

No Javascript tutorial would be complete without some kind of shopping cart. JSCart to the rescue!  In this project we'll build a one page store/cart where customers can add items to the cart and watch the *MAGIC* as it updates on the fly.

### 1. HTML and Styles

In this project we're going to insert significant content dynamically into the HTML.  Didn't I previously say that was a bad idea?  Kinda.  Sometimes it makes sense.  Maybe you're loading the content from another website, maybe you want to keep most of the HTML static for caching and just update some parts with Javascript.  There are times it makes sense, so let's try it.

That'll leave us with a very barebones HTML file:

```html
<!doctype html>
<html>
  <head>
    <meta charset="UTF-8" />
    <title>JSCart</title>
    <link rel='stylesheet' type="text/css" href='styles.css'/>
    <script src="//ajax.googleapis.com/ajax/libs/jquery/1.8.1/jquery.min.js"></script>
    <script src="data.js"></script>
    <script src="application.js"></script>
  </head>
  <body>
    <h1>Balloon-Animals-R-Us</h1>
    <div id="cart">
      <div class='totals'>
        <p><span id='cart_quantity'>0</span> items in cart</p>
        <p>$<span id='cart_price'>0</span> total</p>
      </div>
    </div>
    <div id="inventory">
    </div>
  </body>
</html>
```

Note that our head now includes a `data.js` file.  For our example we're going to type our inventory data right into `data.js`, but when doing it "for real" this file could retrieve the data from anywhere (a file, database, the web, etc).

Create an `application.js` file and just start it with the document ready wrapper:

```javascript
$(function(){

});
```

The create a `styles.css` and paste in this style code:

```css
html{
  font-family: 'Gill Sans Light', 'Helvetica', 'Arial';
  font-size: 90%;
}

body{
  width: 700px;
}

div#cart, div#inventory{
  height: 320px;
  border: 5px solid #999;
  background: #F0F0F0;
  -moz-border-radius: 10px;
  -webkit-border-radius: 10px;
  border-radius: 10px;
  padding: 10px;
}

div#cart{
  width: 160px;
  float: right;
}

div#inventory{
  width: 430px;
}

div.item{
  height: 120px;
  width: 120px;
  border: 1px solid #EEE;
  background: #FFF;
  -moz-border-radius: 5px;
  -webkit-border-radius: 5px;
  border-radius: 5px;
  display: block;
  float: left;
  margin: 5px;
  padding: 5px;
}

div.item h3{
  margin: 0px;
  padding: 0px 0px 10px 0px;
}

div.item ul{
  list-style-type: none;
  margin: 0px;
  padding: 0px;
}

div.item ul li{
  margin: 0px 0px 3px 0px;
}

div#cart h3{
  display: inline;
  font-size: 14px;

}
```

Load the page in your browser and you won't see much!  It'll just be a header and an empty cart.

### 2. Loading External Data

We're going to store the inventory information in `data.js` and keep it really simple.  We'll just store them in a Javascript array where each element of the array is one product.  The products themselves are stored using the "Object Literal Notation" which we saw in JSTasker.  Feel free to makeup your own products and values, but match the names of the attributes:

```javascript
var raw_inventory = [
  { "price":4.99, "name":"Monkey", "stock":5, "product_id":1 },
  { "price":4.99, "name":"Dog",    "stock":4, "product_id":2 },
  { "price":6.99, "name":"Cat",    "stock":3, "product_id":3 },
  { "price":5.99, "name":"Sword",  "stock":2, "product_id":4 },
  { "price":7.99, "name":"Hat",    "stock":1, "product_id":5 }
]
```

Javascript knows it's an array because of the `[` and `]`.  Each object in the array is marked with `{` and `}`. Then inside the objects there are key/value pairs for the keys price, name, stock, and product_id.

#### Loading the Data

Go over to your `application.js`.  Let's prove that `inventory` exists by putting this inside your document ready block:

```javascript
var inventory = $(raw_inventory);
alert("There are " + inventory.length() + " products in the inventory.");
```

We're taking the `raw_inventory` data and turning it into a jQuery object so it's easier to work with, then storing that into `inventory`.  Then we alert the size of that object which should display 5.  If that works then we know the data is loaded and accessible!

#### Building a Prototype

Now it's going to get interesting.  We're creating content on the fly, but it's still wrong to have a lot of HTML in your Javascript.  What can we do?

Let's try putting a template into our HTML.  It'll have the "shape" of an inventory item, it just won't have any data.  Then from Javascript we can find that prototype, make copies of it, fill in the data, and inject those copies into the actual HTML.  Go over to your `index.html` and add this prototype inside the inventory DIV:

```html
<div class='item' id="prototype_item" >
  <h3></h3>
  <ul>
    <li>Price: <span class="price"></span></li>
    <li>Qty: <span class="qty"></span></li>
    <li><a href='#'>Add to Cart</a></li>
  </ul>
</div>
```

Refresh your browser and you'll see a blank item show up.  Next let's find this prototype from the Javascript.  Inside your document ready block of `application.js`, try this:

```javascript
var prototype_item = $('#prototype_item');
prototype_item.detach();
```

Refresh your browser and the blank inventory item is gone.  We've got it loaded into `prototype_item`, so now we can create our actual product listings.

#### Building Products from the Prototype

We've got the `prototype_item`, we've got the `inventory`, now we need to iterate through the inventory and inject a copy of the prototype into our listing for each one.  That's complex, so let's do it one step at a time.

Add this `each` method call inside your document ready:

```javascript
inventory.each(function(){
   alert("Inserting " + this.name);
});
```

Inside the `each` block, `this` refers to the OLN object inside of `inventory`.  We can access the attributes using a dot notation like `this.name`.  Try this in your browser and ensure each of your items is alerted.

The first step is to create a copy or a `clone` of the `prototype_item`.  Add this inside your `each` block:

```javascript
var item = prototype_item.clone();
```

That creates a "deep clone" of `prototype_item`.  Let's set the first attribute:

```javascript
item.find('h3').text(this.name);
```

Within the object `item`, find any H3s and replace their `text` with the value of `this.name`.  Then insert it into the inventory DIV:

```javascript
$('#inventory').append(item);
```

Refresh your browser and your items should all appear.  They'll have names, but the other attributes are blank.

*On your own*, add more Javascript instructions to set the price and quantity.  We still have to figure out the add to cart link, but that's the next iteration.

One thing you'll want to change is the item's DIV id.  Use the `attr` method to set it to a unique id like "product_6" for each item.  The `attr` method takes two parameters: the name of the attribute to change and the value to change it to.  The attribute you want to change is just `"id"`.

Once you're setting the name, price, quantity, id and displaying them in the inventory, then this iteration is done.

### 3. Adding Items to the Cart

Those "Add to Cart" links are mocking us.  They don't do anything!

We need to add a `click` listener.  Each link will need it's own listener, so it's easiest to add it within your `inventory.each` loop.  Start with this:

```javascript
item.on('click', function () {
  alert("Adding " + this.name + " to the cart." );
});
```

Try it in your browser.  What's up with that "undefined"?  `this` isn't what we think it is.  When the function actually gets executed, `this` refers to the item's DIV, not the data we pulled out of the `inventory` array.  Hmmm.  What can we do with that?  Try changing you `alert` to this:

```javascript
alert("Adding " + $(this).attr('id') + " to the cart." );
```

Try it in the browser.  Looks promising, right?  That's pulling the id that we set which holds the product id from the data array.  Our cart could use that information to find the item in the inventory, get its price, etc.

#### Building Up the Cart

It looks like we can get enough information when the "Add to Cart" link is clicked, but what are we going to do with it?  The cart is basically a blank DIV right now.  Let's set it up like a spreadsheet where each inventory item has a row and a quantity ordered.

We can use the same prototype style we did for the inventory listings.  Add this plain HTML into your cart DIV:

```html
<div class='cart_item' id='prototype_cart'>
  <h3></h3>
  <span class='qty'>0</span>
  $<span class='price'></span>
</div>
```

Go back to your `application.js` and look at how we worked with `prototype_item`.  Add a similar set of instructions to build up `cart_item` and `append` it to the cart DIV.  Refresh your browser and make sure a line shows up for each of your products.

#### Connecting the Click to the Cart

Now we need to connect the click action to the cart.  When a user clicks on an add to cart link we need to...

1. Find the link's DIV's ID
1. Find the DIV in the cart with the same ID
1. Increment the quantity in the cart item

Currently our `alert` line finds the proper `id` value.  Let's store that into a variable named `target_id`.  Then find the actual target DIV in the cart like this:

```javascript
var target = $('div#cart div#' + target_id);
```

Then the only thing left is to properly update the quantity.  That math is a little tricky, so let's take a smaller step:

```javascript
target.find('span.qty').text('ME!');
```

Refresh your browser and click the Add to Cart links.  You should see the associated cart quantity change from `0` to `ME!`.

#### Dealing with Strings and Numbers

Our cart quantity is just a string.  We want to increase it by one when the user clicks, but if we add a 1 to the contents of quantity it'll just add strings resulting in "111" instead of "3".  We need to...

1. Find the current value in QTY
1. Convert it to an integer
1. Add one to it
1. Store it back into QTY

Let's first find the SPAN itself and store that into a variable:

```javascript
var quantity = target.find('span.qty');
```

We can pull out the `.text()` to get the string number then use Javascript's `parseInt` method to convert it to an integer:

```javascript
var current = parseInt(quantity.text());
```

From there it's just one more line to add `1` to `current` and stick it back into `quantity` -- you figure it out.

Then refresh your browser, click some links, and your cart quantities should increase numerically.

### 4. Cart Math

We're plunking items into the cart.  Let's add a little more intelligence there to update the total items count and give the user a total price.

#### Prefactoring

I thought I just made up the word prefactoring, but [Wikipedia says that it exists](http://en.wikipedia.org/wiki/Prefactoring).

Let's apply the same pattern we used in JSTasker to group methods into a name space.  I want to collect a few methods that will be responsible for tending the cart, just like we did with the To-Do list.  Up at the top of your `application.js`, let's start with this:

```javascript
var JSCart = {
  update_cart_item_count : function () {},
  update_cart_total : function () {},
  update_cart : function () {
    this.update_cart_item_count();
    this.update_cart_total();
  }
};
```

Again we're using the "Object Literal Notation" here to namespace three methods.  We'll call `update_cart` from our click instruction, and it'll call `update_cart_item_count` and `update_cart_total` for us.

#### Calling the Updaters

Let's start by inserting an `alert` line within `update_cart` that says "Updating the cart", one in `update_cart_item_count` that says "Updating the item count", and one in the `update_cart_total` that says "Updating the total".

Refresh your browser and nothing should happen.  Why do I bother with putting in these `alerts` and checking things?  I believe in "Fail Early, Fail Often".  I'm not very smart, I make mistakes (especially in Javascript), and throwing in a few alerts lets me know that things are or aren't on the right track.  If, for instance, you forgot to declare the anonymous function for `update_cart` and instead just put instructions, your script would either fail to load OR it'd execute the `alert` as soon as it was read (when the page was loaded).  This would be quick clue that something was wrong.

But our methods aren't getting called yet which is correct.  Go down you `application.js` and find the `item.on('click'...)` listener.  As the last instruction there, add a call to `JSCart.update_cart()`.

Refresh your browser, click an add to cart link, and the three alerts should pop up.  If you're satisfied that things are wired together properly, remove the three alert lines.

#### Writing the `update_cart_item_count` Function

Our `update_cart_item_count` function should now be blank.  Here's what we need it to do:

1. Find all the items in the cart
1. Gather the quantities specified for each one
1. Add them together
1. Save the result into the text span "X items in cart"

##### Finding the Items

Each item type has it's own DIV with the class name "cart_item".  Write a selector that finds them all and stores them into a variable named `items`.

Try popping an alert that tells you how many items there are.  It should be the same as your number of products in the inventory.

##### Gathering the Quantities

We'll need to iterate through the list of items, detect their `"qty"` SPAN, get it's contents, convert it to an integer, then add that to the total.  Here's the basic structure:

```javascript
var items = $('#cart div.cart_item');
var total = 0;
items.each(function (){
  // here do some magic to create a variable named value with the qty number
  total += value;
});
```

##### Storing the Value

Then you just need to find the SPAN with ID `'cart_quantity'` and store `total` into it's `text`.

Refresh your browser and confirm that things are working.  Make sure your count is accurate!

#### Writing the `update_cart_total` Function

Having completed the `update_cart_item_count`, it becomes apparent that we're currently setup to do things twice.  The `update_cart_total` function needs to do almost the same thing.  The only difference is that instead of adding the quantity into total we want to multiply quantity times price and add that.

Refactoring necessary? Probably.  But let's do it the simple way first.  Copy & Paste!  Grab the body of `update_cart_item_count` and paste it into `update_cart_total` count.  Then we need to make a few changes:

1. Now `value` feels like the wrong name, rename it to `quantity`
1. After `quantity` is found, find `price`
1. Multiply `quantity` times `price` to make `subtotal`
1. Add `subtotal` to `total`
1. Change the text inserter to put `total` into the SPAN with ID `'cart_price'`

I think you can do this on your own, go to it!  One little note: when you pull out the price string and want to convert it to a number, use `parseFloat` so the cents don't get truncated.

##### I Hate Floats

Dealing with floating point numbers is always a pain.  At least in my experimenting, every once in awhile my total would jump to having really small fractions after the decimal.  Ugh!  In general, when working with prices, I recommend you store prices in cents so you can use integers.  But let's just leave these as floats and fix this presentation issue.

Find the line where you're inserting `total` into the `cart_quantity` SPAN.  Instead of just inserting `total`, use the Javascript native method `toFixed` like this: `total.toFixed(2)`.

### Extensions

This project, like most shopping carts, could go a hundred directions.  Here are some ideas to try adding on:

* Add a clickable link that clears the cart
* Add a keyboard shortcut that clears the cart
* Alphabetize the items in the inventory
* Decrease the number of items in inventory when they're added to the cart
* When stock is low, change the listing to say "Only X Left!"
* When an item is out of stock, grey out or remove it from the inventory
* Prevent the cart from having more of an item than are in stock
* Add a link to remove individual items from the cart
* Change the cart to use a text field so the quantity could be easily manipulated and the totals updated
* Implement Drag & Drop so the items can be dragged and dropped in the cart

