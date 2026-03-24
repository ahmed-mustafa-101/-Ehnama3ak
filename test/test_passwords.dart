
import 'package:dio/dio.dart';

void main() async {
  final dio = Dio(BaseOptions(
    baseUrl: 'http://e7na-ma3ak-test.runasp.net',
    headers: {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    },
    validateStatus: (status) => true,
  ));

  String generateRandomEmail() {
    return "test_${DateTime.now().millisecondsSinceEpoch}@test.com";
  }
  
  String generateRandomPhone() {
    final now = DateTime.now().millisecondsSinceEpoch.toString();
    return "010${now.substring(now.length - 8)}";
  }

  Future<void> testPassword(String password) async {
    final email = generateRandomEmail();
    print("\n🔑 Testing password: '$password'");
    try {
      final response = await dio.post('/api/Auth/register', data: {
        'name': 'Test User',
        'userName': email,
        'email': email,
        'password': password,
        'confirmPassword': password,
        'phoneNumber': generateRandomPhone(),
        'role': 'Patient',
      });
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        print("✅ SUCCESS! Status: ${response.statusCode}");
        print("   Response: ${response.data}");
      } else if (response.statusCode == 400) {
        print("❌ Validation Error (400):");
        print("   ${response.data}");
      } else {
        print("❌ Server Error (${response.statusCode})");
        print("   Response: ${response.data}");
      }
    } catch (e) {
      print("❌ Exception: $e");
    }
    await Future.delayed(Duration(milliseconds: 300));
  }

  print("🧪 Testing various password formats...\n");
  
  // Test passwords with different requirements
  await testPassword("Test1234");           // No special char
  await testPassword("Test@1234");          // Has special char
  await testPassword("Test@123");           // Shorter
  await testPassword("TestTest@1");         // Different format
  await testPassword("Aa1@aaaa");           // Minimal requirements
  await testPassword("Password1@");         // Common format
  await testPassword("MyPass123!");         // With !
  await testPassword("SecureP@ss1");        // Another format
  await testPassword("Test#123456");        // With #
  await testPassword("Pass@word1");         // @ in middle
  
  print("\n✅ Password testing completed!");
}
