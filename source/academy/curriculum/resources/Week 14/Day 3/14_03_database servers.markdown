---
layout: page
title: Database Servers
---

## Database Servers

* Database responsibilities
* Options
  * SQL: SQLite, PostgreSQL, MySQL, Oracle, MS SQL Server
  * "NoSQL": Redis, Mongo, Riak, CouchDB, Cassandra
* Systems Concepts
  * Database server hosts multiple databases
  * Database Users != System Users
  * Users have permissions per database
* Architecture Concepts
  * Transaction Handling
  * Master / Slave
  * Sharding
  * Ring
* Pros & Cons
  * Reads vs Writes
  * Reliability, Consistency & Eventual Consistency
  * Data integrity

#### Workshop Time

For the remainder of the session, please work on:

* install and configure MySQL or PostgreSQL in your Vagrant VM
* create a unique user and database for each of the two Rails apps you deployed yesterday
* set the applications to use those databases (in the `database.yml`)
* run migrations and seeds, restart Ruby servers
* delete any SQLite DBs from the project folders
* verify that the sites work
* BONUS: make a user who does not have `sudo` permissions and runs your MySQL server

#### References

* MySQL
  * [http://kimbriggs.com/computers/computer-notes/mysql-notes/mysql-setup-guide-debian-ubuntu.file](Notes on setting up users)