
import 'package:dio/dio.dart';

void main() async {
  final dio = Dio(BaseOptions(
    baseUrl: 'http://e7na-ma3ak-test.runasp.net',
    headers: {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    },
    validateStatus: (status) => true,
  ))..interceptors.add(LogInterceptor(
    requestBody: true,
    responseBody: true,
    error: true,
  ));

  String generateRandomEmail() {
    return "test_${DateTime.now().millisecondsSinceEpoch}@test.com";
  }
  
  String generateRandomPhone() {
    final now = DateTime.now().millisecondsSinceEpoch.toString();
    return "010${now.substring(now.length - 8)}";
  }

  Future<void> testPayload(String name, Map<String, dynamic> data) async {
    print("\n========== Testing: $name ==========");
    try {
      final response = await dio.post('/api/Auth/register', data: data);
      print("✓ Status: ${response.statusCode}");
      if (response.data != null && response.data.toString().isNotEmpty) {
        print("✓ Response: ${response.data}");
      } else {
        print("✗ Empty response body");
      }
    } catch (e) {
      print("✗ Error: $e");
    }
    await Future.delayed(Duration(milliseconds: 500));
  }

  final password = "Password123!";
  final email = generateRandomEmail();
  
  // Test different phone formats
  print("\n🔍 Testing Phone Number Formats:");
  
  await testPayload("Phone: 11 digits (010xxxxxxxx)", {
    'name': 'Test User',
    'userName': email,
    'email': email,
    'password': password,
    'confirmPassword': password,
    'phoneNumber': generateRandomPhone(),
    'role': 'Patient',
  });

  await testPayload("Phone: +20 prefix", {
    'name': 'Test User',
    'userName': generateRandomEmail(),
    'email': generateRandomEmail(),
    'password': password,
    'confirmPassword': password,
    'phoneNumber': '+20${generateRandomPhone().substring(1)}',
    'role': 'Patient',
  });

  await testPayload("Phone: Simple format (01012345678)", {
    'name': 'Test User',
    'userName': generateRandomEmail(),
    'email': generateRandomEmail(),
    'password': password,
    'confirmPassword': password,
    'phoneNumber': '01012345678',
    'role': 'Patient',
  });

  // Test without phoneNumber
  print("\n🔍 Testing Without Phone Number:");
  await testPayload("No phoneNumber field", {
    'name': 'Test User',
    'userName': generateRandomEmail(),
    'email': generateRandomEmail(),
    'password': password,
    'confirmPassword': password,
    'role': 'Patient',
  });

  // Test with null phoneNumber
  await testPayload("Null phoneNumber", {
    'name': 'Test User',
    'userName': generateRandomEmail(),
    'email': generateRandomEmail(),
    'password': password,
    'confirmPassword': password,
    'phoneNumber': null,
    'role': 'Patient',
  });

  // Test different password formats
  print("\n🔍 Testing Password Formats:");
  
  await testPayload("Simple password (Test1234)", {
    'name': 'Test User',
    'userName': generateRandomEmail(),
    'email': generateRandomEmail(),
    'password': 'Test1234',
    'confirmPassword': 'Test1234',
    'phoneNumber': generateRandomPhone(),
    'role': 'Patient',
  });

  await testPayload("Complex password", {
    'name': 'Test User',
    'userName': generateRandomEmail(),
    'email': generateRandomEmail(),
    'password': 'Test@123456',
    'confirmPassword': 'Test@123456',
    'phoneNumber': generateRandomPhone(),
    'role': 'Patient',
  });

  // Test Doctor registration
  print("\n🔍 Testing Doctor Registration:");
  
  await testPayload("Doctor with specialization", {
    'name': 'Dr Test',
    'userName': generateRandomEmail(),
    'email': generateRandomEmail(),
    'password': password,
    'confirmPassword': password,
    'phoneNumber': generateRandomPhone(),
    'role': 'Doctor',
    'specialization': 'Cardiology',
  });

  print("\n✅ Diagnostic tests completed!");
}
