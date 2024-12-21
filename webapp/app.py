from flask import *
import json

import shapefile
import io
import re

global create_roadData
create_roadData = {}

road_path = "webapp/shapefile/complete_roads.shp"

sf = shapefile.Reader(road_path)
features = []
for shape in sf.shapeRecords():
    geometry = shape.shape.__geo_interface__
    properties = shape.record.as_dict()
    features.append({
        'geometry': geometry,
        'properties': properties
    })

with open('webapp/json/road.json', 'w') as f:
    json.dump(features, f, indent=4)

app = Flask(__name__)

@app.route('/')
def index():
    return render_template('index.html')

@app.route("/roads")
def roads():
    with open('webapp/json/road.json', 'r') as f:
        data = json.load(f)
    return jsonify(data)

@app.route('/create_road_page')
def create_road():
    return render_template('map.html')

@app.route('/createRoadData', methods=['POST'])
def createRoadData():
    data = request.get_json()
    print(data)
    global create_roadData
    create_roadData = data
    return jsonify(data)

@app.route('/get_createRoadData', methods=['GET'])
def get_createRoadData():
    global create_roadData
    return json.dumps(create_roadData)

if __name__ == '__main__':
    app.run(port=5000,debug=True)


