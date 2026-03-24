
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

  int testCounter = 0;
  
  Future<void> testRegistration(String testName, Map<String, dynamic> data) async {
    testCounter++;
    print("\n📝 Test #$testCounter: $testName");
    print("   Data: $data");
    try {
      final response = await dio.post('/api/Auth/register', data: data);
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        print("✅ SUCCESS! Status: ${response.statusCode}");
        print("   Token received: ${response.data.toString().contains('token')}");
        return;
      } else if (response.statusCode == 400) {
        print("⚠️  Validation Error (400):");
        final errors = response.data;
        if (errors is List) {
          for (var err in errors) {
            print("      - ${err['description'] ?? err}");
          }
        } else {
          print("      ${response.data}");
        }
      } else {
        print("❌ Server Error (${response.statusCode})");
        if (response.data != null && response.data.toString().isNotEmpty) {
          print("   Response: ${response.data}");
        }
      }
    } catch (e) {
      print("❌ Exception: $e");
    }
    await Future.delayed(Duration(milliseconds: 400));
  }

  String generateEmail() => "user${DateTime.now().millisecondsSinceEpoch}@test.com";
  String generatePhone() {
    final now = DateTime.now().millisecondsSinceEpoch.toString();
    return "010${now.substring(now.length - 8)}";
  }

  print("🔬 Comprehensive API Testing\n");
  print("=" * 60);

  // Test 1: Minimal valid data (no special chars in password)
  await testRegistration("Minimal - No special chars", {
    'email': generateEmail(),
    'password': 'TestPassword1',
    'confirmPassword': 'TestPassword1',
  });

  // Test 2: Add userName
  await testRegistration("With userName", {
    'userName': generateEmail(),
    'email': generateEmail(),
    'password': 'TestPassword1',
    'confirmPassword': 'TestPassword1',
  });

  // Test 3: Add name
  await testRegistration("With name", {
    'name': 'Test User',
    'userName': generateEmail(),
    'email': generateEmail(),
    'password': 'TestPassword1',
    'confirmPassword': 'TestPassword1',
  });

  // Test 4: Add role
  await testRegistration("With role", {
    'name': 'Test User',
    'userName': generateEmail(),
    'email': generateEmail(),
    'password': 'TestPassword1',
    'confirmPassword': 'TestPassword1',
    'role': 'Patient',
  });

  // Test 5: Add phone
  await testRegistration("With phone", {
    'name': 'Test User',
    'userName': generateEmail(),
    'email': generateEmail(),
    'password': 'TestPassword1',
    'confirmPassword': 'TestPassword1',
    'role': 'Patient',
    'phoneNumber': generatePhone(),
  });

  // Test 6: Try with special char in password
  await testRegistration("With @ in password", {
    'name': 'Test User',
    'userName': generateEmail(),
    'email': generateEmail(),
    'password': 'TestPassword1@',
    'confirmPassword': 'TestPassword1@',
    'role': 'Patient',
    'phoneNumber': generatePhone(),
  });

  print("\n" + "=" * 60);
  print("✅ Testing completed!");
}
