Hospital
===================

[![Build Status](https://api.travis-ci.org/richin13/hospital.svg?branch=development)](https://travis-ci.org/richin13/hospital) [![License](https://img.shields.io/badge/license-GPLv3-blue.svg)](https://www.gnu.org/licenses/gpl-3.0.en.html)
[![Python](https://img.shields.io/badge/python-3.5-gren.svg)](https://www.python.org/downloads/release/python-350/)


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
<p align="center">
  <img src="http://i.imgur.com/zdfp6tS.png" alt="stack" />
</p>

Hospital is written in Python and make use of Flask microframework and other technologies described below

> **Note:**

> - This list may change.
> - Always refer to the documentation of each one before asking stupid questions.

* Python (3.5.1)
* Flask Microframework
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
* ~~Create database~~
* ~~Introduce MSSQL to SQL Alchemy~~
* ~~Add /app templates~~
* Consume stored procedures in app

----------

License
------------------

See LICENSE
