#!/usr/bin/env python
# -*- coding: utf-8 -*- 

from flask import Flask
from flask import request
from flask import jsonify
from datetime import datetime
from flask_pymongo import PyMongo
import pandas as pd
from pymongo import MongoClient
from flask import send_file

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

def connect_mongo(host, port, username, password, db):
    if username and password:
        mongo_uri = 'mongodb://%s:%s@%s:%s/%s' % (username, password, host, port, db)
        conn = MongoClient(mongo_uri)
    else:
        conn = MongoClient(host, port)
    return conn[db]

def read_mongo(db, collection, query={}, host='mongo', port=27017, username=None, password=None, no_id=True):
    db = connect_mongo(host=host, port=port, username=username, password=password, db=db)
    cursor = db[collection].find(query)
    df =  pd.DataFrame(list(cursor))
    if no_id and '_id' in df:
        del df['_id']
    return df

def create_csv():
    df = read_mongo('elo7_challenge', 'deploytimecollection', {}, 'mongo', 27017)
    df.to_csv('deploys.csv', index=False)

@elo7_challenge.route('/deploys-export')
def deploys_export():
    create_csv()
    return send_file('deploys.csv',
                     mimetype='text/csv',
                     attachment_filename='deploys.csv',
                     as_attachment=True)

if __name__ == '__main__':
    elo7_challenge.run(host='0.0.0.0', debug=True)