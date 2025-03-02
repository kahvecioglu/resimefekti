import 'package:resimefekti/services/api.dart';
import 'package:resimefekti/state/image_provider_model.dart';

class ImageFilterService {
  final ApiService _apiService = ApiService();

  Future<void> applyFilter(
      ImageProviderModel imageProvider, String filterType) async {
    if (imageProvider.selectedImage == null) return;

    imageProvider.setLoading(true);
    imageProvider.clearError();

    try {
      final processedImage = await _apiService.processImage(
          imageProvider.selectedImage!, filterType);

      if (processedImage != null) {
        imageProvider.updateProcessedImage(processedImage);
      }
    } catch (e) {
      imageProvider.setError(e.toString());
    } finally {
      imageProvider.setLoading(false);
    }
  }
}
