import flask
import flask_login
import application.util.reports as report
from application import db
from application.forms.panel_forms import AddAmbulanceForm, AddDriverForm, AddParamedicForm, AddTeamForm, \
    DispatchForm
from application.model.operational import Ambulance, Emergency, Dispatch
from application.model.workforce import Driver, Paramedic, ParamedicTeam
from application.model.places import Province, Canton
from sqlalchemy import desc

# custom filter
from application.util import filters

mod = flask.Blueprint('application.panel', __name__, url_prefix='/app/panel')


@mod.route('/')
@flask_login.login_required
def index():
    emergencies = Emergency.query.all()
    _teams = ParamedicTeam.query.all()
    _paramedics = Paramedic.query.all()
    _ambulances = Ambulance.query.all()
    _drivers = Driver.query.all()
    dispatches = Dispatch.query.all()

    return flask.render_template('app/panel/index.html', title='Panel', current_page='index',
                                 emergencies=emergencies,
                                 teams=_teams,
                                 paramedics=_paramedics,
                                 ambulances=_ambulances,
                                 drivers=_drivers,
                                 dispatches=dispatches)


@mod.route('/dispatch', methods=['GET', 'POST'])
@flask_login.login_required
def dispatch():
    form = DispatchForm()

    form.emergency.province.choices = [(p.id, p.name) for p in Province.query.order_by('id_province')]
    form.emergency.canton.choices = [(c.id, c.name) for c in Canton.query.order_by('name')]

    form.ambulance.choices = [(a.id, a.plate_number) for a in Ambulance.query.order_by('plate_number')]
    form.team.choices = [(t.id, str(t)) for t in ParamedicTeam.query.order_by('id_params_team')]

    if form.validate_on_submit():
        e = Emergency(form.emergency.e_description.data, form.emergency.e_type.data, form.emergency.address.data,
                      form.emergency.canton.data)
        db.session.add(e)
        db.session.commit()

        d = Dispatch(form.ambulance.data, form.team.data, e.id, form.dispatch_hour.data, form.arrival_hour.data,
                     form.distance.data, form.status.data, form.fee.data)
        db.session.add(d)
        db.session.commit()
        return flask.redirect(flask.url_for('application.panel.dispatch'))

    __complete(flask.request.args.get('complete'))
    __cancel(flask.request.args.get('cancel'))

    dispatches = Dispatch.query.all()

    return flask.render_template('app/panel/dispatch.html', title='Panel/Despacho', current_page='dispatch', form=form,
                                 dispatches=dispatches)


@mod.route('/ambulances', methods=['GET', 'POST'])
@flask_login.login_required
def ambulances():
    form = AddAmbulanceForm()

    form.driver.choices = [(d.dni, str(d)) for d in Driver.query.order_by('name')]

    if form.validate_on_submit():
        ambulance = Ambulance(form.license_plate.data, form.brand.data, form.model.data, form.mileage.data,
                              True)
        ambulance.driver_id = form.driver.data
        db.session.add(ambulance)
        db.session.commit()
        flask.flash('Ambulancia guardada correctamente', 'info')
        return flask.redirect(flask.url_for('application.panel.ambulances'))

    _ambulances = Ambulance.query.all()

    return flask.render_template('app/panel/ambulance.html', title='Panel/Ambulancias', current_page='ambulances',
                                 form=form, ambulances=_ambulances)


@mod.route('/paramedics', methods=['GET', 'POST'])
@flask_login.login_required
def paramedics():
    form = AddParamedicForm()

    form.team.choices = [(t.id, str(t)) for t in ParamedicTeam.query.order_by('id_params_team')]

    if form.validate_on_submit():
        param = Paramedic(form.dni.data, form.name.data, form.last_name.data, form.address.data, form.phone_number.data,
                          form.salary.data, True, 'PRM', form.specialization.data)
        param.id_params_team = form.team.data
        db.session.add(param)
        db.session.commit()
        flask.flash('Paramédico agregado correctamente', 'info')
        return flask.redirect(flask.url_for('application.panel.paramedics'))

    _paramedics = Paramedic.query.all()

    return flask.render_template('app/panel/paramedic.html', title='Panel/Paramédicos', current_page='paramedics',
                                 form=form, paramedics=_paramedics)


@mod.route('/teams', methods=['GET', 'POST'])
@flask_login.login_required
def teams():
    form = AddTeamForm()

    if form.validate_on_submit():
        team = ParamedicTeam(form.type.data, True, form.fee.data)
        db.session.add(team)
        db.session.commit()
        return flask.redirect(flask.url_for('application.panel.teams'))

    _teams = ParamedicTeam.query.all()

    return flask.render_template('app/panel/team.html', title='Panel/Equipos', current_page='teams',
                                 form=form, teams=_teams)


@mod.route('/drivers', methods=['GET', 'POST'])
@flask_login.login_required
def drivers():
    form = AddDriverForm()

    if form.validate_on_submit():
        d = Driver(form.dni.data, form.name.data, form.last_name.data, form.address.data, form.phone_number.data,
                   form.salary.data, True, 'DRV', form.license_type.data, form.start_hour.data, form.end_hour.data)
        db.session.add(d)
        db.session.commit()
        flask.flash('Conductor agregado correctamente', 'info')
        return flask.redirect(flask.url_for('application.panel.drivers'))

    _drivers = Driver.query.all()

    return flask.render_template('app/panel/driver.html', title='Panel/Conductores', current_page='drivers',
                                 form=form, drivers=_drivers)


@mod.route('/reports', methods=['GET'])
@flask_login.login_required
def reports():
    top_km_amb = Ambulance.query.order_by(desc(Ambulance.mileage)).limit(1).all()
    most_dispatched_ambulance = report.most_dispatched_ambulance()
    most_profitable_ambulance = report.most_profitable_ambulance()

    top_cost_param_team = ParamedicTeam.query.order_by(desc(ParamedicTeam.operation_fee)).limit(1).all()
    most_dispatched_param_team = report.most_dispatched_paramedic_team()
    most_profitable_param_team = report.most_profitable_paramedic_team()

    return flask.render_template('app/panel/reports.html', title='Panel/Reportes', current_page='reports',
                                 top_km_amb=top_km_amb,
                                 most_dispatched_amb=most_dispatched_ambulance,
                                 most_profitable_amb=most_profitable_ambulance,
                                 most_expensive_team=top_cost_param_team,
                                 most_dispatched_team=most_dispatched_param_team,
                                 most_profitable_team=most_profitable_param_team)


def __complete(dispatch_emergency):
    if dispatch_emergency:
        _dispatch = Dispatch.query.filter_by(id_emergency=dispatch_emergency).first_or_404()

        if _dispatch and _dispatch.status != 4:
            _dispatch.status = 4
            db.session.commit()


def __cancel(dispatch_emergency):
    if dispatch_emergency:
        _dispatch = Dispatch.query.filter_by(id_emergency=dispatch_emergency).first_or_404()

        if _dispatch and _dispatch.status != 5:
            _dispatch.status = 5
            db.session.commit()
