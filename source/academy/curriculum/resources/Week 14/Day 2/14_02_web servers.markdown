---
layout: page
title: Web Servers, Workshop
---

## Web Servers

* Web server's roles
* Why do you need it?
* Pros & Cons
* Options
  * Apache
  * NGINX
  * IIS (!)

### Workshop Time

For the remainder of the hour, please work on installing and configuring one of the two web servers -- ideally whichever one you have *less* experience with.

* Configure Vagrant to forward your primary OS port 80 to your VM's port 80
* Configure your web server to respond on port 80
* In the VM:
  * Create a folder `/var/www/static/`
  * Create a file `index.html`
  * In the file, add this document:

```
<html>
  <body>
    <h1>Hello, Static World!</h1>
  </body>
</html>
```

* Configure the web server so this file is displayed when you access http://localhost in your native OS browser