from flask import Flask, request, jsonify
from flask_cors import CORS
from opencv import process_image  # OpenCV işleme fonksiyonunu import ettik

app = Flask(__name__)
CORS(app)

@app.route('/process_image', methods=['POST'])
def process_image_route():
    try:
        if 'image' not in request.files:
            return jsonify({'error': 'Resim dosyası bulunamadı.'}), 400

        file = request.files['image']
        filter_type = request.form.get('filter', 'grayscale')

        # OpenCV işlemleri image_processing.py'den yapılacak
        processed_image = process_image(file, filter_type)

        # Görüntü başarıyla işlendiyse, byte dizisini döndür
        return processed_image, 200, {'Content-Type': 'image/jpeg'}
    except Exception as e:
        return jsonify({'error': f'Resim işlenirken bir hata oluştu: {str(e)}'}), 500

if __name__ == '__main__':
    app.run(debug=True, host='0.0.0.0', port=5000, threaded=True)
