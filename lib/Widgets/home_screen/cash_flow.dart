import 'package:flutter/material.dart';

class Cashflow extends StatefulWidget {
  final double income;
  final double expense;
  final VoidCallback onUpdate;

  const Cashflow({
    required this.onUpdate,
    required this.income,
    required this.expense,
    Key? key,
  }) : super(key: key);

  @override
  State<Cashflow> createState() => _CashflowState();
}

class _CashflowState extends State<Cashflow> {
  bool isHidden = true;

  @override
  Widget build(BuildContext context) {
    final double netBalance = widget.income - widget.expense;

    // Handle % safely
    double expenseRatio = 0;
    double remainingRatio = 0;

    if (widget.income > 0) {
      expenseRatio = (widget.expense / widget.income);
      remainingRatio = ((widget.income - widget.expense) / widget.income);
    }

    String formatAmount(double value) =>
        isHidden ? '***' : '\$${value.toStringAsFixed(0)}';

    return Scaffold(
      body: Column(
        children: [
          // Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.only(top: 40, left: 16, right: 16, bottom: 24),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color.fromARGB(255, 9, 13, 12), Color.fromARGB(255, 29, 31, 31)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
            ),
            child: Column(
              children: [
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Cashflow',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        isHidden ? Icons.visibility_off : Icons.visibility,
                        color: Colors.white,
                      ),
                      onPressed: () {
                        setState(() {
                          isHidden = !isHidden;
                        });
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  isHidden ? '***' : '\$${netBalance.toStringAsFixed(0)}',
                  style: TextStyle(
                    color: netBalance < 0 ? Colors.red : Colors.green,
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Text(
                  'NET BALANCE',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Income & Expense cards
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildAmountCard(formatAmount(widget.income), 'INCOME', Colors.green),
              _buildAmountCard(isHidden ? '***' : '-\$${widget.expense.toStringAsFixed(0)}', 'EXPENSE', Colors.red),
            ],
          ),

          const SizedBox(height: 24),

          // Progress bar section (keeps working even if hidden)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Remaining", style: TextStyle(fontSize: 16)),
                    Text("Spent", style: TextStyle(fontSize: 16)),
                  ],
                ),
                const SizedBox(height: 8),

                Stack(
                  children: [
                    Container(
                      height: 16,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: Colors.grey.shade300,
                      ),
                    ),
                    Row(
                      children: [
                        if (remainingRatio > 0)
                          Expanded(
                            flex: (remainingRatio * 100).toInt(),
                            child: Container(
                              height: 16,
                              decoration: BoxDecoration(
                                color: Colors.green,
                                borderRadius: BorderRadius.horizontal(
                                  left: const Radius.circular(8),
                                  right: expenseRatio == 0 ? const Radius.circular(8) : Radius.zero,
                                ),
                              ),
                            ),
                          ),
                        if (expenseRatio > 0)
                          Expanded(
                            flex: (expenseRatio * 100).toInt(),
                            child: Container(
                              height: 16,
                              decoration: BoxDecoration(
                                color: Colors.red,
                                borderRadius: BorderRadius.horizontal(
                                  right: const Radius.circular(8),
                                  left: remainingRatio == 0 ? const Radius.circular(8) : Radius.zero,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 8),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "${(remainingRatio * 100).toStringAsFixed(2)}% left",
                      style: const TextStyle(color: Colors.green),
                    ),
                    Text(
                      "${(expenseRatio * 100).toStringAsFixed(2)}% spent",
                      style: const TextStyle(color: Colors.red),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAmountCard(String amount, String label, Color color) {
    return Container(
      width: 160,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black26,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [const BoxShadow(color: Colors.black12, blurRadius: 6)],
      ),
      child: Column(
        children: [
          Text(
            amount,
            style: TextStyle(
              fontSize: 20,
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
