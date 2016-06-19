from flask import Flask
from flask_login import LoginManager
from flask_sqlalchemy import SQLAlchemy
from flask_bcrypt import Bcrypt

app = Flask(__name__)
app.config.from_object('config.DevelopmentConfig')
db = SQLAlchemy(app)
bcrypt = Bcrypt(app)

from application.model.app_model import User

login_manager = LoginManager()
login_manager.init_app(app)
login_manager.login_view = 'application.login'

# Blueprints registration
from application.views import landing
from application.views import app_views
from application.views import panel
from application.views import profile

app.register_blueprint(landing.mod)
app.register_blueprint(app_views.mod)
app.register_blueprint(panel.mod)
app.register_blueprint(profile.mod)

# jinja2 config
app.jinja_env.trim_blocks = True
app.jinja_env.lstrip_blocks = True


@login_manager.user_loader
def load_user(uid):
    return User.query.filter(User.id == uid).first()


@app.route('/cdb')
def cdb():
    from application.model.operational import Ambulance, Bill, Dispatch, Emergency, InsurancePlan, Patient
    from application.model.places import Canton, Province
    from application.model.workforce import Employee, Driver, Paramedic, ParamedicTeam
    db.create_all()
    u = User('Ricardo', 'Madriz', 'M', 'richin13', 'richin13@gmail.com', 'admin')
    db.session.add(u)
    db.session.commit()
    return 'done'
