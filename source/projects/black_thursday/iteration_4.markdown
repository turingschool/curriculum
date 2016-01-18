# Iteration 4: Merchant Analytics

Our operations team is asking for better data about of our merchants and have asked for the following:

Find out the total revenue for a given date:

```rb
sa = SalesAnalyst.new

sa.total_revenue_by_date(date) #=> $$
```
**Note:** When calculating revenue the ``unit_price`` listed within ``invoice_items`` should be used. The ``invoice_item.unit_price`` represents the final sale price of an item after sales, discounts or other intermediary price changes.

Find the top x performing merchants in terms of revenue:  

```rb
sa = SalesAnalyst.new

sa.top_revenue_earners(x) #=> [merchant, merchant, merchant, merchant, merchant]
```

If no number is given for `top_revenue_earners`, it takes the top 20 merchants by default:

```rb
sa = SalesAnalyst.new

sa.top_revenue_earners #=> [merchant * 20]
```

Which merchants have pending invoices:

```rb
sa = SalesAnalyst.new

sa.merchants_with_pending_invoices #=> [merchant, merchant, merchant]
```

**Note:** an invoice is considered pending if none of its transactions are successful.

Which merchants offer only one item:

```rb
sa = SalesAnalyst.new

sa.merchants_with_only_one_item #=> [merchant, merchant, merchant]
```

And which month most of those merchants registered on our platform:

```rb
sa.merchants_with_only_one_item_registered_in_month("Month name") #=> [merchant, merchant, merchant]
```

Find the total revenue for a single merchant:

```rb
sa = SalesAnalyst.new

sa.revenue_by_merchant(merchant_id) #=> $
```

which item sold most in terms of quantity and revenue:

```rb
sa = SalesAnalyst.new

sa.most_sold_item_for_merchant(merchant_id) #=> item (in terms of quantity sold)

sa.best_item_for_merchant(merchant_id) #=> item (in terms of revenue generated)
```
