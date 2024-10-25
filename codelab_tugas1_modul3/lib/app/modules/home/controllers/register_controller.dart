import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

class RegisterController extends GetxController {
  FirebaseAuth _auth = FirebaseAuth.instance;
  var email = ''.obs;
  var password = ''.obs;

  // Register method using Firebase
  Future<void> register() async {
    try {
      await _auth.createUserWithEmailAndPassword(
        email: email.value,
        password: password.value,
      );
      Get.snackbar('Success', 'Registration successful!');
    } catch (e) {
      Get.snackbar('Error', e.toString());
    }
  }
}
