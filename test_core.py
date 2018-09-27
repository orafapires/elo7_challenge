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
    
    def test_string_response(self):
        self.assertEqual("Index Page!", self.response.data.decode('utf-8'))

    def test_post_error(self):
        item = {"name": "some_item"}
        response = '{"message":"Bad request parameters!","ok":false}\n'
        self.response = app.post('http://localhost:5000/deploy-time',
                                 data=json.dumps(item),
                                 content_type='application/json')
        self.assertEqual(self.response.status_code, 400)
        self.assertEqual(response, self.response.data.decode('utf-8'))

    def test_post_sucess(self):
        item = { "component" : "teste", "version" : "2.0", "accountable" : "eu", "status" : "teste"}
        response = '{"message":"Deploy data stored successfully.","ok":true}\n'
        self.response = app.post('http://localhost:5000/deploy-time',
                                 data=json.dumps(item),
                                 content_type='application/json')
        self.assertEqual(self.response.status_code, 200)
        self.assertEqual(response, self.response.data.decode('utf-8'))

    