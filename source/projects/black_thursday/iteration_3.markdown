# I3: Item Sales

We've got a good foundation, now it's time to actually track the sale of items. There are three new data files to mix into the system, so for this iteration we'll focus primarily on DAL and Relationships with just a bit of Business Intelligence.

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
ir.from_csv("./data/invoice_items.csv")
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
* `created_at` - returns a `Time` instance for the date the invoice item was first created
* `updated_at` - returns a `Time` instance for the date the invoice item was last modified

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
tr.from_csv("./data/transactions.csv")
transaction = tr.find_by_id(6)
# => <transaction>
```

### `Transaction`

The transaction has the following data accessible:

* `id` - returns the integer id
* `invoice_id` - returns the invoice id
* `credit_card_number` - returns the credit card number
* `credit_card_expiration_date` - returns the credit card expiration date
* `result` - the transaction result
* `created_at` - returns a `Date` instance for the date the transaction was first created
* `updated_at` - returns a `Date` instance for the date the transaction was last modified

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

Customers represent a person who's made one or more purchases in our system.

The `CustomerRepository` is responsible for holding and searching our `Customers`
instances. It offers the following methods:

* `all` - returns an array of all known `Customers` instances
* `find_by_id` - returns either `nil` or an instance of `InvoiceItem` with a matching ID
* `find_all_by_first_name` - returns either `[]` or one or more matches which have a first name matching the substring fragment supplied
* `find_all_by_last_name` - returns either `[]` or one or more matches which have a last name matching the substring fragment supplied

The data can be found in `data/customers.csv` so the instance is created and used like this:

```ruby
cr = CustomerRepository.new
cr.from_csv("./data/customers.csv")
customer = cr.find_by_id(6)
# => <customer>
```

### `Customer`

The customer has the following data accessible:

* `id` - returns the integer id
* `first_name` - returns the first name
* `last_name` - returns the last name
* `created_at` - returns a `Time` instance for the date the customer was first created
* `updated_at` - returns a `Time` instance for the date the customer was last modified

We create an instance like this:

```ruby
c = Customer.new({
  :id => 6,
  :first_name => "Joan",
  :last_name => "Clarke",
  :created_at => Time.now,
  :updated_at => Time.now
})
```

## Relationships

There are many connections to draw between all these objects. Assuming we start with this:

```ruby
se = SalesEngine.new
se.from_csv({
  :items => "./data/items.csv",
  :merchants => "./data/merchants.csv",
  :invoices => "./data/invoices.csv",
  :invoice_items => "./data/invoice_items.csv",
  :transactions => "./data/transactions.csv",
  :customers => "./data/customers.csv"
})
```

Then we can find connections from an invoice:

```ruby
invoice = se.invoices.find_by_id(20)
invoice.items # => [item, item, item]
invoice.transactions # => [transaction, transaction]
invoice.customer # => customer
```

Or a transaction:

```ruby
transaction = se.transactions.find_by_id(40)
transaction.invoice # => invoice
```

And if we started with a merchant we could find the customers who've purchased one or more items at their store:

```ruby
merchant = se.merchants.find_by_id(10)
merchant.customers # => [customer, customer, customer]
```

Or from the customer side we could find the merchants they've purchased from:

```ruby
customer = se.customers.find_by_id(30)
customer.merchants # => [merchant, merchant]
```

## Business Intelligence

* invoice is paid
* invoice total
