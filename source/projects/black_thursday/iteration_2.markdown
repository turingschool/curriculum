# I2: Basic Invoices

Now we'll begin to move a little faster. Let's work with invoices and build up the data access layer, relationships, and business intelligence in one iteration.

## Data Access Layer

### `InvoiceRepository`

The `InvoiceRepository` is responsible for holding and searching our `Invoice`
instances. It offers the following methods:

* `all` - returns an array of all known `Invoice` instances
* `find_by_id` - returns either `nil` or an instance of `Invoice` with a matching ID
* `find_all_by_customer_id` - returns either `[]` or one or more matches which have a matching customer ID
* `find_all_by_merchant_id` - returns either `[]` or one or more matches which have a matching merchant ID
* `find_all_by_status` - returns either `[]` or one or more matches which have a matching status

The data can be found in `data/invoices.csv` so the instance is created and used like this:

```ruby
se = SalesEngine.from_csv({:invoices => "./data/invoices.csv"})
invoice = se.invoices.find_by_id(6)
# => <invoice>
```

### `Invoice`

The invoice has the following data accessible:

* `id` - returns the integer id
* `customer_id` - returns the customer id
* `merchant_id` - returns the merchant id
* `status` - returns the status
* `created_at` - returns a `Time` instance for the date the item was first created
* `updated_at` - returns a `Time` instance for the date the item was last modified

We create an instance like this:

```ruby
i = Invoice.new({
  :id          => 6,
  :customer_id => 7,
  :merchant_id => 8,
  :status      => "pending",
  :created_at  => Time.now,
  :updated_at  => Time.now,
})
```

## Relationships

Then connect our invoices to our merchants:

```ruby
se = SalesEngine.from_csv({
  :items => "./data/items.csv",
  :merchants => "./data/merchants.csv",
  :invoices => "./data/invoices.csv"
})
merchant = se.merchants.find_by_id(10)
merchant.invoices
# => [<invoice>, <invoice>, <invoice>]
invoice = se.invoices.find_by_id(20)
invoice.merchant
# => <merchant>
```

## Business Intelligence

Assume we're created `sa` as a `SalesAnalyst` instance:

### How many invoices does the average merchant have?

```ruby
sa.average_invoices_per_merchant # => 8.5
sa.average_invoices_per_merchant_standard_deviation # => 1.2
```

### Who are our top performing merchants?

Which merchants are more than two standard deviations *above* the mean?

```ruby
sa.top_merchants_by_invoice_count # => [merchant, merchant, merchant]
```

### Who are our lowest performing merchants?

Which merchants are more than two standard deviations *below* the mean?

```ruby
sa.bottom_merchants_by_invoice_count # => [merchant, merchant, merchant]
```

### Which days of the week see the most sales?

Which days are more than one standard deviations *above* the mean?

```ruby
sa.top_days_by_invoice_count # => ["Sunday", "Saturday"]
```

### What percentage of invoices are not shipped?

What percentage of invoices are `shipped` vs `pending`? (takes symbol as argument)

```ruby
sa.invoice_status(:pending) # => 5.25
sa.invoice_status(:shipped) # => 94.83
```
