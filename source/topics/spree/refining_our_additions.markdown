---
layout: page
title: Refining our Extension
section: Building Applications with Spree
---

To finish our admin experience we used a fairly brute force approach to getting
the job done. Similar to stubbing our admin flag data this approach allows us
to quickly complete our work without worrying about too much else.

The Spree admin experience looks great with the addition that we have made.
Now it is time to refine the experience to use a less aggressive approach
and eventually extract it into an extension.

### Replacing an Entire View

To create our users' index view we replaced the entire existing index view.
This solution works but could cause us problems in the future if the
**spree_auth_devise** gem decides to change their layout. We would no longer be
able to leverage any additions that they made.

* Open `app/views/spree/admin/users/index.html.erb`

The sum total of our changes are two lines within the table. The remainder of
the code within the template was copied from the original view template. We
were not interested in any of those changes, however, we needed to copy them
over because there is no way to easily replace a single part of the template.

In the future, if Spree changes the template, changing the layout in some way
our user's would not receive those changes.

If we had created more substantial changes to the original template then it
would make more sense to leave our override in place. However, this is an
instance where it makes sense to leverage other methods to replace content.

### Using Deface

The most common way to manipulate a view without over-writing it in the
traditional way is to use the gem [deface](). The gem allows you to define
append, remove, and replace functionality within the views.

#### Removing the Old Table

Even with our current view in place lets see if we can remove the existing
users table and replace it with a temporary empty template.

* Create `app/overrides/spree/admin/users/index.rb` and add the following source
code:

```ruby
Deface::Override.new virtual_path: "spree/admin/users/index",
  name: "new table",
  replace: "table#listing_users",
  text: ""
```

When you refresh the page the entire table should be missing from the admin
users' index.

#### Adding the Table in a Partial Template

* Open `app/overrides/spree/admin/users/index.rb` and update it use a partial:

```ruby
Deface::Override.new virtual_path: "spree/admin/users/index",
  name: "new table",
  replace: "table#listing_users",
  partial: "spree/admin/users/table"
```

We are mimicing the path of the template with our file name override. This is
not a requirement for our override as deface uses the *virtual_path* to
know which file to replace. However, it is a good convention to parrot the
view directory.

* Open `app/views/spree/admin/users/index.html.erb` and copy the contents of
  the table to your clipboard.

We do not want to remove our current table because we are using deface to
*replace* the existing table. If we were to remove it our table, within our
new partial template, would not have a table to replace.

* Create `app/views/spree/admin/users/_table.html.erb` and copy the table
  contents into our new partial we created.

```erb
<table class="index" id="listing_users" data-hook>
  <colgroup>
    <col style="width: 85%">
    <col style="width: 15%">
  </colgroup>
  <thead>
    <tr data-hook="admin_users_index_headers">
      <th><%= sort_link @search,:email, Spree.t(:user), {}, {:title => 'users_email_title'} %></th>
      <th>Admin?</th>
      <th data-hook="admin_users_index_header_actions" class="actions"></th>
    </tr>
  </thead>
  <tbody>
    <% @users.each do |user|%>
      <tr id="<%= spree_dom_id user %>" data-hook="admin_users_index_rows" class="<%= cycle('odd', 'even')%>">
        <td class='user_email'><%=link_to user.email, object_url(user) %></td>
        <td><%= user.admin? %></td>
        <td data-hook="admin_users_index_row_actions" class="actions">
          <%= link_to_edit user, :no_text => true %>
          <%= link_to_delete user, :no_text => true %>
        </td>
      </tr>
    <% end %>
  </tbody>
</table>
```

* Delete `app/views/spree/admin/users/index.html.erb`

We want to fallback to using the existing template as defined in the the
**spree_auth_devise** gem.

With that file removed when we refresh the page our custom table should still
be present.

The new override and partial template obfuscates more what is taking place but
this will hopefully allow our application to continue to more easily grow
and changes as the Spree template change.

### Conclusions

From the outset we could have used the deface option, however, we were not
sure what we would have to change within the the view to accomplish what we
had hoped. It was easier to start with the replacement of the entire view
and then refine our override only after we were done.

This is a good strategy to adopt early on when working with Spree. After we
accomplish our goal then we should evaluate an optimization in our view
replacement strategy.