import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_colors.dart';
import '../controllers/subscription_controller.dart';

class PaymentCardMock extends StatelessWidget {
  final String? cardNumber;
  final String? cardOwner;
  final String? cardExpiry;
  final String? cardCvv;

  const PaymentCardMock({
    super.key,
    this.cardNumber,
    this.cardOwner,
    this.cardExpiry,
    this.cardCvv,
  });

  @override
  Widget build(BuildContext context) {
    final SubscriptionController controller =
        Get.find<SubscriptionController>();

    return Obx(() {
      final numStr = cardNumber ?? controller.cardNumber.value;
      final nameStr = cardOwner ?? controller.cardOwner.value;
      final expiryStr = cardExpiry ?? controller.cardExpiry.value;

      String displayCardNumber = numStr;
      if (numStr.length >= 19) {
        displayCardNumber = numStr;
      } else {
        displayCardNumber = numStr;
      }

      return Container(
        width: double.infinity,
        height: 200,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF0F4E36), Color(0xFF042417), Color(0xFFEFBF04)],
            stops: [0.0, 0.75, 1.0],
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.3),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Stack(
          children: [
            Positioned(
              right: -30,
              top: -30,
              child: Container(
                width: 150,
                height: 150,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.03),
                ),
              ),
            ),
            Positioned(
              left: -50,
              bottom: -50,
              child: Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.02),
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'QARI 24/7',
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 16,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 2,
                              color: AppColors.secondary,
                              shadows: [
                                Shadow(
                                  blurRadius: 4,
                                  color: Colors.black.withValues(alpha: 0.5),
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 2),
                          const Text(
                            'PREMIUM MEMBER',
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 8,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1,
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ),
                      Stack(
                        children: [
                          Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: Colors.red.withValues(alpha: 0.9),
                              shape: BoxShape.circle,
                            ),
                          ),
                          Positioned(
                            left: 14,
                            child: Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                color: Colors.amber.withValues(alpha: 0.85),
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  Container(
                    width: 36,
                    height: 28,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE5B80B),
                      borderRadius: BorderRadius.circular(6),
                      gradient: const LinearGradient(
                        colors: [
                          Color(0xFFF9D976),
                          Color(0xFFE5B80B),
                          Color(0xFFB58A00),
                        ],
                      ),
                    ),
                    child: Stack(
                      children: [
                        Positioned(
                          left: 10,
                          top: 0,
                          bottom: 0,
                          child: Container(
                            width: 1,
                            color: Colors.black.withValues(alpha: 0.1),
                          ),
                        ),
                        Positioned(
                          left: 20,
                          top: 0,
                          bottom: 0,
                          child: Container(
                            width: 1,
                            color: Colors.black.withValues(alpha: 0.1),
                          ),
                        ),
                        Positioned(
                          top: 9,
                          left: 0,
                          right: 0,
                          child: Container(
                            height: 1,
                            color: Colors.black.withValues(alpha: 0.1),
                          ),
                        ),
                        Positioned(
                          top: 18,
                          left: 0,
                          right: 0,
                          child: Container(
                            height: 1,
                            color: Colors.black.withValues(alpha: 0.1),
                          ),
                        ),
                      ],
                    ),
                  ),

                  Text(
                    displayCardNumber,
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2.5,
                      color: Colors.white,
                      shadows: [
                        Shadow(
                          blurRadius: 4,
                          color: Colors.black.withValues(alpha: 0.5),
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                  ),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'CARD HOLDER',
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 8,
                                fontWeight: FontWeight.bold,
                                color: Colors.white54,
                                letterSpacing: 0.5,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              nameStr.toUpperCase(),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          const Text(
                            'EXPIRES',
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 8,
                              fontWeight: FontWeight.bold,
                              color: Colors.white54,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            expiryStr,
                            style: const TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    });
  }
}
