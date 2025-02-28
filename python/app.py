from flask import Flask, request, jsonify, send_file
import cv2
import numpy as np
import os

app = Flask(__name__)

@app.route('/process', methods=['POST'])
def process_image():
    if 'file' not in request.files:
        return jsonify({'error': 'No file part'}), 400
    
    file = request.files['file']
    image = cv2.imdecode(np.frombuffer(file.read(), np.uint8), cv2.IMREAD_COLOR)

    # Verilen filtre türüne göre işlem yapıyoruz
    filter_type = request.form.get('filter', '')  # Filtre türünü alıyoruz
    if filter_type == 'grayscale':
        image = cv2.cvtColor(image, cv2.COLOR_BGR2GRAY)
    elif filter_type == 'blur':
        image = cv2.GaussianBlur(image, (15, 15), 0)
    
    # İşlenmiş resmi kaydediyoruz
    output_path = 'processed_image.png'
    cv2.imwrite(output_path, image)
    
    return send_file(output_path, mimetype='image/png')

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)  # localhost yerine IP ile çalıştırılmalı
