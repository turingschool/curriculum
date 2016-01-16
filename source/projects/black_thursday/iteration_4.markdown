# Iteration 4: Merchant (and some Customer) Analytics

Performance reviews are coming up and it's time to explroe the highs and the lows.

## Analysis

### `MerchantRepository`

We can query the MerchantRepository for the following:

To find out the total revenue for a given date:

```rb
sa = SalesAnalyst.new

sa.merchant_revenue_by_date(date) #=> $$
```
**Note:** When calculating revenue the ``unit_price`` listed within ``invoice_items`` should be used. The ``invoice_item.unit_price`` represents the final sale price of an item after sales, discounts or other intermediary price changes.

To find the top x performing merchants in terms of revenue:  

```rb
sa = SalesAnalyst.new

sa.top_revenue_earners(x) #=> [merchant, merchant, merchant]
```

If no number is given for `top_revenue_earners`, it takes the top 20 merchants by default:

```rb
sa = SalesAnalyst.new

sa.top_revenue_earners #=> [merchant, merchant, merchant] (20 % of top merchants by revenue)
```

Rank all the merchants by revenue:

```rb
sa = SalesAnalyst.new

sa.merchants_ranked_by_revenue #=> [merchant, merchant, merchant]
```

And filter the results to find the top x percent:

```rb
sa = SalesAnalyst.new

collection = sa.merchants_ranked_by_revenue.
sa.top_percent(collection, xx) #=> [merchant, merchant, merchant]
```

**Note:** percentages will be given as decimals, e.g. 0.6, 0.45, 0.55, and it rounds up. If the given percentage represents 15.2 merchants, you should return 16 merchants.

To find which merchants were most popular in which month (more about `by_month(month)` below):

```rb
sa = SalesAnalyst.new

collection = sa.top_revenue_earners
sa.by_month(collection, month) #=> [merchant, merchant, merchant ]
```

### `CustomerRepository`

Our marketing team is asking for better data about of our customer base to launch a new project and have the following requirements:

Find the x customers that spent the most $:

```rb
sa = SalesAnalyst.new

sa.top_buyers(x) #=> [customer, customer, customer]
```

Be able to find which merchant the customers bought the most items from:

```rb
sa = SalesAnalyst.new

sa.top_merchant_for_customer(customer_id) #=> <Merchant >
```

Find which customers only had one transaction:

```rb
sa = SalesAnalyst.new

sa.one_time_buyers #=> #=> [customer, customer, customer]
```

Find which month had the most `one_time_buyers`:

```rb
sa = SalesAnalyst.new

collection = sa.one_time_buyers
collection.by_month(collection, month)
```

`by_month` acts as as a filter for all collections:  

```rb
collection = sa.most_popular_merchants

collection.by_month(collection, month) #=> #=> [customer, customer, customer]
collection.by_month(collection, month) #=> #=> [customer, customer, customer]
```
