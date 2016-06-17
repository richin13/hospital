Hospital [![Build Status](https://travis-ci.org/richin13/hospital.svg?branch=development)](https://travis-ci.org/richin13/hospital)
===================

Hospital is a Python web application developed as part of the college's course 'Database Administration'. It manages the operational work of propietary ambulances in a random hospital.

----------

Quickstart
------------

First, clone the repo:

```bash
$ git clone https://github.com/richin13/hospital.git
$ cd hospital
```

Then, install all the dependencies

```
$ pip install -r requirements.txt
$ bower install
```

To view the app in action just type `python run.py` and open `http://localhost:5000` in a web browser.
Stack
-------------

Hospital is written in Python and make use of Flask microframework and other technologies described below

> **Note:**

> - This list may change.
> - Always refer to the documentation of each one before asking stupid questions.

* Python (3.5.1)
* Flask Microframework
 * Flask-Auth
 * Flask-Bcrypt
 * Flask-Login
 * Flask-SQLAlchemy
* Microsoft SQL Server 2014
* Semantic-UI

-------------

TODO
-------------

The app is still in __super__ early development

* ~~Add flask application structure~~
* Create database
* Introduce MSSQL to SQL Alchemy
* Add /app templates

----------

License
------------------

See LICENSE
