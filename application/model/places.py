# -*- coding: utf-8 -*
from application import db


class Province(db.Model):
    """
    province because this is Costa Rica baby! Change to `State´ to americanize it
    """
    __tablename__ = 'province'

    id = db.Column('id_province', db.Integer, primary_key=True, autoincrement=False)
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

    id = db.Column('id_canton', db.Integer, primary_key=True)
    name = db.Column(db.String(60), nullable=False)
    id_province = db.Column(db.Integer, db.ForeignKey('province.id_province'), nullable=False)

    emergencies = db.relationship('Emergency', back_populates='canton')

    def __init__(self, name, province):
        self.name = name
        self.id_province = province

    def __repr__(self):
        return '%s, %s' % (self.name, self.province.name)
