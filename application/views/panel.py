import flask
import flask_login
from application import db
from application.forms.panel_forms import AddAmbulanceForm, AddDriverForm, AddParamedicForm, AddTeamForm, \
    DispatchForm
from application.model.operational import Ambulance, Emergency, Dispatch
from application.model.workforce import Driver, Paramedic, ParamedicTeam
from application.model.places import Province, Canton

mod = flask.Blueprint('application.panel', __name__, url_prefix='/app/panel')


@mod.route('/')
@flask_login.login_required
def index():
    return flask.render_template('app/panel/index.html', title='Panel', current_page='index')


@mod.route('/dispatch', methods=['GET', 'POST'])
@flask_login.login_required
def dispatch():
    form = DispatchForm()

    form.emergency.province.choices = [(p.id, p.name) for p in Province.query.order_by('id')]
    form.emergency.canton.choices = [(c.id, c.name) for c in Canton.query.order_by('name')]

    form.ambulance.choices = [(a.id, a.plate_number) for a in Ambulance.query.order_by('plate_number')]
    form.team.choices = [(t.id, str(t)) for t in ParamedicTeam.query.order_by('id')]

    if form.validate_on_submit():
        e = Emergency(form.emergency.description.data, form.emergency.type.data, form.emergency.address.data,
                      form.emergency.canton.data)
        d = Dispatch(form.ambulance.data, form.team.data, e.id, form.dispatch_hour.data, form.arrival_hour.data,
                     form.distance.data, form.status.data, form.fee.data)
        db.session.add(e)
        db.session.add(d)
        db.session.commit()
        return flask.redirect(flask.url_for('application.panel.dispatch'))

    return flask.render_template('app/panel/dispatch.html', title='Panel/Despacho', current_page='dispatch', form=form)


@mod.route('/ambulances', methods=['GET', 'POST'])
@flask_login.login_required
def ambulances():
    form = AddAmbulanceForm()

    if form.validate_on_submit():
        ambulance = Ambulance(form.license_plate.data, form.brand.data, form.model.data, form.mileage.data,
                              form.available.data)
        db.session.add(ambulance)
        db.session.commit()
        flask.flash('Ambulancia guardada correctamente', 'info')
        return flask.redirect(flask.url_for('application.panel.ambulances'))

    ambs = Ambulance.query.all()
    available = Ambulance.query.filter_by(available=True).all()

    return flask.render_template('app/panel/ambulance.html', title='Panel/Ambulancias', current_page='ambulances',
                                 form=form, ambulances=ambs, available=available)


@mod.route('/paramedics', methods=['GET', 'POST'])
@flask_login.login_required
def paramedics():
    form = AddParamedicForm()

    if form.validate_on_submit():
        param = Paramedic(form.dni.data, form.name.data, form.last_name.data, form.address.data, form.phone_number.data,
                          form.salary.data, form.available.data, 'PRM', form.specialization.data)
        db.session.add(param)
        db.session.commit()
        flask.flash('Paramédico agregado correctamente', 'info')
        return flask.redirect(flask.url_for('application.panel.paramedics'))

    params = Paramedic.query.all()
    available = Paramedic.query.filter_by(available=True).all()

    return flask.render_template('app/panel/paramedic.html', title='Panel/Paramédicos', current_page='paramedics',
                                 form=form, paramedics=params, available=available)


@mod.route('teams', methods=['GET', 'POST'])
@flask_login.login_required
def teams():
    form = AddTeamForm()

    if form.validate_on_submit():
        team = ParamedicTeam(form.type.data, form.available.data, form.fee.data)
        db.session.add(team)
        db.session.commit()
        return flask.redirect(flask.url_for('application.panel.teams'))

    pteams = ParamedicTeam.query.all()
    available = ParamedicTeam.query.filter_by(available=True).all()

    return flask.render_template('app/panel/team.html', title='Panel/Equipos', current_page='teams',
                                 form=form, teams=pteams, available=available)


@mod.route('/drivers', methods=['GET', 'POST'])
@flask_login.login_required
def drivers():
    form = AddDriverForm()

    if form.validate_on_submit():
        d = Driver(form.dni.data, form.name.data, form.last_name.data, form.address.data, form.phone_number.data,
                   form.salary.data, form.available.data, 'DRV', form.start_hour.data, form.end_hour.data)
        db.session.add(d)
        db.session.commit()
        flask.flash('Conductor agregado correctamente', 'info')
        return flask.redirect(flask.url_for('application.panel.drivers'))

    drvs = Driver.query.all()
    available = Driver.query.filter_by(available=True).all()

    return flask.render_template('app/panel/driver.html', title='Panel/Conductores', current_page='drivers',
                                 form=form, drivers=drvs, available=available)
