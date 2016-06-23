# -*- coding: utf-8 -*
from flask_wtf import Form
from wtforms import StringField, TextAreaField, IntegerField, BooleanField, FloatField, DateTimeField, SelectField, \
    FormField
from wtforms.validators import DataRequired, NumberRange, length, Optional


class AddEmployeeForm(Form):
    dni = IntegerField(u'Cédula', validators=[DataRequired(u'Debe especificar el número de cedula')],
                       render_kw={'placeholder': u'Cédula'})
    name = StringField('Nombre', validators=[DataRequired('Debe especificar el nombre')],
                       render_kw={'placeholder': 'Nombre'})
    last_name = StringField('Apellido', validators=[DataRequired('Debe especificar el apellido')],
                            render_kw={'placeholder': 'Apellido'})
    address = TextAreaField(u'Dirección', validators=[length(max=128)],
                            render_kw={'placeholder': u'Dirección'})
    phone_number = StringField(u'Teléfono', validators=[length(max=10)],
                               render_kw={'placeholder': u'Teléfono'})
    salary = FloatField('Salario', validators=[DataRequired('Debe especificar el salario'), NumberRange(min=0)],
                        render_kw={'placeholder': 'Salario'})
    available = BooleanField('Disponible')


class AddEmergencyForm(Form):
    e_description = TextAreaField(u'Descripción')
    e_type = StringField('Tipo')
    address = TextAreaField(u'Dirección')
    province = SelectField('Provincia', coerce=int)
    canton = SelectField(u'Cantón', coerce=int)
    pass


class DispatchForm(Form):
    emergency = FormField(AddEmergencyForm)
    ambulance = SelectField('Ambulancia', coerce=int)
    team = SelectField('Equipo', coerce=int)
    dispatch_hour = DateTimeField('Hora de salida (d-m-a H:M)', format='%d-%m-%Y %H:%M')
    arrival_hour = DateTimeField('Hora de entrada (d-m-a H:M)', format='%d-%m-%Y %H:%M', validators=[Optional()])
    distance = IntegerField('Distancia')
    status = SelectField('Estado',
                         choices=[('1', 'En ruta'), ('2', 'En sitio'), ('3', 'Volviendo'), ('4', 'Completado'),
                                  ('5', 'Cancelado')])
    fee = FloatField('Cargos')


class AddDriverForm(AddEmployeeForm):
    license_type = SelectField('Tipo de licencia', choices=[('B1', 'B-1'), ('B2', 'B-2'), ('B3', 'B-3'), ('C2', 'C-2'),
                                                            ('D1', 'D-1'), ('D2', 'D-2'), ('D3', 'D-3'), ('E1', 'E-1')])
    start_hour = DateTimeField('Hora de entrada (HH:MM)', format='%H:%M')
    end_hour = DateTimeField('Hora de salida (HH:MM)', format='%H:%M')


class AddParamedicForm(AddEmployeeForm):
    specialization = SelectField(u'Especilización',
                                 choices=[('PAB', 'PAB'), ('APA', 'APA'), ('AEM', 'AEM'), ('TEM', 'TEM')])
    team = SelectField('Equipo', coerce=int)


class AddTeamForm(Form):
    type = SelectField('Tipo', choices=[('SB', u'Soporte Básico'), ('SA', 'Soporte Avanzado'), ('SV', 'Soporte Vital')])
    available = BooleanField('Equipo disponible?')
    fee = FloatField('Cargos', validators=[])


class AddAmbulanceForm(Form):
    license_plate = IntegerField(u'Número de placa',
                                 validators=[DataRequired(message=u'Debe especificar el número de placa')],
                                 render_kw={'placeholder': u'Número de placa'})
    brand = StringField('Marca',
                        validators=[DataRequired(message=u'Debe especificar la marca del vehículo'),
                                    length(max=45, message=u'Marca inválida')],
                        render_kw={'placeholder': 'Marca'})
    model = StringField('Modelo',
                        validators=[DataRequired(message=u'Debe especificar el modelo del vehículo'),
                                    length(max=45, message=u'Modelo inválido')],
                        render_kw={'placeholder': 'Modelo'})
    mileage = IntegerField('Kilometraje',
                           validators=[NumberRange(min=0, message='El kilometraje debe ser positivo o 0')],
                           render_kw={'placeholder': 'Kilometraje'})
    driver = SelectField('Conductor', coerce=int)
