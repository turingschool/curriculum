---
layout: page
title: RubyPress
---

In this project you'll use Ruby on Rails to build a content management system.

<div class="note">
<p>Consider the requirements fluid until 11:59PM, Monday, April 30th.</p>
</div>

### Learning Goals

* Practices techniques for scalable application architecture including caching, pre-rendering, and database optimization.
* Continue using TDD to drive all layers of Rails development
* Continue to improve User Interface concepts and skills

### Understandings

Please consider the requirements below non-exhaustive guidelines for building a content management system. If you know something should be done but it isn't listed below, do it.

### Restrictions & Outside Code

Project implementation may *not* use:

* RadiantCMS, RefineryCMS, or any other pre-fab CMS system
* Jekyll or derivitives

You *may* choose to use a templating language like `radius` or `liquid` if you choose.

### Base Expectations

You are to build a content management system which can be used by administrators to create content and public users to consume content.

#### Public Visitor

As a public visitor I can:

* View content on the site
* Access the login page

#### Authenticated Author

As an authenticated author, I can:

* Manipulate Content (assuming I'm authorized)
  * Create/Edit/Delete pages
  * Create/Edit/Delete snippets
  * Create/Edit/Delete redirects
* My Account
  * Login
  * Request a password reset and receive a login link via email
  * Change my password
  * View my login history (timestamps, IP address)

#### Authenticated Administrator

As an authenticated Administrator, I can:

* Do everything an Author can do
* Accounts
  * Create new accounts
  * Change the password of a specified account
  * Generate a random-ish password which is emailed to the account owner
  * Deactivate an account
* Permissions
  * Create permissions groups (ex: "Blog Authors")
  * Assign and remove accounts from permissions groups
  * Connect permissions groups with pages (see later section)

### Permissions / Authorization

This project needs to use a role-based access control model.

Imagine we have an `about-us` page on the site. It is connected to the roles `trusted-authors` and `corporate`.

If a user is a member of the `corporate` group, they can edit or delete the page and add child pages.

If a user is a member of the `trusted-authors` group, they can do the same.

If a user is a member of the `admin` group, they can do the same because this group has global permissions.

If a user is not a member of any of those groups, they can see that the page exists in the hierarchy but cannot modify it.

Lastly, the permissions "trickle down." Say the the `about-us` page is nested under the `history` page. Any group which has permissions to work with `history` would also have permission to work with `about-us`.

### Creating Content

There are several different types of content you need to handle:

#### Pages

Pages are structured in a hierarchy. For example:

```
Root
  - About Us
  - Contact
  - Blog
    - 2012
      - Woohoo blog post
      - This year is going to be awesome
    - 2011
      - End of the year wrapup
```

Each page has:

* a parent (except the special Root page)
* a name
* a body
* `created_at` and `updated_at` timestamps
* a `published_at` timestamp
* a layout
* attached authorization roles

##### Body Text Markup

The body should offer a select box of processor options including:

* HTML (plain)
* Markdown
* Textile

##### Published At

If the `published_at` is now or in the past, the page should show up on the public site. If it's `nil` or in the future, the page should not be accessible.

#### Layouts

Layouts are used to wrap content, similar to layouts in a Rails application.

They can contain HTML content, can utilize snippets, and should have a marker (maybe `yield`) where the page content will be output.

#### Snippets

Snippets are template fragments which get rendered inside other pages. They can include content and reference other snippets.

### Data Validity

Any attempt to create/modify a record with invalid attributes should return the user to the input form with a validation error indicating the problem along with suggestions how to fix it.

#### Page

* must have a name unique to that level of the page hierarchy
* must be attached to a layout

#### Snippet

* must have a name unique to that collection

#### Layout

* must have a unique name

#### Redirects

* must have an order of precidence
* must have a destination

### Example Data

### Response Times

Response time and caching are critically imporant. Your CMS should make significant use of:

* data caching
* fragment caching
* page caching
* query consolidation
* database optimizations (query count, using indicies, join)

### Extensions

#### Redirects

A redirect intercepts an incoming request and redirects it to a page on the site or an external URL.

Imagine that we've changed the structure of our blog. We want to capture requests coming in to the old address pattern and send them to the new URLs. Here is how we could create a redirect:

##### Matcher

The matcher could use a format similar to Rails like this:

```
/posts/:id
```

Then any requests for `/posts/5` of `/posts/26` would match this redirect and put the `5` or `26` into an `id` variable.

##### Target

Then the target can reference the same variables:

```
/blog/articles/:id
```

So `/posts/5` would redirect them to `/blog/articles/5`.

#### Assets

A page can have one or more attached assets.

Those assets can then be referenced from inside the page. They also have a unique URL which can be referenced from other pages.

When images are uploaded the system can create resized versions of configurable dimensions in the background.

#### Layouts

Improve the layout functionality so that:

1. Layouts can be nested in other layouts
2. Layouts can be chosed based on media type sniffing. So you might create a `blog` layout that gets used for normal requests, but `blog_mobile` that gets used for mobile requests.
3. Layouts trickle down from the parent. So there is some default setting like `"From Parent"` which gets the layout of the parent or the author can choose another option.
4. Parents can set the "Default Child Layout." Imagine on the root page I'm using the blog index I'm using a layout named `blog_index`, I could choose that each child automatically defaults to the `blog_article`.

#### Extension 4

### Evaluation Criteria

This project will be peer assessed using automated tests and the rubric below. Automated tests will be available by 8AM, Tuesday, April 10th.

1. Correctness
  * 3: All provided stories pass without an error or crash
  * 2: One story failed
  * 1: Two or three stories failed
  * 0: More than three stories failed
2. Testing
  * 3: Testing suite covers >95% of application code
  * 2: Testing suite covers 85-94% of application code
  * 1: Testing suite covers 70-84% of application code
  * 0: Testing suite covers <70% of application code
3. Code Style
  * 3: Source code generates no complaints from Cane or Reek.
  * 2: Source code generates warnings about whitespace/comments, but no violations of line-length or method statement count
  * 1: Source code generates six or fewer warnings about line-length or method statement count
  * 0: Source code generates more than six warnings about line-length or method statement count
4. Live Hungry
  * 4: Program fulfills all Base Expectations and four Extensions
  * 3: Program fulfills all Base Expectations and two Extensions
  * 2: Program fulfills all Base Expectations
  * 1: Program is missing 1-3 Base Expectations
  * 0: Program fulfills many Base Expectations, but more than three features are missing.
5. User Interface & Design
  * 3: WOW! This site is beautiful, functional, and clear.
  * 2: Very good design and UI that shows work far beyond dropping in a library or Bootstrap.
  * 1: Some basic design work, but doesn't show much effort beyond "ready to go" components/frameworks/etc
  * 0: The lack of design makes the site difficult / confusing to use
6. Surprise & Delight
  * 2: A great idea that's well executed and enhances the shopping experience.
  * 1: An extra feature that makes things a little nicer, but doesn't blow your mind.
  * 0: No surprise. Sad face :(

### Evaluation Protocol
