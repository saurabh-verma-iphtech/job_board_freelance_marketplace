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
              colors: [Colors.blue.shade800, Colors.purple.shade600],
            ),
          ),
          child: SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 80),
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
                const SizedBox(height: 30),
                SlideTransition(
                  position: _slideAnimation,
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: const Text(
                      "Secure Payment Gateway",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(30.0),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.white.withOpacity(0.2),
                          blurRadius: 10,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: TextFormField(
                      controller: amtController,
                      keyboardType: TextInputType.number,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        labelText: "Enter Amount",
                        labelStyle: const TextStyle(color: Colors.white70),
                        prefixIcon: const Icon(
                          Icons.currency_rupee,
                          color: Colors.white70,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: Colors.white.withOpacity(0.1),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide: const BorderSide(
                            color: Colors.white,
                            width: 1,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child:
                      _isProcessing
                          ? const CircularProgressIndicator(color: Colors.white)
                          : ScaleTransition(
                            scale: Tween<double>(begin: 0.95, end: 1).animate(
                              CurvedAnimation(
                                parent: _controller,
                                curve: Curves.easeInOut,
                              ),
                            ),
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
                                  borderRadius: BorderRadius.circular(25),
                                ),
                                elevation: 5,
                                shadowColor: Colors.green.shade300,
                              ),
                              child: const Text(
                                "Pay Now",
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 1.1,
                                ),
                              ),
                            ),
                          ),
                ),
                const SizedBox(height: 50),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
