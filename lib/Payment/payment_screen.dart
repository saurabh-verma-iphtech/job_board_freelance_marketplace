// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';
// import 'package:razorpay_flutter/razorpay_flutter.dart';

// class RazorPayPage extends StatefulWidget {
//   final String contractId;
//   final double amount;
//   final String userId; // Add userId parameter
//   final Function(String) onSuccess; // Changed to accept payment ID

//   const RazorPayPage({
//     super.key,
//     required this.contractId,
//     required this.amount,
//     required this.userId,
//     required this.onSuccess,
//   });

//   @override
//   State<RazorPayPage> createState() => _RazorPayPageState();
// }

// class _RazorPayPageState extends State<RazorPayPage>
//     with SingleTickerProviderStateMixin {
//   late Razorpay _razorpay;
//   TextEditingController amtController = TextEditingController();
//   late AnimationController _controller;
//   late Animation<double> _fadeAnimation;
//   late Animation<Offset> _slideAnimation;
//   Map<String, dynamic>? _userData;
//   bool _isLoadingUser = true;
//   String? _errorMessage;
//   bool _isProcessing = false;

//   @override
//   void initState() {
//     super.initState();
//     _loadUserData();
//     amtController.text = widget.amount.toStringAsFixed(0);
//     _razorpay = Razorpay();
//     _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
//     _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
//     _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);

//     _controller = AnimationController(
//       vsync: this,
//       duration: const Duration(milliseconds: 1000),
//     );

//     _fadeAnimation = Tween<double>(
//       begin: 0,
//       end: 1,
//     ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeIn));

//     _slideAnimation = Tween<Offset>(
//       begin: const Offset(0, -0.5),
//       end: Offset.zero,
//     ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

//     _controller.forward();
//   }

//   Future<void> _loadUserData() async {
//     try {
//       final doc =
//           await FirebaseFirestore.instance
//               .collection('users')
//               .doc(widget.userId)
//               .get();

//       if (doc.exists) {
//         setState(() {
//           _userData = doc.data() as Map<String, dynamic>;
//           _isLoadingUser = false;
//         });
//       } else {
//         setState(() {
//           _errorMessage = 'User data not found';
//           _isLoadingUser = false;
//         });
//       }
//     } catch (e) {
//       setState(() {
//         _errorMessage = 'Failed to load user data: ${e.toString()}';
//         _isLoadingUser = false;
//       });
//     }
//   }

//   void openCheckout(amount) async {
//     setState(() => _isProcessing = true);
//     final paiseAmount = (amount * 100).toInt();
//     var options = {
//       'key': 'rzp_test_r5X2FfLPXhBTl3',
//       'amount': paiseAmount,
//       'name': _userData!['name'] ?? 'Customer',
//       'prefill': {
//         'contact': _userData!['phone'] ?? '9999999999',
//         'email': _userData!['email'] ?? 'customer@example.com',
//       },
//       'external': {
//         'wallet': ['paytm'],
//       },
//     };
//     try {
//       _razorpay.open(options);
//     } catch (e) {
//       debugPrint('Error : $e');
//     } finally {
//       setState(() => _isProcessing = false);
//     }
//   }

//   void _handlePaymentSuccess(PaymentSuccessResponse response) {
//     if (response.paymentId != null) {
//       widget.onSuccess(response.paymentId!); // Pass payment ID back
//       Navigator.pop(context); // Close payment screen
//     }
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text("Payment ID: ${response.paymentId}"),
//         backgroundColor: Colors.green,
//       ),
//     );
//   }

//   void _handlePaymentError(PaymentFailureResponse response) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         backgroundColor: Colors.red,
//         content: Text("Payment Failed: ${response.message}"),
//         behavior: SnackBarBehavior.floating,
//       ),
//     );
//   }

//   void _handleExternalWallet(ExternalWalletResponse response) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         backgroundColor: Colors.blue,
//         content: Text("External Wallet: ${response.walletName}"),
//         behavior: SnackBarBehavior.floating,
//       ),
//     );
//   }

