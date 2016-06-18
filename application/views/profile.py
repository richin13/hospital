import flask
import flask_login

mod = flask.Blueprint('application.profile', __name__, url_prefix='/app/profile')


@mod.route('/')
@flask_login.login_required
def index():
    return flask.render_template('app/profile/index.html', title=flask_login.current_user.username,
                                 current_page='index')


@mod.route('/edit')
@flask_login.login_required
def edit():
    return 'bazinga'


@mod.route('/add')
@flask_login.login_required
def add():
    return 'add'
