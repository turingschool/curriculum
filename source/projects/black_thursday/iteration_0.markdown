# Iteration 0 - Merchants & Items

The goal of this iteration is to get the ball rolling by focusing on a "Data Access Layer" for multiple CSV files.

## Data Access Layer

The idea of a *DAL* is to write classes which load and parse your raw data, allowing your system to then interact with rich ruby objects to do more complex analysis. In this iteration we'll build the beginnings of a DAL by building the classes described below:

### `MerchantRepository`

The `MerchantRepository` is responsible for holding and searching our `Merchant`
instances. It offers the following methods:

* `find_by_name` - returns either `nil` or an instance of `District` having done a *case insensitive* search
* `find_all_by_name` - returns either `[]` or one or more matches which contain the supplied name fragment, *case insensitive*

The data can be found in `data/merchants.csv` so the instance is created and used like this:

```ruby
mr = MerchantRepository.new
mr.load_data("./data/merchants.csv")
merchant = mr.find_by_name("Halvorson Group")
# => <Merchant>
```

### `Merchant`

The merchant is one of the critical concepts in our data hierarchy. But it starts with just one method:

* `name` - returns the name of the merchant

We create an instance like this:

```ruby
m = Merchant.new({:name => "Turing School"})
```

### `ItemRepository`

The `ItemRepository` is responsible for holding and searching our `Item`
instances. This object represents one line of data from the file `items.csv`.

It offers the following methods:

* `find_by_name` - returns either `nil` or an instance of `Item` having done a *case insensitive* search
* `find_all_with_description` - returns either `[]` or instances of `Item` where the supplied string appears in the item description (case insensitive)
* `find_all_by_price` - returns either `[]` or instances of `Item` where the supplied price exactly matches
* `find_all_by_price_in_range` - returns either `[]` or instances of `Item` where the supplied price is in the supplied range (a single Ruby `range` instance is passed in)
* `find_all_by_merchant_id` - returns either `[]` or instances of `Item` where the supplied merchant ID matches that supplied

It's initialized and used like this:

```ruby
ir = ItemRepository.new
ir.load_data("./data/items.csv")
item = ir.find_by_name("Item Repellat Dolorum")
# => <Item>
```

### `Item`

The Item instance offers the following methods:

* `name` - returns the name of the item
* `description` - returns the description of the item
* `unit_price` - returns the price of the item formatted as a `BigDecimal`
* `created_on` - returns a `Date` instance for the date the item was first created
* `updated_on` - returns a `Date` instance for the date the item was last modified

We create an instance like this:

```ruby
i = Item.new({
              :name => "Pencil",
              :description => "You can use it to write things",
              :unit_price => BigDecimal.new(10.99,4),
              :created_on => Date.today,
              :updated_at => Time.now
            })
```
