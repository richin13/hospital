import flask
import flask_login
from sqlalchemy import or_
from ..forms.user_forms import LoginForm
from application.model.app_model import User

mod = flask.Blueprint('application', __name__, url_prefix='/app')


@mod.route('/')
def index():
    return flask.redirect(flask.url_for('application.panel.index'))


@mod.route('/tracking')
@flask_login.login_required
def tracking():
    return 'hola'


@mod.route('/login', methods=['GET', 'POST'])
def login():
    form = LoginForm()
    error = False

    if form.validate_on_submit():
        user = User.query.filter(
            or_(User.email == form.username_email.data, User.username == form.username_email.data)).first()

        if user and user.validate_password(form.password.data):
            flask_login.login_user(user)
            _next = flask.request.args.get('next')
            return flask.redirect(_next or flask.url_for('application.index'))
        else:
            error = True

    return flask.render_template('app/login.html', form=form, error=error)


@mod.route('/logout')
@flask_login.login_required
def logout():
    flask_login.logout_user()

    return flask.redirect(flask.url_for('landing.index'))
