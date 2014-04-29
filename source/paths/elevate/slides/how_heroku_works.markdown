title: How Heroku Works
output: how_heroku_works.html
controls: true
theme: JumpstartLab/cleaver-theme

--

# How Heroku Works

--

## High Level

--

## Git as Transport Mechanism

--

### Why Git?

--

### Heroku as Git Remote

--

### Just Like Any Other Remote

```
git@heroku.com:name_of_your_application.git
```

--

```
$ git remote add heroku git@heroku.com:name_of_your_application.git
```

--

### Now It's Just Git

--

## Building a Slug

--

## Dynos Run Slugs

--

### One Dyno, One Slug

--

### One Slug, Many Dynos

--

## Responding to Requests

[Heroku Request/Response Cycle](http://tutorials.jumpstartlab.com/images/elevate/heroku_request_response.png)

--

## Recap

* You transfer code to Heroku by using `git push`
* Heroku builds an archive of your ready-to-run application called a **slug**
* A slug gets copied to and run on one or more **dynos**. The more dynos you run, the more traffic you can support.
* Requests come in to Heroku's **Routing Mesh** and are dispatched to one of your dynos randomly
* All dynos can *share data* so you don't care which dyno is actually serving the request

--

## References

* [How Heroku Works](https://Dev Center.heroku.com/articles/how-heroku-works) on Heroku's Dev Center
* [Heroku Architecture](https://Dev Center.heroku.com/categories/heroku-architecture) on Heroku's Dev Center
