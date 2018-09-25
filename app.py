#!/usr/bin/env python
# -*- coding: utf-8 -*- 

from flask import Flask
from flask import request
from flask import jsonify
from datetime import datetime
from flask_pymongo import PyMongo

elo7_challenge = Flask('elo7_challenge')
elo7_challenge.config["MONGO_URI"] = "mongodb://mongo:27017/elo7_challenge"
mongo = PyMongo(elo7_challenge)

@elo7_challenge.route('/')
def index():
    return 'Index Page!'

@elo7_challenge.route('/deploy-time', methods=['POST'])
def deploy_time():
    data = request.get_json()
    component = data.get('component')
    version = data.get('version')
    accountable = data.get('accountable')
    status = data.get('status')
    date = datetime.now().strftime("%Y-%m-%d %H:%M")
    expected = {'component': component, 'version': version, 'accountable': accountable, 'status': status}
    if data != expected:
        return jsonify({'ok': False, 'message': 'Bad request parameters!'}), 400
    elif not component or not version or not accountable or not status:
        return jsonify({'ok': False, 'message': 'Bad request parameters!'}), 400
    else:
        deploytimecollection = mongo.db.deploytimecollection
        deploytimecollection.insert_one({'component': component, 'version': version, 'accountable': accountable, 'status': status, 'date': date})
        return jsonify({'ok': True, 'message': 'Deploy data stored successfully.'}), 200

if __name__ == '__main__':
    elo7_challenge.run(host='0.0.0.0', debug=True)