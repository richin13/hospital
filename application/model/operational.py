from application import db


class Ambulance(db.Model):
    __table__ = 'ambulance'

    id = db.Column(db.Integer, primary_key=True)
    plate_number = db.Column(db.Integer, nullable=False, unique=True)
    brand = db.Column(db.String(45), nullable=False)
    model = db.Column(db.String(45), nullable=False)
    mileage = db.Column(db.Integer, nullable=False)
    available = db.Column(db.Boolean, nullable=False)

    driver_id = db.Column(db.Integer, db.ForeignKey('driver.id'))
    dispatches = db.relationship('Dispatch', backref='ambulance')

    def __init__(self, plate_number, brand, model, mileage=0, available=True):
        self.plate_number = plate_number
        self.brand = brand
        self.model = model
        self.mileage = mileage
        self.available = available


class Emergency(db.Model):
    __table__ = 'emergency'

    id = db.Column(db.Integer, primary_key=True)
    description = db.Column(db.String(60), nullable=False)
    type = db.Column(db.String(60), nullable=False)
    address = db.Column(db.String(128), nullable=False)
    canton_id = db.Column(db.Integer, db.ForeignKey('canton.id'), nullable=False)

    dispatch = db.relationship('Dispatch', backref='emergency', uselist=False)
    bill = db.relationship('Bill', backref='emergency', uselist=False)

    def __init__(self, description, _type, address, canton):
        self.description = description
        self.type = _type
        self.address = address
        self.canton_id = canton


class Dispatch(db.Model):
    __table__ = 'dispatch'

    ambulance_id = db.Column(db.Integer, db.ForeignKey('ambulance.id'), nullable=False)
    paramedics_team_id = db.Column(db.Integer, db.ForeignKey('paramedics_team.id'), nullable=False)
    emergency_id = db.Column(db.Integer, db.ForeignKey('emergency.id'), nullable=False)

    dispatch_hour = db.Column(db.DateTime, nullable=False)
    arrival_hour = db.Column(db.DateTime)
    distance = db.Column(db.Integer)
    status = db.Column(db.Integer, nullable=False)
    fee = db.Column(db.Float)

    __table_args__ = (
        db.PrimaryKeyConstraint('ambulance_id', 'paramedics_team_id', 'emergency_id'),
        db.CheckConstraint('status >= 1 AND status <= 5')
    )

    def __init__(self, ambulance, paramedics, emergency, dispatch_hour, arrival_hour=None, distance=0, status=1, fee=0):
        self.ambulance_id = ambulance
        self.paramedics_team_id = paramedics
        self.emergency_id = emergency
        self.dispatch_hour = dispatch_hour
        self.arrival_hour = arrival_hour
        self.distance = distance
        self.status = status
        self.fee = fee


class Patient(db.Model):
    __table__ = 'patient'

    dni = db.Column(db.Integer, primary_key=True, autoincrement=False)
    name = db.Column(db.String(45), nullable=False)
    last_name = db.Column(db.String(45), nullable=False)
    address = db.Column(db.String(128), nullable=False, default='Desconocida')
    phone_number = db.Column(db.String(10), nullable=False, default='N/A')

    insurance_id = db.Column(db.Integer, db.ForeignKey('insurance_plan.id', onupdate='cascade'))
    bills = db.relationship('Bill', backref='patient')

    def __init__(self, dni, name, last_name, address, phone_number, insurance=None):
        self.dni = dni
        self.name = name
        self.last_name = last_name
        self.address = address
        self.phone_number = phone_number
        self.insurance_id = insurance


class Bill(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    fee = db.Column(db.Float, nullable=False)
    covered_by_insurance = db.Column(db.Boolean, nullable=False)
    patient_id = db.Column(db.Integer, db.ForeignKey('patient.id'), nullable=False)
    emergency_id = db.Column(db.Integer, db.ForeignKey('emergency.id'), nullable=False)

    def __init__(self, fee, covered, patient, emergency):
        self.fee = fee
        self.covered_by_insurance = covered
        self.patient_id = patient
        self.emergency_id = emergency


class InsurancePlan(db.Model):
    __table__ = 'insurance_plan'

    id = db.Column(db.Integer, primary_key=True)
    category = db.Column(db.Integer, nullable=False)
    coverage_percentage = db.Column(db.Integer, nullable=False)
    description = db.Column(db.String(60), nullable=False)

    __table_args__ = (
        db.CheckConstraint('category >= 1 AND category <= 4')
    )

    def __init__(self, category, coverage_percentage, description):
        self.category = category
        self.coverage_percentage = coverage_percentage
        self.description = description