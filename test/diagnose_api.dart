
import 'package:dio/dio.dart';

void main() async {
  final dio = Dio(BaseOptions(
    baseUrl: 'http://e7na-ma3ak-test.runasp.net',
    headers: {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    },
    validateStatus: (status) => true, // Don't throw on error
  ));

  String generateRandomEmail() {
    return "test_${DateTime.now().millisecondsSinceEpoch}@test.com";
  }
  
  String generateRandomPhone() {
    final now = DateTime.now().millisecondsSinceEpoch.toString();
    return "010${now.substring(now.length - 8)}";
  }

  Future<void> testPayload(String name, Map<String, dynamic> data) async {
    print("\n--- Testing: $name ---");
    try {
      final response = await dio.post('/api/Auth/register', data: data);
      print("Status: ${response.statusCode}");
      print("Response: ${response.data}");
    } catch (e) {
      print("Error: $e");
    }
  }

  // Common data
  final password = "Password123!";
  
  // Test 1: Baseline (What we have now) without specialization
  await testPayload("Baseline (No Specialization)", {
    'name': 'Test User',
    'userName': generateRandomEmail(),
    'email': generateRandomEmail(),
    'password': password,
    'confirmPassword': password,
    'phoneNumber': generateRandomPhone(),
    'role': 'Patient',
  });

  // Test 2: With Gender (Int)
  await testPayload("With Gender (0)", {
    'name': 'Test User',
    'userName': generateRandomEmail(),
    'email': generateRandomEmail(),
    'password': password,
    'confirmPassword': password,
    'phoneNumber': generateRandomPhone(),
    'role': 'Patient',
    'gender': 0,
  });

  // Test 3: With Gender (String)
  await testPayload("With Gender ('Male')", {
    'name': 'Test User',
    'userName': generateRandomEmail(),
    'email': generateRandomEmail(),
    'password': password,
    'confirmPassword': password,
    'phoneNumber': generateRandomPhone(),
    'role': 'Patient',
    'gender': "Male",
  });
  
  // Test 4: Lowercase Role
  await testPayload("Lowercase Role", {
    'name': 'Test User',
    'userName': generateRandomEmail(),
    'email': generateRandomEmail(),
    'password': password,
    'confirmPassword': password,
    'phoneNumber': generateRandomPhone(),
    'role': 'patient',
  });
}
