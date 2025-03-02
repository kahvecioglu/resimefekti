Kurulum Kılavuzu: Flutter, C++, Python ve Flask :

Bu kılavuz, Flutter, C++, Python ve Flask kurulumu için gerekli adımları içermektedir. Bu adımları takip ederek, projelerinizde bu teknolojileri kullanabilirsiniz.

1. Flutter Kurulumu :

1.2. Flutter'ı İndirme ve Kurma :

Flutter SDK'sını İndirin (Link: https://flutter.dev/docs/get-started/install) ve bilgisayarınıza çıkarın.

Windows için:

Flutter SDK'yı Flutter indir sayfasından (Link: https://flutter.dev/docs/get-started/install) indirin.
Zip dosyasını çıkarın ve Flutter SDK'yı uygun bir dizine taşıyın.
Sistem ortam değişkenlerine flutter/bin dizinini ekleyin.
Komut istemcisine flutter --version komutunu yazarak Flutter'ın doğru şekilde kurulduğunu doğrulayın.

macOS için:

Homebrew kurulu ise, brew install flutter komutunu çalıştırarak Flutter'ı kurabilirsiniz.
Alternatif olarak, Flutter SDK'yı Flutter indir sayfasından (Link: https://flutter.dev/docs/get-started/install) indirip çıkarabilirsiniz.
Terminal'e flutter --version komutunu yazarak kurulumu doğrulayın.
1.3. Flutter ve Android Studio veya Visual Studio Code Kurulumu
Android Studio'yu indirip kurun. Geliştirme araçları ve SDK'yı yükleyin.
Visual Studio Code kullanıyorsanız, Flutter ve Dart uzantılarını yükleyin.





2. C++ Kurulumu

2.2. C++ Derleyicisini Kurma
Windows:

Visual Studio'yu (Link: https://visualstudio.microsoft.com/) indirip kurun ve "C++ Desktop Development" iş yükünü seçin.

macOS:
Terminal'e şu komutu yazın:
xcode-select --install

linux :
Terminal'e şu komutu yazın:
sudo apt-get install build-essential






3. Python ve Flask Kurulumu

3.1. Python Kurulumu

Python'ın en son sürümünü Python'ın resmi web sitesinden (Link: https://www.python.org/downloads/) indirin.
Kurulum sırasında "Add Python to PATH" seçeneğini işaretleyin.
Windows:

Python'ı indirip kurun.
Python'u terminal veya komut istemcisinde python --version komutunu girerek doğrulayın.
macOS ve Linux:

Python genellikle sistemle birlikte gelir. Terminal'de şu komutu kullanarak kontrol edebilirsiniz:
python3 --version

3.2. Flask Kurulumu
Flask, Python ile web uygulamaları geliştirmek için kullanılan hafif bir mikro framework'tür.

Flask'ı kurmak için terminal veya komut istemcisinde aşağıdaki komutu çalıştırın:
pip install flask

Flask'ın kurulu olduğunu doğrulamak için:
python -m flask --version