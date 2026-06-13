import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_colors.dart';
import '../controllers/subscription_controller.dart';

class PaymentHistoryScreen extends StatelessWidget {
  const PaymentHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final controller = Get.find<SubscriptionController>();

    final titleColor = isDark ? Colors.white : AppColors.primary;
    final textGrey = isDark ? Colors.grey.shade400 : Colors.grey.shade600;
    final cardBgColor = isDark ? const Color(0xFF161616) : Colors.white;

    // Refresh history when screen opens
    controller.fetchPaymentHistory();

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
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
          'Payment History',
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
        child: Obx(() {
          final history = controller.rxPaymentHistory;

          if (history.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.receipt_long_outlined,
                    size: 64,
                    color: textGrey.withValues(alpha: 0.5),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No payments found',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white70 : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Your subscription invoice history will show here.',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 13,
                      color: textGrey,
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
            itemCount: history.length,
            itemBuilder: (context, index) {
              final payment = history[index];
              final plan = payment['plan'] as String? ?? 'subscription';
              final amount = double.tryParse(payment['amount'].toString()) ?? 0.0;
              final status = payment['status'] as String? ?? 'paid';
              final createdAtStr = payment['created_at'] as String? ?? '';
              final invoiceId = payment['stripe_invoice_id'] as String? ?? '';

              final shortInvoice = invoiceId.length > 18
                  ? '${invoiceId.substring(0, 8)}...${invoiceId.substring(invoiceId.length - 6)}'
                  : invoiceId;

              String formattedDate = '';
              if (createdAtStr.isNotEmpty) {
                try {
                  final parsedDate = DateTime.parse(createdAtStr);
                  formattedDate = '${parsedDate.day}/${parsedDate.month}/${parsedDate.year}';
                } catch (_) {
                  formattedDate = createdAtStr;
                }
              }

              final isSuccess = status.toLowerCase() == 'paid' || status.toLowerCase() == 'succeeded';

              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: cardBgColor,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isDark ? Colors.grey.shade900 : Colors.grey.shade100,
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: isDark
                          ? Colors.black.withValues(alpha: 0.15)
                          : Colors.grey.withValues(alpha: 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: isSuccess
                            ? AppColors.success.withValues(alpha: 0.1)
                            : AppColors.error.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        isSuccess ? Icons.check_circle_outline_rounded : Icons.error_outline_rounded,
                        color: isSuccess ? AppColors.success : AppColors.error,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            plan.toUpperCase(),
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: titleColor,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Invoice: ${shortInvoice.isNotEmpty ? shortInvoice : "N/A"}',
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 11,
                              color: textGrey,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            formattedDate,
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 11,
                              color: textGrey,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '\$${amount.toStringAsFixed(2)}',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: titleColor,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: isSuccess
                                ? AppColors.success.withValues(alpha: 0.2)
                                : AppColors.error.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            status.toUpperCase(),
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: isSuccess ? AppColors.success : AppColors.error,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          );
        }),
      ),
    );
  }
}
