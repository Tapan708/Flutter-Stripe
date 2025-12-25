import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import '../config/stripe_config.dart';
import '../models/course.dart';

class CourseDetailScreen extends StatefulWidget {
  final Course course;

  const CourseDetailScreen({super.key, required this.course});

  @override
  State<CourseDetailScreen> createState() => _CourseDetailScreenState();
}

class _CourseDetailScreenState extends State<CourseDetailScreen> {
  bool _isLoading = false;
  bool _isPurchased = false;

  Future<void> _showLoading() async {
    setState(() => _isLoading = true);
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );
  }

  void _hideLoading() {
    if (_isLoading) _isLoading = false;
    if (Navigator.canPop(context)) Navigator.of(context).pop();
  }

  Future<void> _makePayment() async {
    try {
      await _showLoading();

      final dio = Dio();
      final amount = 999;

      final resp = await dio.post(
        'https://api.stripe.com/v1/payment_intents',
        data: {
          'amount': amount.toString(),
          'currency': 'usd',
          'payment_method_types[]': 'card',
        },
        options: Options(
          contentType: Headers.formUrlEncodedContentType,
          headers: {
            'Authorization': 'Bearer ${StripeConfig.secretKey}',
          },
        ),
      );

      final clientSecret = resp.data['client_secret'] as String?;
      if (clientSecret == null) throw Exception('Missing client secret');

      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: clientSecret,
          merchantDisplayName: widget.course.name,
          billingDetails: const BillingDetails(
            address: Address(
              country: 'US',
              city: 'New York',
              line1: '123 Main St',
              line2: '',
              postalCode: '10001',
              state: 'NY',
            ),
          ),
          billingDetailsCollectionConfiguration: const BillingDetailsCollectionConfiguration(
            address: AddressCollectionMode.never,
            attachDefaultsToPaymentMethod: true,
          ),
        ),
      );

      _hideLoading();

      await Stripe.instance.presentPaymentSheet();

      // mark course as purchased so lock icons are removed
      setState(() => _isPurchased = true);

      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Payment successful ✅')));
    } on StripeException catch (e) {
      _hideLoading();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Payment canceled: ${e.error.localizedMessage}')));
    } catch (e) {
      _hideLoading();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Payment failed: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final course = widget.course;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.deepPurple,
        title: Text(
          course.name,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Image.network(
                course.image,
                width: 120,
                height: 120,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return const Icon(
                    Icons.code,
                    size: 120,
                    color: Colors.grey,
                  );
                },
              ),
            ),
            const SizedBox(height: 20),
            Center(
              child: Text(
                course.name,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 30),
            const Text(
              'Chapters:',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: course.chapters.length,
                itemBuilder: (context, index) {
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Row(
                      children: [
                        Text(
                          '${index + 1}.',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.deepPurple,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            course.chapters[index],
                            style: const TextStyle(
                              fontSize: 16,
                            ),
                          ),
                        ),
                        _isPurchased
                            ? const SizedBox.shrink()
                            : const Icon(
                                Icons.lock,
                                color: Colors.grey,
                                size: 20,
                              ),
                      ],
                    ),
                  );
                },
              ),
            ),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: ElevatedButton(
                onPressed: _makePayment,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Make Payment',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}