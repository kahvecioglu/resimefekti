from flask import Flask, request, jsonify
from flask_cors import CORS
import cv2
import numpy as np
from PIL import Image
import io

app = Flask(__name__)
CORS(app)  # CORS ayarları
@app.route('/process_image', methods=['POST'])
def process_image():
    try:
        if 'image' not in request.files:
            return jsonify({'error': 'Resim dosyası bulunamadı.'}), 400

        file = request.files['image']
        filter_type = request.form.get('filter', 'grayscale')  # Varsayılan filtre: grayscale

        # Resmi işleme
        img = Image.open(file.stream)
        img = np.array(img)

        # Filtre uygula
        if filter_type == 'grayscale':
            img = cv2.cvtColor(img, cv2.COLOR_BGR2GRAY)
        elif filter_type == 'blur':
            img = cv2.GaussianBlur(img, (15, 15), 0)
        elif filter_type == 'sepia':
            # Sepia filtresi örneği
            kernel = np.array([[0.393, 0.769, 0.189],
                               [0.349, 0.686, 0.168],
                               [0.272, 0.534, 0.131]])
            img = cv2.transform(img, kernel)
        elif filter_type == 'invert':
            img = cv2.bitwise_not(img)
        elif filter_type == 'edge':
            img = cv2.Canny(img, 100, 200)
        elif filter_type == 'contrast':
            img = cv2.convertScaleAbs(img, alpha=1.5, beta=0)  # Kontrast artırma
        elif filter_type == 'brightness':
            img = cv2.convertScaleAbs(img, alpha=1, beta=50)  # Parlaklık artırma
        elif filter_type == 'mirror':
            img = cv2.flip(img, 1)  # Ayna efekti
        else:
            return jsonify({'error': 'Geçersiz filtre türü.'}), 400

        # Resmi sıkıştır ve gönder
        _, img_encoded = cv2.imencode('.jpg', img, [int(cv2.IMWRITE_JPEG_QUALITY), 50])  # JPEG kalitesini düşür
        return img_encoded.tobytes(), 200, {'Content-Type': 'image/jpeg'}
    except Exception as e:
        return jsonify({'error': f'Resim işlenirken bir hata oluştu: {str(e)}'}), 500
if __name__ == '__main__':
    app.run(debug=True, host='0.0.0.0', port=5000, threaded=True)  # Threaded modunu etkinleştir