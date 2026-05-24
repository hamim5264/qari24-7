import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_colors.dart';
import '../controllers/subscription_controller.dart';
import '../widgets/payment_card_mock.dart';
import '../widgets/checkout_text_field.dart';
import 'payment_success_screen.dart';
import 'payment_failure_screen.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _formKey = GlobalKey<FormState>();
  final _cardNumberController = TextEditingController();
  final _cardOwnerController = TextEditingController();
  final _cardExpiryController = TextEditingController();
  final _cardCvvController = TextEditingController();
  final _emailController = TextEditingController();

  final SubscriptionController controller = Get.find<SubscriptionController>();

  bool _simulateFailure = false;

  @override
  void initState() {
    super.initState();
    _cardNumberController.text = controller.cardNumber.value;
    _cardOwnerController.text = controller.cardOwner.value;
    _cardExpiryController.text = controller.cardExpiry.value;
    _cardCvvController.text = controller.cardCvv.value;
    _emailController.text = controller.emailAddress.value;
  }

  @override
  void dispose() {
    _cardNumberController.dispose();
    _cardOwnerController.dispose();
    _cardExpiryController.dispose();
    _cardCvvController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _handlePayment() async {
    if (!_formKey.currentState!.validate()) return;

    controller.cardNumber.value = _cardNumberController.text;
    controller.cardOwner.value = _cardOwnerController.text;
    controller.cardExpiry.value = _cardExpiryController.text;
    controller.cardCvv.value = _cardCvvController.text;
    controller.emailAddress.value = _emailController.text;

    FocusScope.of(context).unfocus();

    final success = await controller.processPayment(
      simulateFailure: _simulateFailure,
    );

    if (success) {
      Get.off(() => const PaymentSuccessScreen());
    } else {
      Get.off(() => const PaymentFailureScreen());
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final titleColor = isDark ? Colors.white : AppColors.primary;
    final surfaceColor = isDark
        ? AppColors.surfaceDark
        : AppColors.surfaceLight;
    final borderColor = isDark ? Colors.grey.shade900 : Colors.grey.shade200;

    return Scaffold(
      backgroundColor: isDark
          ? AppColors.backgroundDark
          : AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: isDark ? Colors.white : Colors.black87,
          ),
          onPressed: () => Get.back(),
        ),
        title: Text(
          'checkout_title'.tr,
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.all(24.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const PaymentCardMock(),
                      const SizedBox(height: 28),

                      Text(
                        'payment_details'.tr,
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: titleColor,
                        ),
                      ),
                      const SizedBox(height: 16),

                      CheckoutTextField(
                        labelText: 'Cardholder Name',
                        hintText: 'Enter name',
                        controller: _cardOwnerController,
                        prefixIcon: const Icon(Icons.person_outline_rounded),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter cardholder name';
                          }
                          return null;
                        },
                        onChanged: (val) => controller.cardOwner.value = val,
                      ),
                      const SizedBox(height: 18),

                      CheckoutTextField(
                        labelText: 'card_number'.tr,
                        hintText: 'XXXX XXXX XXXX XXXX',
                        controller: _cardNumberController,
                        keyboardType: TextInputType.number,
                        prefixIcon: const Icon(Icons.credit_card_outlined),
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(16),
                          CardNumberInputFormatter(),
                        ],
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter card number';
                          }
                          if (value.replaceAll(' ', '').length < 16) {
                            return 'Card number must be 16 digits';
                          }
                          return null;
                        },
                        onChanged: (val) => controller.cardNumber.value = val,
                      ),
                      const SizedBox(height: 18),

                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: CheckoutTextField(
                              labelText: 'expiry_label'.tr,
                              hintText: 'MM/YY',
                              controller: _cardExpiryController,
                              keyboardType: TextInputType.number,
                              prefixIcon: const Icon(
                                Icons.calendar_today_outlined,
                              ),
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                                LengthLimitingTextInputFormatter(4),
                                CardExpiryInputFormatter(),
                              ],
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Enter expiry';
                                }
                                if (!value.contains('/') || value.length < 5) {
                                  return 'Invalid date';
                                }
                                return null;
                              },
                              onChanged: (val) =>
                                  controller.cardExpiry.value = val,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: CheckoutTextField(
                              labelText: 'cvv_label'.tr,
                              hintText: 'XXX',
                              controller: _cardCvvController,
                              obscureText: true,
                              keyboardType: TextInputType.number,
                              prefixIcon: const Icon(
                                Icons.lock_outline_rounded,
                              ),
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                                LengthLimitingTextInputFormatter(3),
                              ],
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Enter CVV';
                                }
                                if (value.length < 3) {
                                  return 'Invalid CVV';
                                }
                                return null;
                              },
                              onChanged: (val) =>
                                  controller.cardCvv.value = val,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),

                      CheckoutTextField(
                        labelText: 'email_address'.tr,
                        hintText: 'email@domain.com',
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        prefixIcon: const Icon(Icons.mail_outline_rounded),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter email address';
                          }
                          if (!GetUtils.isEmail(value)) {
                            return 'Please enter a valid email address';
                          }
                          return null;
                        },
                        onChanged: (val) => controller.emailAddress.value = val,
                      ),
                      const SizedBox(height: 24),

                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.success.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: AppColors.success.withValues(alpha: 0.2),
                          ),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.security_rounded,
                              color: AppColors.success,
                              size: 20,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'secure_payment'.tr,
                                style: const TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.success,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 28),

                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.orange.withValues(
                            alpha: isDark ? 0.15 : 0.08,
                          ),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: Colors.orange.withValues(alpha: 0.4),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.bug_report_rounded,
                              color: Colors.orange.shade700,
                            ),
                            const SizedBox(width: 12),
                            const Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Sandbox Testing Tool',
                                    style: TextStyle(
                                      fontFamily: 'Inter',
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.orange,
                                    ),
                                  ),
                                  SizedBox(height: 2),
                                  Text(
                                    'Toggle below to test the Failure Receipt screen.',
                                    style: TextStyle(
                                      fontFamily: 'Inter',
                                      fontSize: 10,
                                      color: Colors.orange,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Switch(
                              value: _simulateFailure,
                              activeThumbColor: Colors.orange,
                              onChanged: (val) {
                                setState(() {
                                  _simulateFailure = val;
                                });
                              },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),

            Obx(() {
              final isProcessing = controller.isProcessingPayment.value;
              final amountStr = controller.selectedPlan.value == 'Yearly'
                  ? '\$200.00'
                  : '\$20.00';

              return Container(
                padding: const EdgeInsets.all(24.0),
                decoration: BoxDecoration(
                  color: surfaceColor,
                  border: Border(
                    top: BorderSide(color: borderColor, width: 0.5),
                  ),
                ),
                child: SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 2,
                      shadowColor: AppColors.primary.withValues(alpha: 0.4),
                    ),
                    onPressed: isProcessing ? null : _handlePayment,
                    child: isProcessing
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2.5,
                            ),
                          )
                        : Text(
                            'pay_amount'.tr.replaceAll('@amount', amountStr),
                            style: const TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                          ),
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}

class CardNumberInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    var text = newValue.text;

    if (newValue.selection.baseOffset == 0) {
      return newValue;
    }

    var buffer = StringBuffer();
    for (int i = 0; i < text.length; i++) {
      buffer.write(text[i]);
      var nonZeroIndex = i + 1;
      if (nonZeroIndex % 4 == 0 && nonZeroIndex != text.length) {
        buffer.write(' ');
      }
    }

    var string = buffer.toString();
    return newValue.copyWith(
      text: string,
      selection: TextSelection.collapsed(offset: string.length),
    );
  }
}

class CardExpiryInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    var text = newValue.text;

    if (newValue.selection.baseOffset == 0) {
      return newValue;
    }

    var buffer = StringBuffer();
    for (int i = 0; i < text.length; i++) {
      buffer.write(text[i]);
      var nonZeroIndex = i + 1;
      if (nonZeroIndex == 2 && nonZeroIndex != text.length) {
        buffer.write('/');
      }
    }

    var string = buffer.toString();
    return newValue.copyWith(
      text: string,
      selection: TextSelection.collapsed(offset: string.length),
    );
  }
}
