from application import db


class Province(db.Model):
    """
    province because this is Costa Rica baby! Change to `State´ to americanize it
    """
    __tablename__ = 'province'

    id = db.Column('id_province', db.Integer, nullable=False, primary_key=True, autoincrement=False)
    name = db.Column(db.String(30), nullable=False)
    cantons = db.relationship('Canton', backref='province')

    def __init__(self, pid, name):
        self.id = pid
        self.name = name

    def __repr__(self):
        return str(self.name)


class Canton(db.Model):
    """
    ugly af, change to `City´
    """
    __tablename__ = 'canton'

    id = db.Column('id_canton', db.Integer, nullable=False, primary_key=True)
    name = db.Column(db.String(60), nullable=False)
    province_id = db.Column(db.Integer, db.ForeignKey('province.id'), nullable=False)

    emergency = db.relationship('Canton', uselist=False)

    def __init__(self, name, province):
        self.name = name
        self.province_id = province

    def __repr__(self):
        return '%s, %s' % (self.name, self.province.name)
