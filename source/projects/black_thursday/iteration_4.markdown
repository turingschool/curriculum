# Iteration 4: Merchant (and some Customer) Analytics

Performance reviews are coming up and it's time to explroe the highs and the lows.

## Analysis

### `MerchantRepository`

We can query the MerchantRepository for the following:

To find out the total revenue for a given date:

```rb
merchants.revenue(date) #=> $$
```

To find the top x performing merchants in terms of revenue:  

```rb
merchants.most_revenue(x) #=> [merchant, merchant, merchant]
```

If no number is given for `most_revenue`, it takes the top 20 merchants by default: 

```rb
merchants.most_revenue #=> [merchant, merchant, merchant] (20 % of top merchants by revenue)
```

It's also possible to filter the results to find which merchants are in x percentile:

```rb
merchants.all.in_percentile(xx) #=> [merchant, merchant, merchant]
```

And filter the results to find the top x percent:

```rb
merchants.all.top_percent(xx) #=> [merchant, merchant, merchant]
```

To find which merchants were most popular in which month (more about `by_month(month)` below):

```rb
merchants.most_revenue.by_month(month) #=> [merchant, merchant, merchant ]
```

### `CustomerRepository`

Our marketing team is asking for better data about of our customer base to launch a new project and have the following requirements:

Find the x customers that spent the most $:

```rb
customers.top_buyers #=> [customer, customer, customer]
```

Be able to find which merchant the customers bought the most items from:

```rb
customer.top_merchant #=> <Merchant >
```

And in turn find out which __merchant__ was the most popular:

```rb
merchants.most_popular
```

Find which customers only had one transaction:

```rb
customers.one_time_buyers #=> #=> [customer, customer, customer]
```

Find which month had the most `one_time_buyers`:

```rb
customers.one_time_buyers.by_month(month)
```

`by_month` acts as as a filter for all collections:  

```rb
merchants.most_popular.by_month(month) #=> #=> [customer, customer, customer]
customers.top_buyers.by_month(month) #=> #=> [customer, customer, customer]
```
