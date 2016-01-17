# Iteration 5: Customer/Merchant Analytics

The marketing team loved the software and told everyone in the office how much better they were able to do their work. We received a lot of requests from other departments and the first team we are going to help is the logistics team.    

## Analysis

### `MerchantRepostiory`

The logistics team need to be able to filter merchants by the following:

Which merchants have pending invoices:

```rb
sa = SalesAnalyst.new

sa.merchants_with_pending_invoices
```

**Note:** an invoice is considered pending if one or more of it’s transactions are not successful.

Which merchants had only one transaction:

```rb
sa = SalesAnalyst.new

sa.merchants_with_only_one_transaction #=> [merchant, merchant, merchant]
```

Which merchants had only one transaction in a given month:

```rb
sa = SalesAnalyst.new

collection = merchants_with_only_one_transaction
sa.by_month(collection, month) #=> [merchant, merchant, merchant]
```

`by_month` works as a filter and can be used on any collection:

```rb
sa = SalesAnalyst.new

collection = sa.merchants_with_pending_invoices
sa.by_month(collection, month) #=> [merchant, merchant, merchant]

collection = sa.top_revenue_earners
sa.by_month(collection, month)          #=> [merchant, merchant, merchant]
```

For individual merchants we need to find the following data,

total revenue for a single merchant:

```rb
sa = SalesAnalyst.new

sa.revenue_by_merchant(merchant_id) #=> $$$
```

which item sold most in terms of quantity and revenue: 

```rb
sa = SalesAnalyst.new

sa.most_sold_item_for_merchant(merchant_id) #=> [item, item] (in terms of quantity sold)

sa.best_item_for_merchant(merchant_id) #=> item (in terms of revenue generated)
```

and find out which month the merchant sold the most: 

```rb
sa = SalesAnalyst.new

sa.best_month_for_merchant(merchant_id) => "Month name"
```

find the best invoice, an invoice with the highest total $ amount:

```rb
sa = SalesAnalyst.new

sa.best_invoice #=> invoice
```

and if passed a merchant_id, the method `best_invoice` returns the best invoice for a given merchant. 

```rb 
sa = SalesAnalyst.new

sa.best_invoice(merchant_id) #=> invoice
```

### More from the marketing team

The marketing department called and said they were super jealous on the `top_percent` and `in_percentile` filters that the logistics team had available to use on `Merchant` instances. Let's extend the filters to be available for all objects: `Invoice`, `Customer`, `Merchant`, `Transaction` and `Item`.

The filters are:

```rb
.top_percent(collection, 0.xx)
.bottom_percent(collection, 0.xx)

.by_weekday(collection, "Weekday")
.by_month(collection, "Month name")
```
