# Resim Filtreleme Uygulaması

Bu proje, kullanıcıların yerel cihazlarından resim seçmesini, OpenCV kullanarak çeşitli filtreler uygulamasını ve düzenlenen resmi indirmesini sağlayan bir resim işleme uygulamasıdır. Backend olarak Flask, frontend için Flutter ve state management için Provider kullanılmıştır.

## 📌 Kullanılan Teknolojiler

- **Flutter**: Kullanıcı arayüzü ve uygulama akışını sağlamak için
- **Provider**: State management için
- **Flask**: Backend işlemleri ve API iletişimi için
- **OpenCV**: Görüntü işleme ve filtreleme için
- **Dio**: API isteklerini yönetmek için

---

## 📂 Proje Yapısı

### Flutter Kodu
```
lib/
├── main.dart  # Uygulamanın giriş noktası
│
│   
│
├── state/
│   ├── image_provider.model.dart  # Seçilen resmin yönetimi
│  
│
├── services/
│   ├── api.dart  # Flask API'ye istek gönderen servis
│   ├── image_download_services.dart   # Resim indirme servisi
│   ├── image_filter_service.dart      # Filtreleme servisi


### Flask Backend Kodu
```
lib/
│  
│
├── python/
│   ├── flask.py   # Flask uygulamasının ana dosyası 
    ├── opencv.py   # Opencv ile , , resim dosyasını alır, filtreler, işler
---

## 🚀 Kurulum ve Çalıştırma

### Flutter Uygulamasını Çalıştırma

1. Flutter'ın sisteminize kurulu olduğundan emin olun.
2. Gerekli bağımlılıkları yükleyin:
   ```
   flutter pub get
   ```
3. Uygulamayı başlatın:
   ```
   flutter run
   ```

### Flask Backend'i Çalıştırma

1. Gerekli bağımlılıkları yükleyin:
   ```
   pip install -r requirements.txt
   ```
2. Flask uygulamasını çalıştırın:
   ```
   python flask.py
   ```

---

## 🎨 Uygulama Akışı

1. **Resim Seçme**: Kullanıcı cihazından bir resim seçer.
2. **Filtre Uygulama**: Seçilen resme OpenCV kullanarak çeşitli filtreler uygulanır (örneğin, siyah-beyaz, bulanıklaştırma, kenar algılama vb.).
3. **Önizleme ve Kaydetme**: Kullanıcı, filtrelenmiş görüntüyü önizleyebilir ve isterse cihazına indirebilir.

---

## 📌 API Endpointleri

| Metod | URL | Açıklama |
|-------|-----|----------|
| POST | `/upload` | Resmi yükler ve işleme alır |
| GET  | `/filters` | Mevcut filtrelerin listesini döner |
| POST | `/apply_filter` | Belirtilen filtreyi uygular |

---


📌 **Not**: Uygulamayı kullanırken Flask backend'in çalışır durumda olduğuna emin olun!
