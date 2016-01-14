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

**Note:** an invoice is considered pending if none of it’s transactions are successful.

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

find the invoice with the highest total $ amount:

```rb
sa = SalesAnalyst.new

sa.best_invoice
```

### More from the marketing team

The marketing department called and said they were super jealous on the `top_percent` and `in_percentile` filters that the logistics team had available to use on `Merchant` instances. Let's extend the filters to be available for the following instances: `Invoice`, `Customer`, `Merchant` and `Item`.

The filters are:

```rb
.top_percent(xx)
.in_percentile(xx)
.by_month(month)
```
