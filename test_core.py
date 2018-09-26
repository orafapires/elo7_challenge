#!/usr/bin/env python
# -*- coding: utf-8 -*- 

from app import elo7_challenge
import unittest
import json

app = elo7_challenge.test_client()

class TestElo7Challenge(unittest.TestCase):

    def setUp(self):
        app = elo7_challenge.test_client()
        self.response = app.get('/')

    def test_get(self):
        self.assertEqual(200, self.response.status_code)

    def test_post_error(self):
        item = {"name": "some_item"}
        self.response = app.post('http://localhost:5001/deploy-time',
                                 data=json.dumps(item),
                                 content_type='application/json')
        self.assertEqual(self.response.status_code, 400)

    def test_post_sucess(self):
        item = { "component" : "teste", "version" : "2.0", "accountable" : "eu", "status" : "teste"}
        self.response = app.post('http://localhost:5001/deploy-time',
                                 data=json.dumps(item),
                                 content_type='application/json')
        self.assertEqual(self.response.status_code, 200)