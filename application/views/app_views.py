import flask
from flask_login import login_required
from flask_login import login_user
from flask_login import logout_user
from ..forms import LoginForm
from application.model.User import User

mod = flask.Blueprint('application', __name__, url_prefix='/app')


@mod.route('/')
def index():
    return flask.redirect(flask.url_for('landing.index'))


@mod.route('/panel')
def panel():
    return 'panel'


@mod.route('/tracking')
@login_required
def tracking():
    return 'hola'


@mod.route('/profile')
@login_required
def profile():
    return 'profile'


@mod.route('/login', methods=['GET', 'POST'])
def login():
    form = LoginForm()
    error = False

    if form.validate_on_submit():
        user = User.query.filter_by(email=form.email.data).first()

        if user and user.validate_password(form.password.data):
            login_user(user)
            _next = flask.request.args.get('next')
            return flask.redirect(_next or flask.url_for('application.index'))
        else:
            error = True

    return flask.render_template('app/login.html', form=form, error=error)


@mod.route('/logout')
def logout():
    logout_user()

    return flask.redirect(flask.url_for('landing.index'))
