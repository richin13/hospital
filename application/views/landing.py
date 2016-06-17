import flask

mod = flask.Blueprint('landing', __name__)


@mod.route('/')
def index():
    return flask.render_template('landing/index.html')


@mod.route('/about')
def about():
    return 'about'


@mod.route('/contact')
def contact():
    return 'contact'