//   @override
//   void dispose() {
//     _razorpay.clear();
//     _controller.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTap: () => FocusScope.of(context).unfocus(),
//       child: Scaffold(
//         body: Container(
//           height: double.infinity,
//           decoration: BoxDecoration(
//             gradient: LinearGradient(
//               begin: Alignment.topLeft,
//               end: Alignment.bottomRight,
//               colors: [Colors.blue.shade800, Colors.purple.shade600],
//             ),
//           ),
//           child: SingleChildScrollView(
//             child: Column(
//               children: [
//                 const SizedBox(height: 80),
//                 FadeTransition(
//                   opacity: _fadeAnimation,
//                   child: SlideTransition(
//                     position: _slideAnimation,
//                     child: Image.network(
//                       'https://img.freepik.com/free-vector/hands-holding-credit-card-mobile-phone-with-banking-app-person-paying-with-bank-card-transferring-money-shopping-online-flat-vector-illustration-payment-finance-concept_74855-24760.jpg',
//                       width: 300,
//                       fit: BoxFit.cover,
//                     ),
//                   ),
//                 ),
//                 const SizedBox(height: 30),
//                 SlideTransition(
//                   position: _slideAnimation,
//                   child: FadeTransition(
//                     opacity: _fadeAnimation,
//                     child: const Text(
//                       "Secure Payment Gateway",
//                       style: TextStyle(
//                         color: Colors.white,
//                         fontSize: 28,
//                         fontWeight: FontWeight.bold,
//                         letterSpacing: 1.2,
//                       ),
//                     ),
//                   ),
//                 ),
//                 Padding(
//                   padding: const EdgeInsets.all(30.0),
//                   child: AnimatedContainer(
//                     duration: const Duration(milliseconds: 300),
//                     decoration: BoxDecoration(
//                       borderRadius: BorderRadius.circular(15),
//                       boxShadow: [
//                         BoxShadow(
//                           color: Colors.white.withOpacity(0.2),
//                           blurRadius: 10,
//                           spreadRadius: 2,
//                         ),
//                       ],
//                     ),
//                     child: TextFormField(
//                       controller: amtController,
//                       keyboardType: TextInputType.number,
//                       style: const TextStyle(color: Colors.white),
//                       decoration: InputDecoration(
//                         labelText: "Enter Amount",
//                         labelStyle: const TextStyle(color: Colors.white70),
//                         prefixIcon: const Icon(
//                           Icons.currency_rupee,
//                           color: Colors.white70,
//                         ),
//                         border: OutlineInputBorder(
//                           borderRadius: BorderRadius.circular(15),
//                           borderSide: BorderSide.none,
//                         ),
//                         filled: true,
//                         fillColor: Colors.white.withOpacity(0.1),
//                         focusedBorder: OutlineInputBorder(
//                           borderRadius: BorderRadius.circular(15),
//                           borderSide: const BorderSide(
//                             color: Colors.white,
//                             width: 1,
//                           ),
//                         ),
//                       ),
//                     ),
//                   ),
//                 ),
//                 const SizedBox(height: 20),
//                 AnimatedSwitcher(
//                   duration: const Duration(milliseconds: 300),
//                   child:
//                       _isProcessing
//                           ? const CircularProgressIndicator(color: Colors.white)
//                           : ScaleTransition(
//                             scale: Tween<double>(begin: 0.95, end: 1).animate(
//                               CurvedAnimation(
//                                 parent: _controller,
//                                 curve: Curves.easeInOut,
//                               ),
//                             ),
//                             child: ElevatedButton(
//                               onPressed: () {
//                                 if (amtController.text.isNotEmpty) {
//                                   FocusScope.of(context).unfocus();
//                                   int amount = int.parse(amtController.text);
//                                   openCheckout(amount);
//                                 }
//                               },
//                               style: ElevatedButton.styleFrom(
//                                 backgroundColor: Colors.green.shade700,
//                                 padding: const EdgeInsets.symmetric(
//                                   horizontal: 40,
//                                   vertical: 15,
//                                 ),
//                                 shape: RoundedRectangleBorder(
//                                   borderRadius: BorderRadius.circular(25),
//                                 ),
//                                 elevation: 5,
//                                 shadowColor: Colors.green.shade300,
//                               ),
//                               child: const Text(
//                                 "Pay Now",
//                                 style: TextStyle(
//                                   fontSize: 20,
//                                   fontWeight: FontWeight.w600,
//                                   letterSpacing: 1.1,
//                                 ),
//                               ),
//                             ),
//                           ),
//                 ),
//                 const SizedBox(height: 50),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }


