const canvas = document.getElementById('mapCanvas');
const ctx = canvas.getContext('2d');
const highlightCanvas = document.getElementById('highlightCanvas');
const highlightCtx = highlightCanvas.getContext('2d');
const canvasHeight = canvas.height;
// スケーリング用の設定
const scale = 1.0; // 必要に応じて変更
const scale2 = 1.1;
const offsetX = -13550000; // 必要に応じて変更
const offsetY = -3480000; // 必要に応じて変更
const xmove =6165;
const ymove = 1000;
const plot = document.getElementById('plot');
const linecolor = 'black';

// キャンバスをクリア
ctx.clearRect(0, 0, canvas.width, canvas.height);

let createRoadData = [];

// Flaskからデータを取得して描画
fetch('/roads')
    .then(response => response.json())
    .then(data => {
        data.forEach(feature => {
            drawGeometry(feature.geometry);
        });
    });
    //console.log("test");

//map描画
function drawGeometry(geometry) {
    if (geometry.type === "Polygon") {
        geometry.coordinates.forEach(ring => {
            drawPolygon(ring);
        });
    } else if (geometry.type === "LineString") {
        drawLineString(geometry.coordinates,linecolor);
    }
}
//ポリゴン描画関数
function drawPolygon(coordinates) {
    ctx.beginPath();
    coordinates.forEach(([x, y], index) => {
    
        const px = (x + offsetX) * scale-xmove;
        const py = canvasHeight-((y + offsetY) * scale-ymove);
        if (index === 0) {
            ctx.moveTo(px, py);
        } else {
            ctx.lineTo(px, py);
        }
    });
    ctx.closePath();
    ctx.fillStyle = "rgba(0, 0, 255, 0.3)";
    ctx.fill();
}
//ラインストリング描画関数
function drawLineString(coordinates,color) {
    ctx.strokeStyle = color;
    ctx.lineWidth = 1;
    ctx.beginPath();
    coordinates.forEach(([x, y], index) => {
        //console.log(x,y);
        const px = ((x + offsetX) * scale-xmove);
        const py = (canvasHeight-((y + offsetY) * scale-ymove));
        //console.log(px,py);  
        if (index === 0) {
            ctx.moveTo(px, py);
        } else {
            ctx.lineTo(px, py);
        }
    });
    ctx.stroke();
}


//ライン距離
// ポイントとラインセグメント間の距離を計算する関数
function pointToLineDistance(px, py, x1, y1, x2, y2) {
    const A = px - x1;
    const B = py - y1;
    const C = x2 - x1;
    const D = y2 - y1;
    const dot = A * C + B * D;
    const len_sq = C * C + D * D;
    const param = (len_sq !== 0) ? (dot / len_sq) : -1;
    let xx, yy;
    
    if (param < 0) {
        xx = x1;
        yy = y1;
    } else if (param > 1) {
        xx = x2;
        yy = y2;
    } else {
        xx = x1 + param * C;
        yy = y1 + param * D;
    }
    
    const dx = px - xx;
    const dy = py - yy;
    return Math.sqrt(dx * dx + dy * dy);
}
//クリックした座標に近い道路を取得する関数
function getClickedRoad(clickX, clickY, offsetX, offsetY, scale, xmove, ymove) {
    return fetch('/roads')
        .then(response => response.json())
        .then(data => {
            let clickedFeature = null;
            data.forEach(feature => {
                if (feature.geometry.type === "LineString") {
                    const coordinates = feature.geometry.coordinates.map(([x, y]) => [(x + offsetX) * scale - xmove, (y + offsetY) * scale - ymove]);
                    for (let i = 0; i < coordinates.length - 1; i++) {
                        const [x1, y1] = coordinates[i];
                        const [x2, y2] = coordinates[i + 1];
                        const distance = pointToLineDistance(clickX, clickY, x1, y1, x2, y2);
                        
                        if (distance < 6) { // 閾値を設定
                            clickedFeature = feature;
                            break;
                        }
                    }
                }
            });
            return clickedFeature;
        });
}
// 丸を描画する関数
function drawCircle(ctx, x, y, radius, color) {
    ctx.beginPath();
    ctx.arc(x, y, radius, 0, 2 * Math.PI, false);
    ctx.fillStyle = color;
    ctx.fill();
}


// お絵描き機能の追加
let isDrawing = false;
let startX = 0;
let startY = 0;
let endX = 0;
let endY = 0;
let roadInfo = {};

highlightCanvas.addEventListener('click', (e) => {
    const rect = canvas.getBoundingClientRect();
    const clickX = e.clientX - rect.left;
    const clickY = canvasHeight - (e.clientY - rect.top);
    console.log(`clickX,clickY: (${clickX}, ${clickY})`);
    if (!isDrawing) {
        // 始点を設定
        getClickedRoad(clickX,clickY, offsetX, offsetY, scale, xmove, ymove)
            .then(feature => {
                if (feature) {
                    console.log('s_Feature:', feature.properties.road_id);
                    [startX, startY] = [clickX, clickY];
                    console.log(`startX,startY: (${startX}, ${startY})`);
                    roadInfo={
                        s_xy: [startX, startY],
                        s_id: feature.properties.road_id
                    };
                    drawCircle(highlightCtx, startX, canvasHeight-startY, 5, 'blue'); // 始点に丸を描画
                    isDrawing = true;
                }
            });
    } else {
        // 終点を設定して直線を描画
        console.log(`endX,endY: (${endX}, ${endY})`);
        getClickedRoad(clickX,clickY, offsetX, offsetY, scale, xmove, ymove)
            .then(feature => {
                if (feature) {
                    console.log('t_Feature:', feature.properties.road_id);
                    [endX, endY] = [clickX, clickY];
                    console.log(`endX,endY: (${endX}, ${endY})`);
                    highlightCtx.strokeStyle = 'red';
                    highlightCtx.lineWidth = 2;
                    highlightCtx.beginPath();
                    highlightCtx.moveTo(startX,canvasHeight - startY);
                    highlightCtx.lineTo(endX, canvasHeight - endY);
                    highlightCtx.stroke();
                    highlightCtx.closePath();
                    roadInfo.t_xy = [endX,endY];
                    roadInfo.t_id = feature.properties.road_id;
                    console.log(roadInfo);
                    // createRoadData.push(roadInfo);
                    // console.log(createRoadData);
                    // roadInfo = {};
                    drawCircle(highlightCtx, endX, canvasHeight-endY, 5, 'blue'); // 始点に丸を描画
                    isDrawing = false; // 描画完了
                }
            });

    }
});

function sendDataToServer(data) {
    fetch('/createRoadData', {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json',
        },
        body: JSON.stringify(roadInfo),
    })
    .then(response => response.json())
    .then(data => {
        console.log('Success:', data);
        roadInfo = {};
    })
    .catch((error) => {
        console.error('Error:', error);
    });
}

const sendDataButton = document.getElementById('sendDataButton');
const canvasRect = canvas.getBoundingClientRect();
sendDataButton.style.top = `${canvasRect.bottom+window.scrollY+5}px`;
sendDataButton.style.left = `${canvasRect.left}px`;
sendDataButton.addEventListener('click', () => {
    sendDataToServer(roadInfo);
});


const updateMapButton = document.getElementById('updateMapButton');
updateMapButton.style.top = `${canvasRect.bottom+window.scrollY+5}px`;
updateMapButton.style.left = `${canvasRect.left+100}px`;
updateMapButton.addEventListener('click',()=>{
    highlightCtx.clearRect(0, 0, highlightCanvas.width, highlightCanvas.height);
    location.reload();
});