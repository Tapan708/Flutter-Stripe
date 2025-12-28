import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import 'package:flutter_stripe/flutter_stripe.dart';

import '../config/stripe_config.dart';
import '../models/course.dart';

class PurchaseState {
  final bool isLoading;
  final bool isPurchased;
  final String? error;

  const PurchaseState({this.isLoading = false, this.isPurchased = false, this.error});

  PurchaseState copyWith({bool? isLoading, bool? isPurchased, String? error}) {
    return PurchaseState(
      isLoading: isLoading ?? this.isLoading,
      isPurchased: isPurchased ?? this.isPurchased,
      error: error ?? this.error,
    );
  }
}

class PurchaseNotifier extends StateNotifier<PurchaseState> {
  final Course course;
  PurchaseNotifier(this.course) : super(const PurchaseState());

  Future<bool> makePayment() async {
    try {
      state = state.copyWith(isLoading: true, error: null);

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
          merchantDisplayName: course.name,
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

      state = state.copyWith(isLoading: false);

      await Stripe.instance.presentPaymentSheet();

      state = state.copyWith(isPurchased: true);
      return true;
    } on StripeException catch (e) {
      state = state.copyWith(isLoading: false, error: e.error.localizedMessage);
      rethrow;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      rethrow;
    }
  }
}

final coursePurchaseProvider = StateNotifierProvider.autoDispose.family<PurchaseNotifier, PurchaseState, Course>(
  (ref, course) => PurchaseNotifier(course),
);