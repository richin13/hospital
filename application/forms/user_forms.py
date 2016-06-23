# -*- coding: utf-8 -*
from flask_wtf import Form
from wtforms import StringField, PasswordField, SelectField
from wtforms.validators import DataRequired, Email


class LoginForm(Form):
    username_email = StringField(u'Usuario/Correo electrónico',
                                 validators=[
                                     DataRequired(message=u'El campo de usuario/correo electrónico es requerido')],
                                 render_kw={'placeholder': 'Nombre de usuario o e-mail'})
    password = PasswordField('Contraseña', validators=[DataRequired(message=u'La contraseña es requerida')],
                             render_kw={'placeholder': u'Contraseña'})


class RegistrationForm(Form):
    name = StringField('Nombre', validators=[DataRequired(message='Debe especificar el nombre')],
                       render_kw={'placeholder': 'Nombre'})
    last_name = StringField('Apellido', validators=[DataRequired(message='Debe especificar el apellido')],
                            render_kw={'placeholder': 'Apellido'})
    gender = SelectField(u'Género', choices=[('M', 'Masculino'), ('F', 'Femenino')])
    email = StringField(u'Correo electrónico',
                        validators=[DataRequired(message=u'El correo electrónico es requerido'),
                                    Email(message=u'Debe ingresar un correo electrónico válido')],
                        render_kw={'placeholder': u'Correo electrónico'})
    username = StringField('Nombre de usuario',
                           validators=[DataRequired(message='Debe especificar el nombre de usuario')],
                           render_kw={'placeholder': 'Nombre de usuario'})
    password = PasswordField(u'Contraseña',
                             validators=[DataRequired(message=u'Debe especificar una contraseña válida')],
                             render_kw={'placeholder': u'Contraseña'})
