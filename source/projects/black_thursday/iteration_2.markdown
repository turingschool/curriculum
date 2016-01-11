# I2: Basic Invoices

Now we'll begin to move a little faster. Let's work with invoices and build up the data access layer, relationships, and business intelligence in one iteration.

## Data Access Layer

### `InvoiceRepository`

### `Invoice`

id,customer_id,merchant_id,status,created_at,updated_at

## Relationships

```ruby
se = SalesEngine.new
se.load_data({
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

### How many invoices does the average merchant have?

### Who are our top performing merchants?

### Who are our lowest performing merchants?

### Which days of the week see the most sales?

### What percentage of invoices are not shipped?
