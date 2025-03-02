import cv2
import numpy as np
from PIL import Image
import io

def process_image(file, filter_type):
    # Flask'tan gelen resim verisini okuma
    img = Image.open(file.stream)
    img = np.array(img)

    # Görüntü tipi uint8 değilse, onu uygun tipe dönüştürme
    if img.dtype != np.uint8:
        img = cv2.convertScaleAbs(img)

    # Seçilen filtre türüne göre işleme yapma
    if filter_type == 'grayscale':
        img = cv2.cvtColor(img, cv2.COLOR_BGR2GRAY)
    elif filter_type == 'blur':
        img = cv2.GaussianBlur(img, (15, 15), 0)
    elif filter_type == 'sepia':
        kernel = np.array([[0.393, 0.769, 0.189],
                           [0.349, 0.686, 0.168],
                           [0.272, 0.534, 0.131]])
        img = cv2.transform(img, kernel)
    elif filter_type == 'contrast':
        img = cv2.convertScaleAbs(img, alpha=1.5, beta=0)
    elif filter_type == 'brightness':
        img = cv2.convertScaleAbs(img, alpha=1, beta=50)
    elif filter_type == 'mirror':
        img = cv2.flip(img, 1)
    elif filter_type == 'negative':
        img = 255 - img
    elif filter_type == 'vignette':
        rows, cols = img.shape[:2]
        X_result = np.zeros((rows, cols, 3), dtype=np.uint8)
        for i in range(rows):
            for j in range(cols):
                dist = np.sqrt((i - rows/2) ** 2 + (j - cols/2) ** 2)
                factor = 1 - min(dist / (rows / 2), 1)
                X_result[i, j] = img[i, j] * factor
        img = X_result
    elif filter_type == 'posterize':
        img = cv2.convertScaleAbs(img, alpha=1.0, beta=-100)
    else:
        raise ValueError('Geçersiz filtre türü.')

    # Görüntüyü byte dizisine dönüştürme (JPEG formatında)
    _, img_encoded = cv2.imencode('.jpg', img, [int(cv2.IMWRITE_JPEG_QUALITY), 50])
    return img_encoded.tobytes()
