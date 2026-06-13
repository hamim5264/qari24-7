import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/constants/app_colors.dart';
import '../../settings/controllers/settings_controller.dart';
import '../controllers/subscription_controller.dart';
import '../screens/payment_success_screen.dart';
import '../screens/payment_failure_screen.dart';

class StripePaymentBottomSheet extends StatefulWidget {
  final SubscriptionController controller;
  const StripePaymentBottomSheet({super.key, required this.controller});

  static void show(BuildContext context, SubscriptionController controller) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StripePaymentBottomSheet(controller: controller),
    );
  }

  @override
  State<StripePaymentBottomSheet> createState() => _StripePaymentBottomSheetState();
}

class _StripePaymentBottomSheetState extends State<StripePaymentBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  final _cardNumberController = TextEditingController();
  final _cardOwnerController = TextEditingController();
  final _cardExpiryController = TextEditingController();
  final _cardCvvController = TextEditingController();
  final _emailController = TextEditingController();
  final _zipController = TextEditingController();

  bool _savePaymentInfo = true;
  bool _isPaying = false;
  bool _hasSavedCard = false;
  String _savedCardLast4 = '';
  
  // Controls which sub-screen is showing: 'methods' or 'add_card'
  String _currentScreen = 'methods'; 

  @override
  void initState() {
    super.initState();
    _cardNumberController.text = widget.controller.cardNumber.value;
    _cardOwnerController.text = widget.controller.cardOwner.value;
    _cardExpiryController.text = widget.controller.cardExpiry.value;
    _cardCvvController.text = widget.controller.cardCvv.value;
    final emailVal = widget.controller.emailAddress.value.isNotEmpty
        ? widget.controller.emailAddress.value
        : (Get.isRegistered<SettingsController>()
            ? Get.find<SettingsController>().email.value
            : '');
    _emailController.text = emailVal;
    _zipController.text = '10001'; // Default ZIP code
    _checkSavedCard();
  }

  Future<void> _checkSavedCard() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final last4 = prefs.getString('auth_saved_card_last4');
      if (last4 != null && last4.isNotEmpty) {
        setState(() {
          _hasSavedCard = true;
          _savedCardLast4 = last4;
        });
      }
    } catch (_) {}
  }

  @override
  void dispose() {
    _cardNumberController.dispose();
    _cardOwnerController.dispose();
    _cardExpiryController.dispose();
    _cardCvvController.dispose();
    _emailController.dispose();
    _zipController.dispose();
    super.dispose();
  }

  Future<void> _handlePayment() async {
    if (_currentScreen == 'add_card') {
      if (!_formKey.currentState!.validate()) return;
    }

    widget.controller.cardNumber.value = _cardNumberController.text;
    widget.controller.cardOwner.value = _cardOwnerController.text;
    widget.controller.cardExpiry.value = _cardExpiryController.text;
    widget.controller.cardCvv.value = _cardCvvController.text;
    widget.controller.emailAddress.value = _emailController.text;

    FocusScope.of(context).unfocus();
    setState(() {
      _isPaying = true;
    });

    final success = await widget.controller.processPayment(simulateFailure: false);

    setState(() {
      _isPaying = false;
    });

    if (success) {
      if (_savePaymentInfo && _currentScreen == 'add_card') {
        final cardNum = _cardNumberController.text.replaceAll(' ', '');
        if (cardNum.length >= 4) {
          final last4 = cardNum.substring(cardNum.length - 4);
          try {
            final prefs = await SharedPreferences.getInstance();
            await prefs.setString('auth_saved_card_last4', last4);
          } catch (_) {}
        }
      }
      Get.back(); // close bottom sheet
      Get.to(() => const PaymentSuccessScreen());

      if (_savePaymentInfo && _currentScreen == 'add_card') {
        _showSaveCardInfoDialog();
      }
    } else {
      Get.back(); // close bottom sheet
      Get.to(() => const PaymentFailureScreen());
    }
  }

  void _showSaveCardInfoDialog() {
    Get.dialog(
      AlertDialog(
        backgroundColor: const Color(0xFF161616),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Row(
          children: [
            Icon(Icons.security_rounded, color: AppColors.primary, size: 24),
            SizedBox(width: 8),
            Text(
              "Save Payment Info?",
              style: TextStyle(
                color: Colors.white,
                fontFamily: 'Inter',
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ],
        ),
        content: const Text(
          "Would you like to securely save this card's reference on your device for one-click future purchases?",
          style: TextStyle(
            color: Colors.white70,
            fontFamily: 'Inter',
            height: 1.4,
            fontSize: 13,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text(
              "NOT NOW",
              style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold),
            ),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              Get.snackbar(
                "Info Saved",
                "Your payment card preference was saved.",
                snackPosition: SnackPosition.BOTTOM,
                backgroundColor: const Color(0xFF06402B),
                colorText: Colors.white,
              );
            },
            child: const Text(
              "SAVE CARD",
              style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final viewInsets = MediaQuery.of(context).viewInsets;
    final sheetBg = isDark ? const Color(0xFF161616) : Colors.white;
    final textGrey = isDark ? Colors.grey.shade400 : Colors.grey.shade600;
    final titleColor = isDark ? Colors.white : AppColors.primary;
    final dividerColor = isDark ? Colors.grey.shade800 : Colors.grey.shade300;

    return AnimatedSize(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      child: Container(
        padding: EdgeInsets.only(
          left: 24,
          right: 24,
          top: 16,
          bottom: 24 + viewInsets.bottom,
        ),
        decoration: BoxDecoration(
          color: sheetBg,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          border: Border.all(
            color: isDark ? Colors.grey.shade900 : Colors.grey.shade100,
            width: 1.5,
          ),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 44,
                  height: 5,
                  decoration: BoxDecoration(
                    color: isDark ? Colors.grey.shade800 : Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              
              // Conditional navigation header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _currentScreen == 'add_card'
                      ? GestureDetector(
                          onTap: () {
                            setState(() {
                              _currentScreen = 'methods';
                            });
                          },
                          child: Row(
                            children: [
                              Icon(Icons.arrow_back_ios_new_rounded, size: 16, color: titleColor),
                              const SizedBox(width: 8),
                              Text(
                                'Add new card',
                                style: TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: titleColor,
                                ),
                              ),
                            ],
                          ),
                        )
                      : Text(
                          'Payment Details',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: titleColor,
                          ),
                        ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () => Get.back(),
                  ),
                ],
              ),
              Divider(color: dividerColor),
              const SizedBox(height: 12),

              // Switch screen contents
              _currentScreen == 'methods' 
                  ? _buildMethodsScreen(isDark, textGrey, titleColor, dividerColor)
                  : _buildAddCardForm(isDark, textGrey, titleColor, dividerColor),
            ],
          ),
        ),
      ),
    );
  }

  // 1. Methods screen containing Apple Pay, Link, Saved cards, and options
  Widget _buildMethodsScreen(bool isDark, Color textGrey, Color titleColor, Color dividerColor) {
    final amountStr = '\$${widget.controller.activeAmount.toStringAsFixed(2)}';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Apple Pay button
        SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              elevation: 0,
            ),
            onPressed: _handlePayment,
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  ' Pay',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),

        // Pay with link button
        SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF00D66F),
              foregroundColor: Colors.black,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              elevation: 0,
            ),
            onPressed: _handlePayment,
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Pay with ',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: Colors.black,
                  ),
                ),
                Text(
                  'link',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Divider
        Row(
          children: [
            Expanded(child: Divider(color: dividerColor)),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              child: Text(
                'Or pay using',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: textGrey,
                ),
              ),
            ),
            Expanded(child: Divider(color: dividerColor)),
          ],
        ),
        const SizedBox(height: 16),

        // Saved Card Section
        if (_hasSavedCard) ...[
          Text(
            'Saved',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: titleColor,
            ),
          ),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: () {
              // Populate mock credentials and pay
              widget.controller.cardNumber.value = '4000 1234 5678 $_savedCardLast4';
              widget.controller.cardExpiry.value = '12/28';
              widget.controller.cardCvv.value = '123';
              widget.controller.cardOwner.value = widget.controller.cardOwner.value.isNotEmpty
                  ? widget.controller.cardOwner.value
                  : 'Saved Cardholder';
              _handlePayment();
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E1E1E) : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: isDark ? Colors.grey.shade900 : Colors.grey.shade200,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.credit_card, color: AppColors.secondary, size: 20),
                      const SizedBox(width: 12),
                      Text(
                        '•••• $_savedCardLast4',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: titleColor,
                        ),
                      ),
                    ],
                  ),
                  GestureDetector(
                    onTap: () {
                      Get.snackbar("Saved Cards", "Standard card authorization active.");
                    },
                    child: const Text(
                      'View more >',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],

        // New Payment Method Section
        Text(
          'New payment method',
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: titleColor,
          ),
        ),
        const SizedBox(height: 8),

        // Card option
        _buildPaymentMethodOption(
          icon: Icons.credit_card_rounded,
          title: 'New card',
          onTap: () {
            setState(() {
              _currentScreen = 'add_card';
            });
          },
          isDark: isDark,
        ),
        const SizedBox(height: 8),

        // Klarna option
        _buildPaymentMethodOption(
          icon: Icons.shopping_bag_outlined,
          title: 'Klarna',
          subtitle: 'Buy now or pay later with Klarna',
          onTap: () => _handlePayment(),
          isDark: isDark,
        ),
        const SizedBox(height: 8),

        // Cash App Pay option
        _buildPaymentMethodOption(
          icon: Icons.monetization_on_outlined,
          title: 'Cash App Pay',
          onTap: () => _handlePayment(),
          isDark: isDark,
        ),

        const SizedBox(height: 24),

        // Checkout pay button
        SizedBox(
          width: double.infinity,
          height: 54,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 2,
            ),
            onPressed: _isPaying ? null : () {
              if (_hasSavedCard) {
                widget.controller.cardNumber.value = '4000 1234 5678 $_savedCardLast4';
                widget.controller.cardExpiry.value = '12/28';
                widget.controller.cardCvv.value = '123';
                widget.controller.cardOwner.value = widget.controller.cardOwner.value.isNotEmpty
                    ? widget.controller.cardOwner.value
                    : 'Saved Cardholder';
                _handlePayment();
              } else {
                setState(() {
                  _currentScreen = 'add_card';
                });
              }
            },
            child: _isPaying
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2.5,
                    ),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Pay $amountStr',
                        style: const TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(Icons.lock, size: 16),
                    ],
                  ),
          ),
        ),
      ],
    );
  }

  // Helper payment list option card
  Widget _buildPaymentMethodOption({
    required IconData icon,
    required String title,
    String? subtitle,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E1E1E) : Colors.grey.shade500.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isDark ? Colors.grey.shade900 : Colors.grey.shade200,
          ),
        ),
        child: Row(
          children: [
            Icon(icon, color: isDark ? Colors.grey.shade400 : AppColors.primary, size: 22),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 11.5,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Colors.grey.shade500),
          ],
        ),
      ),
    );
  }

  // 2. Add New Card Form Screen
  Widget _buildAddCardForm(bool isDark, Color textGrey, Color titleColor, Color dividerColor) {
    final amountStr = '\$${widget.controller.activeAmount.toStringAsFixed(2)}';

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Email field
          const Text(
            'Account Info',
            style: TextStyle(fontFamily: 'Inter', fontSize: 13, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          TextFormField(
            controller: _emailController,
            style: const TextStyle(color: Colors.white, fontSize: 14),
            keyboardType: TextInputType.emailAddress,
            decoration: _getInputDecoration('Email address', isDark),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter email address';
              }
              if (!GetUtils.isEmail(value)) {
                return 'Please enter a valid email address';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),

          // Name field
          const Text(
            'Cardholder Name',
            style: TextStyle(fontFamily: 'Inter', fontSize: 13, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          TextFormField(
            controller: _cardOwnerController,
            style: const TextStyle(color: Colors.white, fontSize: 14),
            decoration: _getInputDecoration('Enter cardholder name', isDark),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please enter cardholder name';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),

          // Card Information (Combined container)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Card information',
                style: TextStyle(fontFamily: 'Inter', fontSize: 13, fontWeight: FontWeight.bold),
              ),
              GestureDetector(
                onTap: () {
                  Get.snackbar("Scan Card", "Card scanning simulation activated.");
                },
                child: const Row(
                  children: [
                    Icon(Icons.camera_alt_outlined, size: 14, color: AppColors.primary),
                    SizedBox(width: 4),
                    Text(
                      'Scan card',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          
          // Card fields grid
          Container(
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E1E1E) : Colors.grey.shade100,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: dividerColor),
            ),
            child: Column(
              children: [
                // Card number input
                TextFormField(
                  controller: _cardNumberController,
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(16),
                    CardNumberInputFormatter(),
                  ],
                  decoration: InputDecoration(
                    hintText: 'Card number',
                    hintStyle: TextStyle(color: Colors.grey.shade500, fontSize: 14),
                    prefixIcon: const Icon(Icons.credit_card_outlined, size: 18, color: Colors.grey),
                    suffixIcon: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12.0),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _buildBrandIcon('Visa'),
                          const SizedBox(width: 4),
                          _buildBrandIcon('MC'),
                          const SizedBox(width: 4),
                          _buildBrandIcon('Amex'),
                        ],
                      ),
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter card number';
                    }
                    if (value.replaceAll(' ', '').length < 16) {
                      return 'Card number must be 16 digits';
                    }
                    return null;
                  },
                ),
                Divider(height: 1, color: dividerColor),
                
                // Expiry and CVC input
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _cardExpiryController,
                        style: const TextStyle(color: Colors.white, fontSize: 14),
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(4),
                          CardExpiryInputFormatter(),
                        ],
                        decoration: InputDecoration(
                          hintText: 'MM / YY',
                          hintStyle: TextStyle(color: Colors.grey.shade500, fontSize: 14),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Enter expiry';
                          }
                          if (!value.contains('/') || value.length < 5) {
                            return 'Invalid date';
                          }
                          return null;
                        },
                      ),
                    ),
                    Container(width: 1, height: 44, color: dividerColor),
                    Expanded(
                      child: TextFormField(
                        controller: _cardCvvController,
                        style: const TextStyle(color: Colors.white, fontSize: 14),
                        obscureText: true,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(3),
                        ],
                        decoration: InputDecoration(
                          hintText: 'CVC',
                          hintStyle: TextStyle(color: Colors.grey.shade500, fontSize: 14),
                          suffixIcon: const Icon(Icons.help_outline_rounded, size: 18, color: Colors.grey),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Enter CVC';
                          }
                          if (value.length < 3) {
                            return 'Invalid CVC';
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),

          // Billing Address (Country, ZIP)
          const Text(
            'Billing address',
            style: TextStyle(fontFamily: 'Inter', fontSize: 13, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          Container(
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E1E1E) : Colors.grey.shade100,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: dividerColor),
            ),
            child: Column(
              children: [
                // Country Region Dropdown (using initialValue to resolve deprecation warning)
                DropdownButtonFormField<String>(
                  initialValue: 'United States',
                  style: TextStyle(color: isDark ? Colors.white : Colors.black87, fontSize: 14),
                  dropdownColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                  items: ['United States', 'United Kingdom', 'Canada', 'Bangladesh', 'Saudi Arabia']
                      .map((label) => DropdownMenuItem(
                            value: label,
                            child: Text(label),
                          ))
                      .toList(),
                  onChanged: (val) {},
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  ),
                ),
                Divider(height: 1, color: dividerColor),
                // ZIP Code field
                TextFormField(
                  controller: _zipController,
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    hintText: 'ZIP',
                    hintStyle: TextStyle(color: Colors.grey.shade500, fontSize: 14),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'ZIP is required';
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // Save card checkbox
          Row(
            children: [
              Checkbox(
                value: _savePaymentInfo,
                activeColor: AppColors.primary,
                onChanged: (val) {
                  setState(() {
                    _savePaymentInfo = val ?? true;
                  });
                },
              ),
              Text(
                'Save this card for future payments',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 12.5,
                  color: textGrey,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Submit Pay Button
          SizedBox(
            width: double.infinity,
            height: 54,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 2,
              ),
              onPressed: _isPaying ? null : _handlePayment,
              child: _isPaying
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2.5,
                      ),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Pay $amountStr',
                          style: const TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Icon(Icons.lock, size: 16),
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }

  // Helper decoration
  InputDecoration _getInputDecoration(String hint, bool isDark) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: Colors.grey.shade500, fontSize: 14),
      filled: true,
      fillColor: isDark ? const Color(0xFF1E1E1E) : Colors.grey.shade500.withValues(alpha: 0.05),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: isDark ? Colors.grey.shade900 : Colors.grey.shade200,
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: isDark ? Colors.grey.shade900 : Colors.grey.shade200,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    );
  }

  // Brand icons mock helper
  Widget _buildBrandIcon(String brand) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        brand,
        style: const TextStyle(
          color: Colors.black,
          fontSize: 7.5,
          fontWeight: FontWeight.w900,
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
