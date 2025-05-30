import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserAdProductController extends GetxController {
  final String userAd;

  UserAdProductController(this.userAd);

  final isLoading = true.obs;
  final errorMessage = ''.obs;
  final adData = Rxn<Map<String, dynamic>>();
  final userAdData = Rxn<Map<String, dynamic>>();

  @override
  void onInit() {
    super.onInit();
    fetchAdData();
  }

  Future<void> fetchAdData() async {
    try {
      isLoading.value = true;

      DocumentSnapshot doc =
        await FirebaseFirestore.instance.collection('user').doc(userAd).get();
        
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
