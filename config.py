# -*- coding: utf-8 -*
import os


class Config(object):
    SQLALCHEMY_TRACK_MODIFICATIONS = False
    SECRET_KEY = os.environ['SECRET_KEY']  # Set this before running
    WTF_CSRF_ENABLED = True
    DEBUG = False
    TESTING = False
    SQLALCHEMY_DATABASE_URI = os.environ['PGSQL_URI']
    BCRYPT_LOG_ROUNDS = 12


class ProductionConfig(Config):
    SQLALCHEMY_DATABASE_URI = os.environ['MSSQL_CONN_STR']


class DevelopmentConfig(Config):
    DEBUG = True


class TestingConfig(Config):
    TESTING = True
