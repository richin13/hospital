import os
import application
import unittest
import tempfile


class HospitalTestCase(unittest.TestCase):
    def setUp(self):
        self.bd_tp, application.app.config['DATABASE'] = tempfile.mktemp()
        application.app.config['TESTING'] = True
        self.app = application.app.test_client()

        with application.app.app_context():
            application.init_db()

        pass

    def tearDown(self):
        pass