# Iteration 1 - Starting Relationships and Business Intelligence

With the beginnings of a Data Access Layer in place we can begin building relationships between objects and derive some business intelligence.

## Starting the Relationships Layer

Merchants and Items are linked conceptually by the `merchant_id` in `Item` corresponding to the `id` in `Merchant`. Connect them in code to allow for the following interaction:

```ruby
se = SalesEngine.from_csv({
  :items     => "./data/items.csv",
  :merchants => "./data/merchants.csv",
})
merchant = se.merchants.find_by_id(10)
merchant.items
# => [<item>, <item>, <item>]
item = se.items.find_by_id(20)
item.merchant
# => <merchant>
```

## Starting the Analysis Layer

Our analysis will use the data and relationships to calculate information.

Who in the system will answer those questions? Assuming we have a `se` that's an instance of `SalesEngine` let's initialize a `SalesAnalyst` like this:

```ruby
sa = SalesAnalyst.new(se)
```

Then ask/answer these questions:

### How many products do merchants sell?

Do most of our merchants offer just a few items or do they represent a warehouse?

```ruby
sa.average_items_per_merchant # => 8.5
```

And what's the standard deviation?

```ruby
sa.average_items_per_merchant_standard_deviation # => 1.2
```

### Which merchants have the fewest items?

Maybe we could boost sales on the platform by encouraging merchants to list more items. Which merchants are more than one standard deviation below the average number of products offered?

```ruby
sa.merchants_with_low_item_count # => [merchant, merchant, merchant]
```

### What are prices like on our platform?

Are these merchants selling commodity or luxury goods? Let's find the average price of a merchant's items (by supplying the merchant ID):

```ruby
sa.average_item_price_for_merchant(6) # => BigDecimal
```

Then average that across all merchants:

```ruby
sa.average_price_per_merchant # => BigDecimal
```

### Which are our *Golden Items*?

Given that our platform is going to charge merchants based on their sales, expensive items are extra exciting to us. Which are our "Golden Items", those two standard-deviations above the average item price?

```ruby
sa.golden_items # => [item, item, item, item]
```
