# -*- coding: utf-8 -*
from application import db


class Ambulance(db.Model):
    __tablename__ = 'ambulance'

    id = db.Column('id_ambulance', db.Integer, primary_key=True)
    plate_number = db.Column(db.Integer, nullable=False, unique=True)
    brand = db.Column(db.String(45), nullable=False)
    model = db.Column(db.String(45), nullable=False)
    mileage = db.Column(db.Integer, nullable=False)
    available = db.Column(db.Boolean, nullable=False)

    driver_id = db.Column(db.Integer, db.ForeignKey('driver.dni'))

    driver = db.relationship('Driver', back_populates='ambulance')
    dispatches = db.relationship('Dispatch', backref='ambulance')

    def __init__(self, plate_number, brand, model, mileage=0, available=True):
        self.plate_number = plate_number
        self.brand = brand
        self.model = model
        self.mileage = mileage
        self.available = available

    def __repr__(self):
        return '%s %s, #%s' %(self.brand, self.model, self.plate_number)


class Emergency(db.Model):
    __tablename__ = 'emergency'

    id = db.Column('id_emergency', db.Integer, primary_key=True)
    description = db.Column(db.String(60), nullable=False)
    type = db.Column(db.String(60), nullable=False)
    address = db.Column(db.String(128), nullable=False)
    id_canton = db.Column(db.Integer, db.ForeignKey('canton.id_canton'), nullable=False)

    canton = db.relationship('Canton', back_populates='emergencies')
    dispatch = db.relationship('Dispatch', backref='emergency', uselist=False)
    bill = db.relationship('Bill', backref='emergency', uselist=False)

    def __init__(self, description, _type, address, canton):
        self.description = description
        self.type = _type
        self.address = address
        self.id_canton = canton


class Dispatch(db.Model):
    __tablename__ = 'dispatch'

    id_ambulance = db.Column(db.Integer, db.ForeignKey('ambulance.id_ambulance'), nullable=False)
    id_params_team = db.Column(db.Integer, db.ForeignKey('paramedics_team.id_params_team'), nullable=False)
    id_emergency = db.Column(db.Integer, db.ForeignKey('emergency.id_emergency'), nullable=False)

    dispatch_hour = db.Column(db.DateTime, nullable=False)
    arrival_hour = db.Column(db.DateTime)
    distance = db.Column(db.Integer)
    status = db.Column(db.Integer, nullable=False)
    fee = db.Column(db.Float)

    __table_args__ = (
        db.PrimaryKeyConstraint('id_ambulance', 'id_params_team', 'id_emergency'),
        db.CheckConstraint('status >= 1 AND status <= 5')
    )

    def __init__(self, ambulance, paramedics, emergency, dispatch_hour, arrival_hour=None, distance=0, status=1, fee=0):
        self.id_ambulance = ambulance
        self.id_params_team = paramedics
        self.id_emergency = emergency
        self.dispatch_hour = dispatch_hour
        self.arrival_hour = arrival_hour
        self.distance = distance
        self.status = status
        self.fee = fee

    def pretty_status(self):
        if self.status == 1:
            return 'En ruta'
        elif self.status == 2:
            return 'En el sitio'
        elif self.status == 3:
            return 'Volviendo'
        elif self.status == 4:
            return 'Completado'
        elif self.status == 5:
            return 'Cancelado'
        else:
            raise AttributeError('status should be some number between 1 and 5')


class Patient(db.Model):
    __tablename__ = 'patient'

    dni = db.Column('id_patient', db.Integer, primary_key=True, autoincrement=False)
    name = db.Column(db.String(45), nullable=False)
    last_name = db.Column(db.String(45), nullable=False)
    address = db.Column(db.String(128), nullable=False, default='Desconocida')
    phone_number = db.Column(db.String(10), nullable=False, default='N/A')

    insurance_id = db.Column(db.Integer, db.ForeignKey('insurance_plan.id_insurance_plan', onupdate='cascade'))
    bills = db.relationship('Bill', backref='patient')

    def __init__(self, dni, name, last_name, address, phone_number, insurance=None):
        self.dni = dni
        self.name = name
        self.last_name = last_name
        self.address = address
        self.phone_number = phone_number
        self.insurance_id = insurance


class Bill(db.Model):
    __tablename__ = 'patient_bill'

    id = db.Column('id_bill', db.Integer, primary_key=True)
    fee = db.Column(db.Float, nullable=False)
    covered_by_insurance = db.Column(db.Boolean, nullable=False)

    id_patient = db.Column(db.Integer, db.ForeignKey('patient.id_patient'), nullable=False)
    id_emergency = db.Column(db.Integer, db.ForeignKey('emergency.id_emergency'), nullable=False)

    def __init__(self, fee, covered, patient, emergency):
        self.fee = fee
        self.covered_by_insurance = covered
        self.id_patient = patient
        self.id_emergency = emergency


class InsurancePlan(db.Model):
    __tablename__ = 'insurance_plan'

    id = db.Column('id_insurance_plan', db.Integer, primary_key=True)
    category = db.Column(db.Integer, nullable=False)
    coverage_percentage = db.Column(db.Integer, nullable=False)
    description = db.Column(db.String(60), nullable=False)

    __table_args__ = (
        db.CheckConstraint('category >= 1 AND category <= 4'),
    )

    def __init__(self, category, coverage_percentage, description):
        self.category = category
        self.coverage_percentage = coverage_percentage
        self.description = description
