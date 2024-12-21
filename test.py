# import shapefile
# import json

# road_path = "webapp/shapefile/complete_node.shp"

# sf = shapefile.Reader(road_path)
# features = []
# for shape in sf.shapeRecords():
#     geometry = shape.shape.__geo_interface__
#     properties = shape.record.as_dict()
#     features.append({
#         'geometry': geometry,
#         'properties': properties
#     })

# with open('webapp/json/node.json', 'w') as f:
#     json.dump(features, f, indent=4)

# scale = 1.0 
# scale2 = 1.1
# offsetX = -13550000
# offsetY = -3480000
# xmove =6165
# ymove = 1000
# canvasHeight = 600
#const px = x + offsetX -xmove;
#const py = canvasHeight-(y + offsetY -ymove);

# x = px - (offsetX - xmove)
#x = px -166.96956176683307
# y = -py + canvasHeight + ymove - offsetY
#y = 610.0832631918602 - py

# print(460.1362307779491+13556165)
# print(12.083408452104777+3481600)
#13556625.136230778 3481612.083408452
#460.1362307779491 -12.083408452104777

# import math

# def calculate_distance(x1, y1, x2, y2):
#     return math.sqrt((x2 - x1) ** 2 + (y2 - y1) ** 2)

# def calculate_scaling_factor(original_coords, scaled_coords):
#     (x1, y1), (x2, y2) = original_coords
#     (x1_scaled, y1_scaled), (x2_scaled, y2_scaled) = scaled_coords
    
#     original_distance = calculate_distance(x1, y1, x2, y2)
#     scaled_distance = calculate_distance(x1_scaled, y1_scaled, x2_scaled, y2_scaled)
    
#     if original_distance == 0:
#         raise ValueError("Original coordinates are the same point, cannot calculate scaling factor.")
    
#     scaling_factor = scaled_distance / original_distance
#     return scaling_factor

#元の座標
original_coords = ((13556693.330675768 , 3481301.00007263),(13556660.358453281 , 3481301.00007263) )

# 縮小後の座標
scaled_coords = ( (361.3611140009016 , 311.0833358219825), (328.3888915143907 , 311.0833358219825))

# original_coords = ((100, 100), (200, 200))
# scaled_coords = ((50, 50), (100, 100))

# 縮小率を計算
# scaling_factor = calculate_scaling_factor(original_coords, scaled_coords)
# print(f"Scaling factor: {scaling_factor}")

import json

def delete_road_by_id(file_path, road_id):
    # JSONファイルを読み込む
    with open(file_path, 'r') as file:
        data = json.load(file)
    
    # 指定された road_id に対応するデータを削除
    data = [feature for feature in data if feature['properties']['road_id'] != road_id]
    
    # JSONファイルに書き戻す
    with open(file_path, 'w') as file:
        json.dump(data, file, indent=4)

# 使用例
# file_path = 'webapp/json/road2.json'
# road_id_to_delete = 3  # 削除したい road_id を指定

#delete_road_by_id(file_path, road_id_to_delete)

def add_road(file_path, new_road):
    with open(file_path, "r") as file:
        data = json.load(file)
    
    data.append(new_road)

    with open(file_path, "w") as file:
        json.dump(data, file, indent=4)
file_path = 'webapp/json/road2.json'
new_road = {
    "geometry": {
        "type": "LineString",
        "coordinates": [
            [1,2],
            [3,4]
        ]
    },
    "properties": {
        "fid": None,
        "linkno": None,
        "oneway": 0,
        "netlevel": None,
        "maxspeed": 60,
        "maxspeed_2": None,
        "planesu": None,
        "mlanesu": None,
        "fukuin": None,
        "road_id": 1,
        "length": 45.0
    }
}
add_road(file_path, new_road)
