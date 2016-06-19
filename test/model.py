import unittest
from application.model.app_model import User
from application.model.workforce import ParamedicTeam


class UserTest(unittest.TestCase):
    def setUp(self):
        self.user = User('richin13', 'richin13@gmail.com', 'admin')
        self.user.id = 1000351

    def testRepr(self):
        assert str(self.user) == "User <'richin13'>"

    def test2(self):
        assert self.user.id == 1000351

    def test3(self):
        print(self.user.password)


class ParamedicsTeamTest(unittest.TestCase):
    def setUp(self):
        self.team = ParamedicTeam('SB', True, 0)

    def testPretty(self):
        assert self.team._pretty_type() == 'Soporte Básico'