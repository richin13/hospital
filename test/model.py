import unittest
from application.model.app_model import User


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
