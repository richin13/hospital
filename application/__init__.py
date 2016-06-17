from flask import Flask
from flask_login import LoginManager
from flask_sqlalchemy import SQLAlchemy
from flask_bcrypt import Bcrypt

app = Flask(__name__)
app.config.from_object('config.DevelopmentConfig')
db = SQLAlchemy(app)
bcrypt = Bcrypt(app)

from application.model.User import User

login_manager = LoginManager()
login_manager.init_app(app)
login_manager.login_view = 'application.login'

# Blueprints registration
from application.views import landing
from application.views import app_views

app.register_blueprint(landing.mod)
app.register_blueprint(app_views.mod)

# jinja2 config
app.jinja_env.trim_blocks = True
app.jinja_env.lstrip_blocks = True


@login_manager.user_loader
def load_user(uid):
    return User.query.filter(User.id == uid).first()

@app.route('/cdb')
def createdb():
    db.create_all()
