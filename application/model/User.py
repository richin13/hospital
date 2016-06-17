from application import db
from application import bcrypt
from flask_login import UserMixin
from sqlalchemy.ext.hybrid import hybrid_property


class User(db.Model, UserMixin):
    id = db.Column(db.Integer, primary_key=True)
    username = db.Column(db.String(80), unique=True)
    email = db.Column(db.String(120), unique=True)
    _password = db.Column(db.String(128))

    def __init__(self, username, email, pw):
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
