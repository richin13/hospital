from application import db
from application import bcrypt
from flask_login import UserMixin
from sqlalchemy.ext.hybrid import hybrid_property


class User(db.Model, UserMixin):
    __table__ = 'users'

    id = db.Column(db.Integer, primary_key=True)
    name = db.Column(db.String(32), nullable=False)
    last_name = db.Column(db.String(32), nullable=False)
    genre = db.Column(db.CHAR(1), db.CheckConstraint('genre in (\'M\', \'F\')'), nullable=False)
    username = db.Column(db.String(80), nullable=False, unique=True)
    email = db.Column(db.String(120), nullable=False, unique=True)
    _password = db.Column(db.String(128), nullable=False)

    def __init__(self, name, last_name, genre, username, email, pw):
        self.name = name
        self.last_name = last_name
        self.genre = genre
        self.username = username
        self.email = email
        self._password = bcrypt.generate_password_hash(pw)

    @hybrid_property
    def password(self):
        return self._password

    @password.setter
    def _set_password(self, pw):
        self._password = bcrypt.generate_password_hash(pw)

    def validate_password(self, password):
        return bcrypt.check_password_hash(self.password, password)

    def __repr__(self):
        return 'User <%r>' % self.username
