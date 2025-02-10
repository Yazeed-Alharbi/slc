import 'package:flutter_test/flutter_test.dart';
import 'package:slc/dartUtil/validators.dart';

void main() {
  group("Email Validator Tests", () {
    test("Empty email should return error", () {
      expect(Validators.validateEmail(""), "Email is required.");
    });

    test("Invalid email should return error", () {
      expect(Validators.validateEmail("invalidemail"),
          "Please enter a valid email.");
    });

    test("Valid email should return null", () {
      expect(Validators.validateEmail("test@example.com"), null);
    });
  });

  group("Password Validator Tests", () {
    test("Empty password should return error", () {
      expect(Validators.validatePassword(""), "Password is required.");
    });

    test("Valid password should return null", () {
      expect(Validators.validatePassword("mypassword"), null);
    });
  });
}
