from application import db


class Employee(db.Model):
    """
    An employee of the hospital. It abstracts the information of the different types of
    employees that the hospital has.
    """
    __tablename__ = 'employee'

    dni = db.Column(db.Integer, primary_key=True, autoincrement=False)
    name = db.Column(db.String(45), nullable=False)
    last_name = db.Column(db.String(45), nullable=False)
    address = db.Column(db.String(128), nullable=False, default='Desconocida')
    phone_number = db.Column(db.String(10), unique=True, default='N/A')
    salary = db.Column(db.Float, nullable=False)
    available = db.Column(db.Boolean, nullable=False)
    type = db.Column(db.String(3), nullable=False)

    __mapper_args__ = {
        'polymorphic_identity': 'employee',
        'polymorphic_on': type
    }

    __table_args__ = (
        db.CheckConstraint('salary > 0')
    )

    def __init__(self, dni, name, ln, addr, pn, salary, available, _type):
        self.dni = dni
        self.name = name
        self.last_name = ln
        self.address = addr
        self.phone_number = pn
        self.salary = salary,
        self.available = available,
        self.type = _type


class Driver(Employee):
    """
    An ambulance driver
    """
    __tablename__ = 'driver'

    dni = db.Column(db.Integer, db.ForeignKey('employee.id'), primary_key=True)
    start_hour = db.Column(db.Time)
    end_hour = db.Column(db.Time)

    ambulance = db.relationship('Ambulance', backref='driver', uselist=False)

    __mapper_args__ = {
        'polymorphic_identity': 'driver'
    }

    def __init__(self, dni, name, ln, addr, pn, salary, available, _type, sh, eh):
        super(Driver, self).__init__(dni, name, ln, addr, pn, salary, available, _type)
        self.start_hour = sh
        self.end_hour = eh


class Paramedic(Employee):
    __tablename__ = 'paramedic'

    dni = db.Column(db.Integer, db.ForeignKey('employee.id'), primary_key=True)
    specialization = db.Column(db.CHAR(3), nullable=False, default='UNK')
    team_id = db.Column(db.Integer, db.ForeignKey('paramedic_team.id'))

    __mapper_args__ = {
        'polymorphic_identity': 'paramedic'
    }

    __table_args__ = (
        db.CheckConstraint("""
            specialization = 'PAB' OR
            specialization = 'APA' OR
            specialization = 'AEM' OR
            specialization = 'TEM'""")
    )

    def __init__(self, dni, name, ln, addr, pn, salary, available, _type, sh, eh):
        super(Paramedic, self).__init__(dni, name, ln, addr, pn, salary, available, _type)
        self.start_hour = sh
        self.end_hour = eh


class ParamedicTeam(db.Model):
    __tablename__ = 'paramedics_team'

    id = db.Column(db.Integer, nullable=False, primary_key=True)
    type = db.Column(db.String(2), nullable=False)
    available = db.Column(db.Boolean, nullable=False)
    operation_fee = db.Column(db.Float, nullable=False)

    members = db.relationship('Paramedic', backref='team')
    dispatches = db.relationship('Dispatch', backref='paramedics_team')

    __table_args__ = (
        db.CheckConstraint("""
            type = 'SB' OR
            type = 'SA' OR
            type = 'SV'""")
    )

    def __init__(self, _type, available, of):
        self.type = _type
        self.available = available
        self.operation_fee = of
