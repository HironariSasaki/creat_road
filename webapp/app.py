from flask import *
import json

import shapefile
import io
import re

global create_roadData
create_roadData = {}


road_path = "webapp/shapefile/complete_roads.shp"
file_path = 'webapp/json/road.json'

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

#指定した road_id に対応するデータを削除する関数
def delete_road(file_path, road_id):
    # JSONファイルを読み込む
    with open(file_path, 'r') as file:
        data = json.load(file)
    # 指定された road_id に対応するデータを削除
    data = [feature for feature in data if feature['properties']['road_id'] != road_id]
    
    # JSONファイルに書き戻す
    with open(file_path, 'w') as file:
        json.dump(data, file, indent=4)

#新たに作製した道路データを追加する関数
def add_road(file_path, new_road):
    with open(file_path, "r") as file:
        data = json.load(file)
    
    data.append(new_road)
    with open(file_path, "w") as file:
        json.dump(data, file, indent=4)



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
    if len(data) != 0:
        data["status"] = "new_road"
        global create_roadData
        create_roadData = data
    elif len(data) == 0:
        data["status"] = "no_new_road"

    return jsonify(data)


@app.route('/get_createRoadData', methods=['GET'])
def get_createRoadData():
    global create_roadData
    return json.dumps(create_roadData)

@app.route('/new_road_data_from_gama', methods=['POST'])
def new_road_data_from_gama():
    data = request.get_json()
    print(data)
    delete_road_id = data["delete_road"]
    for i in delete_road_id:
        delete_road(file_path, i)
    
    add_road_data = data["add_road"]
    for i in add_road_data:
        new_road = {
            "geometry": {
                "type": "LineString",
                "coordinates": i["coordinates"]
            },
            "properties": {
                "fid": None,
                "linkno": None,
                "oneway": i["properties"]["oneway"],
                "netlevel": None,
                "maxspeed": i["properties"]["maxspeed"],
                "maxspeed_2": None,
                "planesu": None,
                "mlanesu": None,
                "fukuin": None,
                "road_id": i["properties"]["road_id"],
                "length": None
            }
        }
        add_road(file_path, new_road)
    return json.dumps({"status": "success"})


if __name__ == '__main__':
    app.run(port=5000,debug=True)



