# I3: Item Sales

We've got a good foundation, now it's time to actually track the sale of items. There are three new data files to mix into the system, so for this iteration we'll focus on just DAL and Relationships.

## Data Access Layer

### `InvoiceItemRepository`

Invoice items are how invoices are connected to items. A single invoice item connects a single item with a single invoice.

The `InvoiceItemRepository` is responsible for holding and searching our `InvoiceItem`
instances. It offers the following methods:

* `all` - returns an array of all known `InvoiceItem` instances
* `find_by_id` - returns either `nil` or an instance of `InvoiceItem` with a matching ID
* `find_all_by_item_id` - returns either `[]` or one or more matches which have a matching item ID
* `find_all_by_invoice_id` - returns either `[]` or one or more matches which have a matching invoice ID

The data can be found in `data/invoice_items.csv` so the instance is created and used like this:

```ruby
ir = InvoiceItemRepository.new
ir.load_data("./data/invoice_items.csv")
invoice = ir.find_by_id(6)
# => <invoice_item>
```

### `InvoiceItem`

The invoice item has the following data accessible:

* `id` - returns the integer id
* `item_id` - returns the item id
* `invoice_id` - returns the invoice id
* `quantity` - returns the quantity
* `unit_price` - returns the unit_price
* `created_at` - returns a `Date` instance for the date the invoice item was first created
* `updated_at` - returns a `Date` instance for the date the invoice item was last modified

We create an instance like this:

```ruby
ii = InvoiceItem.new({
  :id => 6,
  :item_id => 7,
  :invoice_id => 8,
  :quantity => 1,
  :unit_price => BigDecimal.new(10.99, 4),
  :created_at => Time.now,
  :updated_at => Time.now
})
```

### `TransactionRepository`

Transactions are billing records for an invoice. An invoice can have multiple transactions, but should have at most one that is successful.

The `TransactionRepository` is responsible for holding and searching our `Transaction`
instances. It offers the following methods:

* `all` - returns an array of all known `Transaction` instances
* `find_by_id` - returns either `nil` or an instance of `InvoiceItem` with a matching ID
* `find_all_by_invoice_id` - returns either `[]` or one or more matches which have a matching invoice ID
* `find_all_by_credit_card_number` - returns either `[]` or one or more matches which have a matching credit card number
* `find_all_by_result` - returns either `[]` or one or more matches which have a matching status

The data can be found in `data/transactions.csv` so the instance is created and used like this:

```ruby
tr = TransactionRepository.new
tr.load_data("./data/transactions.csv")
transaction = tr.find_by_id(6)
# => <transaction>
```

### `Transaction`

The invoice item has the following data accessible:

* `id` - returns the integer id
* `invoice_id` - returns the invoice id
* `credit_card_number` - returns the credit card number
* `credit_card_expiration_date` - returns the credit card expiration date
* `result` - the transaction result
* `created_at` - returns a `Date` instance for the date the invoice item was first created
* `updated_at` - returns a `Date` instance for the date the invoice item was last modified

We create an instance like this:

```ruby
t = Transaction.new({
  :id => 6,
  :invoice_id => 8,
  :credit_card_number => "4242424242424242",
  :credit_card_expiration_date => "0220",
  :result => "success",
  :created_at => Time.now,
  :updated_at => Time.now
})
```

### `CustomerRepository`

### `Customer`

## Relationships
