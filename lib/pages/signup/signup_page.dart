import '../signin/signin_page.dart';
import '../../services/firebase/auth_service.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SignupPage extends StatelessWidget {
  SignupPage({super.key});

  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _birthDateController = TextEditingController();
  String _selectedGender = 'Male';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: true,
      bottomNavigationBar: _signin(context),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        toolbarHeight: 50,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
         padding: const EdgeInsets.symmetric(horizontal: 16,vertical: 16),
          child: Column(
            children: [
              Center(
                child: Text(
                  'Register Account',
                  style: GoogleFonts.raleway(
                    textStyle: const TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 32
                    )
                  ),
                ),
              ),
              const SizedBox(height: 20,),
               _fullName(),
              const SizedBox(height: 20,),
               _emailAddress(),
               const SizedBox(height: 20,),
               _password(),
               const SizedBox(height: 20,),
               _birthDate(context),
               const SizedBox(height: 20,),
               _gender(),
               const SizedBox(height: 50,),
               _signup(context),
            ],
          ),

      ),
      )
    );
  }

Widget _fullName() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Full Name',
          style: GoogleFonts.raleway(
            textStyle: const TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.normal,
              fontSize: 16
            )
          ),
        ),
        const SizedBox(height: 16,),
        TextField(
          controller: _fullNameController,
          decoration: InputDecoration(
            filled: true,
            hintText: 'example: alok saepudin',
            hintStyle: const TextStyle(
              color: Color(0xff6A6A6A),
              fontWeight: FontWeight.normal,
              fontSize: 14
            ),
            fillColor: const Color(0xffF7F7F9) ,
            border: OutlineInputBorder(
              borderSide: BorderSide.none,
              borderRadius: BorderRadius.circular(14)
            )
          ),
        )
      ],
    );
  }

  Widget _emailAddress() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Email Address',
          style: GoogleFonts.raleway(
            textStyle: const TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.normal,
              fontSize: 16
            )
          ),
        ),
        const SizedBox(height: 16,),
        TextField(
          controller: _emailController,
          decoration: InputDecoration(
            filled: true,
            hintText: 'example: alok@gmail.com',
            hintStyle: const TextStyle(
              color: Color(0xff6A6A6A),
              fontWeight: FontWeight.normal,
              fontSize: 14
            ),
            fillColor: const Color(0xffF7F7F9) ,
            border: OutlineInputBorder(
              borderSide: BorderSide.none,
              borderRadius: BorderRadius.circular(14)
            )
          ),
        )
      ],
    );
  }

  Widget _password() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Password',
          style: GoogleFonts.raleway(
            textStyle: const TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.normal,
              fontSize: 16
            )
          ),
        ),
        const SizedBox(height: 16,),
        TextField(
          controller: _passwordController,
          obscureText: true,
          decoration: InputDecoration(
            filled: true,
            fillColor: const Color(0xffF7F7F9) ,
            border: OutlineInputBorder(
              borderSide: BorderSide.none,
              borderRadius: BorderRadius.circular(14)
            )
          ),
        )
      ],
    );
  }

  Widget _birthDate(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Birth Date',
          style: GoogleFonts.raleway(
            textStyle: const TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.normal,
              fontSize: 16
            )
          ),
        ),
        const SizedBox(height: 16,),
        TextField(
          controller: _birthDateController,
          readOnly: true,
          decoration: InputDecoration(
            filled: true,
            hintText: 'Select your birth date',
            hintStyle: const TextStyle(
              color: Color(0xff6A6A6A),
              fontWeight: FontWeight.normal,
              fontSize: 14
            ),
            fillColor: const Color(0xffF7F7F9),
            border: OutlineInputBorder(
              borderSide: BorderSide.none,
              borderRadius: BorderRadius.circular(14)
            )
          ),
          onTap: () async {
            DateTime? pickedDate = await showDatePicker(
              context: context,
              initialDate: DateTime.now(),
              firstDate: DateTime(1900),
              lastDate: DateTime.now(),
            );
            if (pickedDate != null) {
              _birthDateController.text = "${pickedDate.toLocal()}".split(' ')[0];
            }
          },
        ),
      ],
    );
  }

  Widget _gender() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Gender',
          style: GoogleFonts.raleway(
            textStyle: const TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.normal,
              fontSize: 16
            )
          ),
        ),
        const SizedBox(height: 16,),
        DropdownButtonFormField<String>(
          value: _selectedGender,
          items: ['Male', 'Female', 'Other'].map((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
          onChanged: (newValue) {
            _selectedGender = newValue!;
          },
          decoration: InputDecoration(
            filled: true,
            fillColor: const Color(0xffF7F7F9),
            border: OutlineInputBorder(
              borderSide: BorderSide.none,
              borderRadius: BorderRadius.circular(14)
            )
          ),
        ),
      ],
    );
  }

  Widget _signup(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xff0D6EFD),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          minimumSize: const Size(double.infinity, 60),
          elevation: 0,
      ),
      onPressed: () async {
       await AuthService().signup(
          userName: _fullNameController.text,
          email: _emailController.text,
          password: _passwordController.text,
          context: context,
          birthDate: _birthDateController.text,
          gender: _selectedGender,
        );
      },
      child: const Text("Sign Up"),
    );
  }

  Widget _signin(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: RichText(
        textAlign: TextAlign.center,
        text: TextSpan(
          children: [
            const TextSpan(
                text: "Already Have Account? ",
                style: TextStyle(
                  color: Color(0xff6A6A6A),
                  fontWeight: FontWeight.normal,
                  fontSize: 16
                ),
              ),
              TextSpan(
                text: "Log In",
                style: const TextStyle(
                    color: Color(0xff1A1D1E),
                    fontWeight: FontWeight.normal,
                    fontSize: 16
                  ),
                  recognizer: TapGestureRecognizer()..onTap = () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => SigninPage()
                      ),
                    );
                  }
              ),
          ]
        )
      ),
    );
  }
}