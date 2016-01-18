# Iteration 5: Customer Analytics

Our marketing team is asking for better data about of our customer base to launch a new project and have the following requirements:

Find the x customers that spent the most $:

```rb
sa = SalesAnalyst.new

sa.top_buyers(x) #=> [customer, customer, customer, customer, customer]
```

If no number is given for `top_buyers`, it takes the top 20 customers by default

```rb
sa = SalesAnalyst.new

sa.top_buyers #=> [customer * 20]
```

Be able to find which merchant the customers bought the most items from:

```rb
sa = SalesAnalyst.new

sa.top_merchant_for_customer(customer_id) #=> merchant
```

Find which customers only had one transaction:

```rb
sa = SalesAnalyst.new

sa.one_time_buyers #=> [customer, customer, customer]
```

Find which month had the most `one_time_buyers`:

```rb
sa = SalesAnalyst.new

sa.one_time_buyers_in_month("Month name") #=> [customer, customer]
```

Find which item a customer bought the most of:

```rb
sa = SalesAnalyst.new

sa.favorite_item(customer_id) #=> [item]
```

Return all items that were purchased most if there are several with the same quantity:

```rb
sa = SalesAnalyst.new

sa.favorite_item(customer_id) #=> [item, item, item]
```

Find customers with unpaid invoices:

```rb
sa = SalesAnalyst.new

sa.customers_with_unpaid_invoices #=> [customer, customer, customer]
```

**Note:** invoices are unpaid if one or more of the invoices are not paid in full (see method `invoice#is_paid_in_full?`).

Find the best invoice, the invoice with the highest dollar amount:

```rb
sa.best_invoice #=> invoice
```
