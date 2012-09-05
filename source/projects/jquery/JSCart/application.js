var JSCart = {
  update_cart_item_count : function () {
    var items = $('#cart div.cart_item');
    var total = 0;
    items.each(function (){
      var value = parseInt($(this).find("span.qty").text());
      total += value;
    });
    $('.totals span#cart_quantity').text(total);
  },
  update_cart_total : function () {
    var items = $('#cart div.cart_item');
    var total = 0;
    items.each(function (){
      var quantity = parseInt($(this).find("span.qty").text());
      var price = parseFloat($(this).find("span.price").text());
      total += quantity * price;
    });
    $('.totals span#cart_price').text(total.toFixed(2));
  },
  update_cart : function () {
    this.update_cart_item_count();
    this.update_cart_total();
  }
};

$(function(){
  var inventory = $(raw_inventory);
  var prototype_item = $('#prototype_item');
  prototype_item.detach();
  var prototype_cart = $('#prototype_cart');
  prototype_cart.detach();

  inventory.each(function(){
    var item = prototype_item.clone();
    item.find('h3').text(this.name);
    item.find('span.price').text(this.price);
    item.find('span.qty').text(this.stock);
    item.attr("id", "product_" + this.product_id);
    item.on('click', function () {
      var target_id = $(this).attr('id');
      var target = $('div#cart div#' + target_id);
      var quantity = target.find('span.qty');
      var current = parseInt(quantity.text());
      quantity.text(current + 1);
      JSCart.update_cart();
    });
    $('#inventory').append(item);

    var cart_item = prototype_cart.clone();
    cart_item.find('h3').text(this.name);
    cart_item.find('span.price').text(this.price);
    cart_item.find('span.qty').text('0');
    cart_item.attr("id", "product_" + this.product_id);
    $('#cart').append(cart_item);

  });
});

//  function update_total(){
//    var total = 0;
//    $("#cart .qty").each(function(){
//      //alert(this)
//      var quantity = parseInt($(this).html());
//      total = total + quantity;
//    });
//    $('#cart_quantity').html(total);
//  }
//
//  $(items).each(function(){
//    var name = this.name;
//    var price = this.price;
//    var link_id = "add_" + this.product_id;
//    var cart_id = "cart_" + this.product_id;
//
//    $(
//      "<div class='item'>" +
//      "<h3>" + name + "</h3>" +
//      "<ul><li>Price: " + price + "</li>" +
//      "<li>Qty: " + this.stock + "</li>" +
//      "<li class='add_link' id='" + link_id + "'>Add to Cart</li>" +
//      "</ul></div>"
//    ).appendTo("#inventory");
//
//    $(
//      "<div class='cart_item' id='" + cart_id + "'>" +
//      "<h3>" + name + ":</h3>" +
//      "<span class='qty'>0</span>" +
//      "$<span class='price'>" + price + "</span>" +
//      "</div>"
//    ).appendTo("#cart");
//
//    $("#" + link_id).on('click', function(){
//      var qty = $("#" + cart_id + " .qty");
//      var current = parseInt(qty.html());
//      qty.html(current + 1);
//      update_total();
//    });
//  });
