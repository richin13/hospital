import flask
import flask_login
from application.forms.panel_forms import AddAmbulanceForm

mod = flask.Blueprint('application.panel', __name__, url_prefix='/app/panel')


@mod.route('/')
@flask_login.login_required
def index():
    return flask.render_template('app/panel/index.html', title='Panel', current_page='index')


@mod.route('/dispatch')
@flask_login.login_required
def dispatch():
    return flask.render_template('app/panel/dispatch.html', title='Panel/Despacho', current_page='dispatch')


@mod.route('/ambulances', methods=['GET', 'POST'])
@flask_login.login_required
def ambulances():
    form = AddAmbulanceForm()

    if form.validate_on_submit():
        return 'is valid'

    return flask.render_template('app/panel/ambulance.html', title='Panel/Ambulancias', current_page='ambulances',
                                 form=form)


@mod.route('/paramedics')
@flask_login.login_required
def paramedics():
    return flask.render_template('app/panel/paramedic.html', title='Panel/Paramédicos', current_page='paramedics')


@mod.route('/drivers')
@flask_login.login_required
def drivers():
    return flask.render_template('app/panel/driver.html', title='Panel/Conductores', current_page='drivers')
