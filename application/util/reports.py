# -*- coding: utf-8 -*
from application import db
from application.model.operational import Ambulance

# Report tuples (<object>, <amount, resource>)
from application.model.workforce import ParamedicTeam


def most_dispatched_ambulance():
    query = "SELECT TOP 1 id_ambulance, COUNT(*) FROM dispatch GROUP BY id_ambulance ORDER BY count(*) DESC"
    result = db.engine.execute(query).fetchall()
    return Ambulance.query.get(result[0][0]), result[0][1]


def most_profitable_ambulance():
    query = "SELECT TOP 1 id_ambulance, SUM(fee) FROM dispatch GROUP BY id_ambulance ORDER BY SUM(fee) DESC"
    result = db.engine.execute(query).fetchall()
    return Ambulance.query.get(result[0][0]), result[0][1]


def most_dispatched_paramedic_team():
    query = "SELECT TOP 1 id_params_team, COUNT(*) FROM dispatch GROUP BY id_params_team ORDER BY count(*) DESC"
    result = db.engine.execute(query).fetchall()
    return ParamedicTeam.query.get(result[0][0]), result[0][1]


def most_profitable_paramedic_team():
    query = "SELECT TOP 1 id_params_team, SUM(fee) FROM dispatch GROUP BY id_params_team ORDER BY SUM(fee) DESC"
    result = db.engine.execute(query).fetchall()
    return ParamedicTeam.query.get(result[0][0]), result[0][1]


def top_ambulances():
    query = "SELECT TOP 5 plate_number, COUNT(*), SUM(fee) " \
            "FROM dispatch " \
            "INNER JOIN ambulance " \
            "ON dispatch.id_ambulance=ambulance.id_ambulance " \
            "GROUP BY plate_number, status HAVING status = 4 ORDER BY SUM(fee) DESC"

    result = db.engine.execute(query).fetchall()
    return result


def top_teams():
    query = "SELECT TOP 5 dispatch.id_params_team, type, SUM(fee) " \
            "FROM dispatch " \
            "INNER JOIN paramedics_team " \
            "ON dispatch.id_params_team=paramedics_team.id_params_team " \
            "GROUP BY dispatch.id_params_team, type ORDER BY SUM(fee) DESC"

    result = db.engine.execute(query).fetchall()
    return result
