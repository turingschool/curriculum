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

sa.merchants_with_only_one_transaction.by_month(month) #=> [merchant, merchant, merchant]
```

`by_month` works as a filter and can be used on any collection:

```rb
sa = SalesAnalyst.new

sa.merchants_with_pending_invoices.by_month(month) #=> [merchant, merchant, merchant]
sa.top_revenue_earners.by_month(month)          #=> [merchant, merchant, merchant]
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

sa.most_sold_item_for_merchant(merchant_id) #=> item

sa.best_item_for_merchant(merchant_id) #=> item
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
.top_percent(0.xx)
.bottom_percent(0.xx)

.by_weekday("Weekday")
.by_month("Month name")
```
