from flask_wtf import Form
from wtforms import StringField, PasswordField
from wtforms.validators import DataRequired, Email


class LoginForm(Form):
    email = StringField('Correo electrónico',
                        validators=[DataRequired(message='El correo electrónico es requerido'),
                                    Email(message='Debe ingresar un correo electrónico válido')],
                        render_kw={'placeholder': 'Correo electrónico'})
    password = PasswordField('Contraseña', validators=[DataRequired(message='La contraseña es requerida')],
                             render_kw={'placeholder': 'Contraseña'})
