# -*- coding: utf-8 -*
import flask
import flask_login
from application import db
from application.forms.user_forms import RegistrationForm
from application.model.app_model import User

mod = flask.Blueprint('application.profile', __name__, url_prefix='/app/profile')


@mod.route('/', methods=['GET', 'POST'])
@flask_login.login_required
def index():
    form = RegistrationForm()

    if form.validate_on_submit():
        u = User.query.filter_by(username=flask_login.current_user.username).first()
        u.name = form.name.data
        u.last_name = form.last_name.data
        u.gender = form.gender.data
        u.email = form.email.data
        u.username = form.username.data
        u.password = form.password.data
        db.session.commit()
        flask.flash('Se guardaron los cambios', 'info')
        return flask.redirect(flask.url_for('application.profile.index'))

    jscripts = ['update_profile.js']

    return flask.render_template('app/profile/index.html', title=flask_login.current_user.username,
                                 current_page='index', user=flask_login.current_user, form=form, jscripts=jscripts)


@mod.route('/users', methods=['GET', 'POST'])
@flask_login.login_required
def users():
    form = RegistrationForm()

    if form.validate_on_submit():
        u = User(form.name.data, form.last_name.data, form.gender.data, form.email.data, form.username.data,
                 form.password.data)
        db.session.add(u)
        db.session.commit()
        return flask.redirect(flask.url_for('application.profile.users'))

    us = User.query.all()

    return flask.render_template('app/profile/users.html', title=u'Perfil/Gestión de usuarios', current_page='users',
                                 form=form, users=us)
