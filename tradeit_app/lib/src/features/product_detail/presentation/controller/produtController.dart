import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProductDetailController extends GetxController {
  final String adId;

  ProductDetailController(this.adId);

  final isLoading = true.obs;
  final errorMessage = ''.obs;
  final adData = Rxn<Map<String, dynamic>>();

  @override
  void onInit() {
    super.onInit();
    fetchAdData();
  }

  Future<void> fetchAdData() async {
    try {
      isLoading.value = true;

      DocumentSnapshot doc =
          await FirebaseFirestore.instance.collection('ads').doc(adId).get();
      
      if (doc.exists) {
        adData.value = doc.data() as Map<String, dynamic>;
      } else {
        errorMessage.value = 'Anúncio não encontrado.';
      }
    } catch (e) {
      errorMessage.value = 'Erro ao buscar anúncio: $e';
    } finally {
      isLoading.value = false;
    }
  }
}
