from flask_wtf import Form
from wtforms import StringField
from wtforms import IntegerField
from wtforms import BooleanField
from wtforms.validators import length
from wtforms.validators import NumberRange
from wtforms.validators import DataRequired


class AddAmbulanceForm(Form):
    license_plate = StringField('Número de placa',
                                validators=[DataRequired(message='Debe especificar el número de placa')],
                                render_kw={'placeholder': 'Número de placa'})
    brand = StringField('Marca',
                        validators=[DataRequired(message='Debe especificar la marca del vehículo'),
                                    length(max=45, message='Marca inválida')],
                        render_kw={'placeholder': 'Marca'})
    model = StringField('Modelo',
                        validators=[DataRequired(message='Debe especificar el modelo del vehículo'),
                                    length(max=45, message='Modelo inválido')],
                        render_kw={'placeholder': 'Modelo'})
    mileage = IntegerField('Kilometraje',
                           validators=[NumberRange(min=0, message='El kilometraje debe ser positivo o 0')],
                           render_kw={'placeholder': 'Kilometraje'})
    available = BooleanField('Disponible')
