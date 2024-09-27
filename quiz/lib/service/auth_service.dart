import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  Future<String> reqistration({
    required String email,
    required String password,
    required String confirm,
  }) async {
    // ตรวจสอบว่ารหัสผ่านตรงกัน
    if (password != confirm) {
      return 'Passwords do not match'; // รหัสผ่านไม่ตรงกัน
    }

    try {
      await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);
      return 'success'; // สำเร็จ
    } on FirebaseAuthException catch (e) {
      return e.message ??
          'Unknown error occurred'; // แสดงข้อความผิดพลาดจาก Firebase
    } catch (e) {
      return e.toString(); // แสดงข้อความผิดพลาดทั่วไป
    }
  }

  Future<String> signin({
    required String email,
    required String password,
  }) async {
    try {
      await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);
      return 'success'; // สำเร็จ
    } on FirebaseAuthException catch (e) {
      return e.message ??
          'Unknown error occurred'; // แสดงข้อความผิดพลาดจาก Firebase
    } catch (e) {
      return e.toString(); // แสดงข้อความผิดพลาดทั่วไป
    }
  }
}
