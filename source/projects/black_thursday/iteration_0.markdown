# Iteration 0 - Merchants & Items

The goal of this iteration is to get the ball rolling by focusing on a "Data Access Layer" for multiple CSV files.

## Data Access Layer

The idea of a *DAL* is to write classes which load and parse your raw data, allowing your system to then interact with rich ruby objects to do more complex analysis. In this iteration we'll build the beginnings of a DAL by building the classes described below:

### `SalesEngine`

Then let's tie everything together with one common root, a `SalesEngine` instance:

```ruby
se = SalesEngine.from_csv({
  :items     => "./data/items.csv",
  :merchants => "./data/merchants.csv",
})
```

From there we can find the child instances:

* `items` returns an instance of `ItemRepository` with all the item instances loaded
* `merchants` returns an instance of `MerchantRepository` with all the merchant instances loaded

### `MerchantRepository`

The `MerchantRepository` is responsible for holding and searching our `Merchant`
instances. It offers the following methods:

* `all` - returns an array of all known `Merchant` instances
* `find_by_id` - returns either `nil` or an instance of `Merchant` with a matching ID
* `find_by_name` - returns either `nil` or an instance of `Merchant` having done a *case insensitive* search
* `find_all_by_name` - returns either `[]` or one or more matches which contain the supplied name fragment, *case insensitive*

The data can be found in `data/merchants.csv` so the instance is created and used like this:

```ruby
se = SalesEngine.from_csv({
  :items     => "./data/items.csv",
  :merchants => "./data/merchants.csv",
})

mr = se.merchants
merchant = mr.find_by_name("CJsDecor")
# => <Merchant>
```

### `Merchant`

The merchant is one of the critical concepts in our data hierarchy.

* `id` - returns the integer id of the merchant
* `name` - returns the name of the merchant

We create an instance like this:

```ruby
m = Merchant.new({:id => 5, :name => "Turing School"})
```

### `ItemRepository`

The `ItemRepository` is responsible for holding and searching our `Item`
instances. This object represents one line of data from the file `items.csv`.

It offers the following methods:

* `all` - returns an array of all known `Item` instances
* `find_by_id` - returns either `nil` or an instance of `Item` with a matching ID
* `find_by_name` - returns either `nil` or an instance of `Item` having done a *case insensitive* search
* `find_all_with_description` - returns either `[]` or instances of `Item` where the supplied string appears in the item description (case insensitive)
* `find_all_by_price` - returns either `[]` or instances of `Item` where the supplied price exactly matches
* `find_all_by_price_in_range` - returns either `[]` or instances of `Item` where the supplied price is in the supplied range (a single Ruby `range` instance is passed in)
* `find_all_by_merchant_id` - returns either `[]` or instances of `Item` where the supplied merchant ID matches that supplied

It's initialized and used like this:

```ruby
se = SalesEngine.from_csv({
  :items     => "./data/items.csv",
  :merchants => "./data/merchants.csv"
})

ir   = se.items
item = ir.find_by_name("Item Repellat Dolorum")
# => <Item>
```

### `Item`

The Item instance offers the following methods:

* `id` - returns the integer id of the item
* `name` - returns the name of the item
* `description` - returns the description of the item
* `unit_price` - returns the price of the item formatted as a `BigDecimal`
* `created_at` - returns a `Time` instance for the date the item was first created
* `updated_at` - returns a `Time` instance for the date the item was last modified
* `merchant_id` - returns the integer merchant id of the item

It also offers the following method:

* `unit_price_to_dollars` - returns the price of the item in dollars formatted as a `Float` 

We create an instance like this:

```ruby
i = Item.new({
  :name        => "Pencil",
  :description => "You can use it to write things",
  :unit_price  => BigDecimal.new(10.99,4),
  :created_at  => Time.now,
  :updated_at  => Time.now,
  :merchant_id => "1234",
  :id => "4567"
})
```