import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

class RazorPayPage extends StatefulWidget {
      final String contractId;
  final double amount;
  final String userId; // Add userId parameter
  final Function(String) onSuccess; // Changed to accept payment ID

  const RazorPayPage({
    super.key,
    required this.contractId,
    required this.amount,
    required this.userId,
    required this.onSuccess,
  });

  @override
  State<RazorPayPage> createState() => _RazorPayPageState();
}

class _RazorPayPageState extends State<RazorPayPage>
    with SingleTickerProviderStateMixin {
    late Razorpay _razorpay;
    TextEditingController amtController = TextEditingController();
    late AnimationController _controller;
    late Animation<double> _fadeAnimation;
    late Animation<Offset> _slideAnimation;
    Map<String, dynamic>? _userData;
    bool _isLoadingUser = true;
    String? _errorMessage;
    bool _isProcessing = false;

    @override
    void initState() {
      super.initState();
      _loadUserData();
      amtController.text = widget.amount.toStringAsFixed(0);
      _razorpay = Razorpay();
      _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
      _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
      _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);

      _controller = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 1000),
      );

      _fadeAnimation = Tween<double>(
        begin: 0,
        end: 1,
      ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeIn));

      _slideAnimation = Tween<Offset>(
        begin: const Offset(0, -0.5),
        end: Offset.zero,
      ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

      _controller.forward();
    }

    Future<void> _loadUserData() async {
      try {
        final doc =
            await FirebaseFirestore.instance
                .collection('users')
                .doc(widget.userId)
                .get();

        if (doc.exists) {
          setState(() {
            _userData = doc.data() as Map<String, dynamic>;
            _isLoadingUser = false;
          });
        } else {
          setState(() {
            _errorMessage = 'User data not found';
            _isLoadingUser = false;
          });
        }
      } catch (e) {
        setState(() {
          _errorMessage = 'Failed to load user data: ${e.toString()}';
          _isLoadingUser = false;
        });
      }
    }

    void openCheckout(amount) async {
      setState(() => _isProcessing = true);
      final paiseAmount = (amount * 100).toInt();
      var options = {
        'key': 'rzp_test_r5X2FfLPXhBTl3',
        'amount': paiseAmount,
        'name': _userData!['name'] ?? 'Customer',
        'prefill': {
          'contact': _userData!['phone'] ?? '9999999999',
          'email': _userData!['email'] ?? 'customer@example.com',
        },
        'external': {
          'wallet': ['paytm'],
        },
      };
      try {
        _razorpay.open(options);
      } catch (e) {
        debugPrint('Error : $e');
      } finally {
        setState(() => _isProcessing = false);
      }
    }

    void _handlePaymentSuccess(PaymentSuccessResponse response) {
      if (response.paymentId != null) {
        widget.onSuccess(response.paymentId!); // Pass payment ID back
        Navigator.pop(context); // Close payment screen
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Payment ID: ${response.paymentId}"),
          backgroundColor: Colors.green,
        ),
      );
    }

    void _handlePaymentError(PaymentFailureResponse response) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red,
          content: Text("Payment Failed: ${response.message}"),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }

    void _handleExternalWallet(ExternalWalletResponse response) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.blue,
          content: Text("External Wallet: ${response.walletName}"),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }

    @override
    void dispose() {
      _razorpay.clear();
      _controller.dispose();
      super.dispose();
    }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        body: Container(
          height: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Colors.indigo.shade900, Colors.purple.shade800],
            ),
          ),
          child: SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 80),
                _buildAnimatedHeader(),
                _buildPaymentForm(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAnimatedHeader() {
    return Stack(
      alignment: Alignment.center,
      children: [
        AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Transform.translate(
              offset: Offset(0, -20 * (1 - _controller.value)),
              child: Opacity(opacity: _controller.value, child: child),
            );
          },
          child: Container(
            width: 300,
            height: 200,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.white.withOpacity(0.1),
                  blurRadius: 30,
                  spreadRadius: 10,
                ),
              ],
            ),
          ),
        ),
        FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: Image.network(
              'https://img.freepik.com/free-vector/hands-holding-credit-card-mobile-phone-with-banking-app-person-paying-with-bank-card-transferring-money-shopping-online-flat-vector-illustration-payment-finance-concept_74855-24760.jpg',
              width: 300,
              fit: BoxFit.cover,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentForm() {
    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(0, 0.5),
        end: Offset.zero,
      ).animate(
        CurvedAnimation(
          parent: _controller,
          curve: const Interval(0.3, 1.0, curve: Curves.easeOut),
        ),
      ),
      child: FadeTransition(
        opacity: Tween<double>(begin: 0, end: 1).animate(
          CurvedAnimation(
            parent: _controller,
            curve: const Interval(0.4, 1.0, curve: Curves.easeIn),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: Column(
            children: [
              const SizedBox(height: 30),
              _buildTitle(),
              const SizedBox(height: 40),
              _buildAmountInput(),
              const SizedBox(height: 40),
              _buildPayButton(),
              const SizedBox(height: 30),
              _buildSecurityBadges(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTitle() {
    return ShaderMask(
      shaderCallback:
          (bounds) => const LinearGradient(
            colors: [Colors.white, Colors.amber],
          ).createShader(bounds),
      child: const Text(
        "Secure Payment Gateway",
        style: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.w800,
          letterSpacing: 1.2,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildAmountInput() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.white.withOpacity(_isProcessing ? 0 : 0.2),
            blurRadius: 15,
            spreadRadius: 2,
          ),
        ],
      ),
      child: TextFormField(
        controller: amtController,
        keyboardType: TextInputType.number,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.w500,
        ),
        decoration: InputDecoration(
          labelText: "Enter Amount",
          labelStyle: const TextStyle(color: Colors.white70),
          prefixIcon: Padding(
            padding: const EdgeInsets.only(left: 20, right: 15),
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 1, end: 1.2),
              duration: const Duration(milliseconds: 200),
              builder:
                  (context, value, child) => Transform.scale(
                    scale: value,
                    child: const Icon(
                      Icons.currency_rupee,
                      color: Colors.white70,
                      size: 28,
                    ),
                  ),
            ),
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.white.withOpacity(0.15),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: const BorderSide(color: Colors.white, width: 1.5),
          ),
        ),
      ),
    );
  }

  Widget _buildPayButton() {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 500),
      transitionBuilder:
          (child, animation) => ScaleTransition(
            scale: animation,
            child: FadeTransition(opacity: animation, child: child),
          ),
      child:
          _isProcessing
              ? Column(
                children: [
                  const CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 3,
                  ),
                  const SizedBox(height: 20),
                  TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0.5, end: 1),
                    duration: const Duration(milliseconds: 800),
                    builder:
                        (context, value, child) => Opacity(
                          opacity: value,
                          child: const Text(
                            "Processing Payment...",
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                            ),
                          ),
                        ),
                  ),
                ],
              )
              : MouseRegion(
                onHover: (_) => _controller.forward(),
                onExit: (_) => _controller.reverse(),
                child: AnimatedBuilder(
                  animation: _controller,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: 1 + (_controller.value * 0.05),
                      child: child,
                    );
                  },
                  child: ElevatedButton(
                    onPressed: () {
                      if (amtController.text.isNotEmpty) {
                        FocusScope.of(context).unfocus();
                        int amount = int.parse(amtController.text);
                        openCheckout(amount);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green.shade700,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 40,
                        vertical: 15,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      elevation: 8,
                      shadowColor: Colors.green.shade300,
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.lock_outline, size: 22),
                        SizedBox(width: 12),
                        Text(
                          "PAY NOW",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
    );
  }

  Widget _buildSecurityBadges() {
    return FadeTransition(
      opacity: Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(parent: _controller, curve: const Interval(0.8, 1.0)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildSecurityIcon(Icons.security, "Secure"),
          _buildSecurityIcon(Icons.no_encryption_gmailerrorred, "Encrypted"),
          _buildSecurityIcon(Icons.verified_user, "Verified"),
        ],
      ),
    );
  }

  Widget _buildSecurityIcon(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Column(
        children: [
          Icon(icon, color: Colors.white70, size: 28),
          const SizedBox(height: 6),
          Text(
            text,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  // Keep existing methods (openCheckout, payment handlers, dispose)
  
}
