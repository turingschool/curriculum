---
layout: page
title: Refining our Extension
section: Building Applications with Spree
---

To finish our admin experience we used a fairly brute force approach to getting
the job done. Similar to stubbing our admin flag data this approach allows us
to quickly complete our work without worrying about too much else.

The Spree admin experience is improved with the addition that we have made.
Now it is time to refine the experience to use a less aggressive approach
and eventually extract it into an extension.

### Replacing an Entire View

To create our users' index view we replaced the *entire* existing index view.
This solution works but could cause us problems in the future if the
`spree_auth_devise` gem decides to change its layout. We would no longer be
able to leverage any additions that they made.

* Open `app/views/spree/admin/users/index.html.erb`

The sum total of our changes are two lines within the table. The remainder of
the code within the template was copied from the original view template. We
were not interested in any of the rest of the code, however, we needed to copy them
over because there is no way to easily replace a single part of the template.

If we had created more substantial changes to the original template then it
would make more sense to leave our override in place. However, this is an
instance where it makes sense to leverage other methods to replace content.

### Using Deface

The most common way to manipulate a view without over-writing it in the
traditional way is to use the gem [deface](https://github.com/spree/deface). The gem allows you to define
append, remove, and replace code or content within the views.

#### Removing the Old Table

Let's experiment upon the app as it stands right now. We'll try to remove the users table from our overriden template using Deface.

* Create `app/overrides/spree/admin/users/index.rb` and add the following source
code:

```ruby
Deface::Override.new(virtual_path: "spree/admin/users/index",
  name: "new table",
  replace: "table#listing_users",
  text: "")
```

When you refresh the page the entire table should be missing from the admin
users' index. If nothing appears different, try stopping and restarting your development server, then revisit the page.

#### Adding the Table in a Partial Template

* Open `app/overrides/spree/admin/users/index.rb` and change it to use a partial instead of text:

```ruby
Deface::Override.new(virtual_path: "spree/admin/users/index",
  name: "new table",
  replace: "table#listing_users",
  partial: "spree/admin/users/table")
```

We are mimicing the path of the template with our overriding template (`spree/admin/users/table`). This is not a requirement for our override as Deface uses the `virtual_path` to
know which file to replace. However, it is a good convention to parrot the
view directory for our own organization and maintainability.

* Open `app/views/spree/admin/users/index.html.erb` and copy the contents of
  the table to your clipboard.

We do not want to remove our current table because we are using deface to
*replace* the existing table. If we were to remove the table in our replacement template, then Deface would not find the DOM element we want it to replace.

* Create `app/views/spree/admin/users/_table.html.erb` and copy the table
  contents into the new partial we created.

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

#### Using the Original Template

We want to fallback to using the original template as defined in the the
`spree_auth_devise` gem.

* Delete `app/views/spree/admin/users/index.html.erb`

With that file removed when we refresh the page our custom table should still
be present.

#### Reducing the Replacement

We're replacing less of the view template, but still replacing the whole table.

Instead, let's rework our Deface usage to:

1. Insert the `<th>` table heading
2. Insert the `<td>` with the actual admin check

Hints:

* Target the `<th>` and `<td>` with class `actions`
* For each replacement use Deface's `insert_before`

### Conclusions

From the outset we could have used the Deface option. But overriding the entire view template made the process a bit more transparent.
