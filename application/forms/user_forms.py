from flask_wtf import Form
from wtforms import StringField, PasswordField, SelectField
from wtforms.validators import DataRequired, Email


class LoginForm(Form):
    email = StringField('Correo electrónico',
                        validators=[DataRequired(message='El correo electrónico es requerido'),
                                    Email(message='Debe ingresar un correo electrónico válido')],
                        render_kw={'placeholder': 'Correo electrónico'})
    password = PasswordField('Contraseña', validators=[DataRequired(message='La contraseña es requerida')],
                             render_kw={'placeholder': 'Contraseña'})


class RegistrationForm(Form):
    name = StringField('Nombre', validators=[DataRequired(message='Debe especificar el nombre')],
                       render_kw={'placeholder': 'Nombre'})
    last_name = StringField('Apellido', validators=[DataRequired(message='Debe especificar el apellido')],
                            render_kw={'placeholder': 'Apellido'})
    genre = SelectField('Género', choices=[('M', 'Masculino'), ('F', 'Femenino')])
    email = StringField('Correo electrónico',
                        validators=[DataRequired(message='El correo electrónico es requerido'),
                                    Email(message='Debe ingresar un correo electrónico válido')],
                        render_kw={'placeholder': 'Correo electrónico'})
    username = StringField('Nombre de usuario',
                           validators=[DataRequired(message='Debe especificar el nombre de usuario')],
                           render_kw={'placeholder': 'Nombre de usuario'})
    password = PasswordField('Contraseña', validators=[DataRequired(message='Debe especificar una contraseña válida')],
                           render_kw={'placeholder': 'Contraseña'})
