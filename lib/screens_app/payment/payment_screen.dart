import 'package:flutter/material.dart';
import 'package:ehnama3ak/core/localization/app_localizations.dart';

class PaymentScreen extends StatefulWidget {
  final double amount;
  final VoidCallback onPaymentSuccess;

  const PaymentScreen({
    super.key,
    required this.amount,
    required this.onPaymentSuccess,
  });

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  int? _selectedCardIndex;
  String _selectedPaymentMethod = 'credit_card';
  bool _saveCard = false;
  String? _selectedBank;
  String? _selectedWallet;

  final List<String> _banks = [
    'State Bank of India',
    'HDFC Bank',
    'ICICI Bank',
    'Axis Bank',
    'CIB',
    'NBE',
  ];
  final List<Map<String, dynamic>> _walletProviders = [
    {'name': 'Vodafone Cash', 'icon': Icons.account_balance_wallet},
    {'name': 'Fawry', 'icon': Icons.payments},
    {'name': 'Orange Cash', 'icon': Icons.account_balance_wallet},
    {'name': 'InstaPay', 'icon': Icons.bolt},
  ];

  final _formKey = GlobalKey<FormState>();
  final _cardNumberController = TextEditingController();
  final _cardHolderController = TextEditingController();
  final _cvvController = TextEditingController();
  String _expiryMonth = '01';
  String _expiryYear = '2025';

  final List<Map<String, String>> _savedCards = [
    {
      'type': 'Visa',
      'number': '**** **** **** 4242',
      'holder': 'Card Holder Name',
      'expiry': '12/26',
    },
    {
      'type': 'Mastercard',
      'number': '**** **** **** 5555',
      'holder': 'Card Holder Name',
      'expiry': '10/25',
    },
  ];

  @override
  void dispose() {
    _cardNumberController.dispose();
    _cardHolderController.dispose();
    _cvvController.dispose();
    super.dispose();
  }

  void _handlePayment() {
    bool canPay = false;
    if (_selectedPaymentMethod == 'credit_card') {
      if (_selectedCardIndex != null ||
          (_formKey.currentState?.validate() ?? false)) {
        canPay = true;
      }
    } else if (_selectedPaymentMethod == 'net_banking') {
      if (_selectedBank != null) {
        canPay = true;
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(AppLocalizations.of(context).pleaseSelectBank)));
      }
    } else if (_selectedPaymentMethod == 'wallets') {
      if (_selectedWallet != null) {
        canPay = true;
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context).pleaseSelectWallet)),
        );
      }
    }

    if (canPay) {
      _processPayment(AppLocalizations.of(context));
    }
  }

  void _processPayment(AppLocalizations l10n) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    // Simulate network delay
    Future.delayed(const Duration(seconds: 2), () {
      if (!mounted) return;
      Navigator.pop(context); // Pop loader
      widget.onPaymentSuccess();
      if (!mounted) return;
      Navigator.pop(context); // Pop payment screen

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.paymentSuccessful),
          backgroundColor: Colors.green,
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : const Color(0xFFF8F9FE),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildHeader(context, l10n),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionTitle(l10n.savedCards),
                  const SizedBox(height: 15),
                  _buildSavedCardsList(),
                  const SizedBox(height: 30),
                  _buildSectionTitle(l10n.otherPaymentMethods),
                  const SizedBox(height: 15),
                  _buildPaymentMethodItem(
                    id: 'credit_card',
                    title: l10n.creditDebitCard,
                    icon: Icons.credit_card_rounded,
                  ),
                  if (_selectedPaymentMethod == 'credit_card' && _selectedCardIndex == null)
                    _buildCreditCardForm(l10n),
                  _buildPaymentMethodItem(
                    id: 'net_banking',
                    title: l10n.netBanking,
                    icon: Icons.account_balance_rounded,
                  ),
                  if (_selectedPaymentMethod == 'net_banking') _buildBankSelection(l10n),
                  _buildPaymentMethodItem(
                    id: 'wallets',
                    title: l10n.mobileWallets,
                    icon: Icons.account_balance_wallet_rounded,
                  ),
                  if (_selectedPaymentMethod == 'wallets') _buildWalletSelection(l10n),
                  const SizedBox(height: 40),
                  _buildPayButton(l10n),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, AppLocalizations l10n) {
    return Container(
      width: double.infinity,
      height: 180,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xff0DA5FE), Color(0xff0DA5FE)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(40),
          bottomRight: Radius.circular(40),
        ),
      ),
      child: SafeArea(
        child: Stack(
          children: [
            Positioned(
              left: 10,
              top: 10,
              child: IconButton(
                icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            Center(
              child: Text(
                l10n.payment,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        letterSpacing: 0.5,
      ),
    );
  }

  Widget _buildSavedCardsList() {
    return SizedBox(
      height: 190,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _savedCards.length,
        itemBuilder: (context, index) {
          final card = _savedCards[index];
          final isSelected = _selectedCardIndex == index;
          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedCardIndex = index;
                _selectedPaymentMethod = 'saved_card';
              });
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: 300,
              margin: const EdgeInsets.only(right: 15),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: index % 2 == 0
                      ? [const Color(0xFF1A237E), const Color(0xFF3F51B5)]
                      : [const Color(0xFF37474F), const Color(0xFF546E7A)],
                ),
                borderRadius: BorderRadius.circular(20),
                border: isSelected
                    ? Border.all(color: const Color(0xFF0DA5FE), width: 3)
                    : null,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.2),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        card['type']!,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                      const Icon(Icons.contactless, color: Colors.white70),
                    ],
                  ),
                  Text(
                    card['number']!,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      letterSpacing: 2,
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'CARD HOLDER',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 10,
                            ),
                          ),
                          Text(
                            card['holder']!,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'EXPIRES',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 10,
                            ),
                          ),
                          Text(
                            card['expiry']!,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildPaymentMethodItem({
    required String id,
    required String title,
    required IconData icon,
  }) {
    final isSelected =
        _selectedPaymentMethod == id && _selectedCardIndex == null;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedPaymentMethod = id;
          _selectedCardIndex = null;
          if (id == 'credit_card') {
            // Logic for form expansion if needed
          } else {
            // Other logic
          }
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: isSelected
                ? const Color(0xFF0DA5FE)
                : Colors.grey.withValues(alpha: 0.2),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected ? const Color(0xFF0DA5FE) : Colors.grey,
            ),
            const SizedBox(width: 15),
            Text(
              title,
              style: TextStyle(
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected
                    ? const Color(0xFF0DA5FE)
                    : (isDark ? Colors.white : Colors.black87),
              ),
            ),
            const Spacer(),
            if (isSelected)
              const Icon(Icons.check_circle, color: Color(0xFF0DA5FE))
            else
              const Icon(Icons.circle_outlined, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  Widget _buildCreditCardForm(AppLocalizations l10n) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
      padding: const EdgeInsets.all(20),
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark
            ? const Color(0xFF262626)
            : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            _buildTextField(
              controller: _cardNumberController,
              label: l10n.cardNumber,
              hint: '0000 0000 0000 0000',
              keyboardType: TextInputType.number,
              validator: (v) =>
                  (v?.length ?? 0) < 16 ? 'Invalid' : null,
            ),
            const SizedBox(height: 15),
            _buildTextField(
              controller: _cardHolderController,
              label: l10n.cardHolder,
              hint: l10n.fullName,
              validator: (v) =>
                  (v?.isEmpty ?? true) ? l10n.requiredField : null,
            ),
            const SizedBox(height: 15),
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: _buildDropdownField(
                    label: l10n.expiryMonth,
                    value: _expiryMonth,
                    items: List.generate(
                      12,
                      (i) => (i + 1).toString().padLeft(2, '0'),
                    ),
                    onChanged: (v) => setState(() => _expiryMonth = v!),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  flex: 2,
                  child: _buildDropdownField(
                    label: l10n.expiryYear,
                    value: _expiryYear,
                    items: List.generate(10, (i) => (2025 + i).toString()),
                    onChanged: (v) => setState(() => _expiryYear = v!),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  flex: 1,
                  child: _buildTextField(
                    controller: _cvvController,
                    label: l10n.cvv,
                    hint: '123',
                    keyboardType: TextInputType.number,
                    obscureText: true,
                    validator: (v) => (v?.length ?? 0) < 3 ? 'Invalid' : null,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 15),
            CheckboxListTile(
              value: _saveCard,
              onChanged: (v) => setState(() => _saveCard = v!),
              title: Text(
                l10n.saveCardFuture,
                style: const TextStyle(fontSize: 14),
              ),
              controlAffinity: ListTileControlAffinity.leading,
              contentPadding: EdgeInsets.zero,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    TextInputType keyboardType = TextInputType.text,
    bool obscureText = false,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 5),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          obscureText: obscureText,
          validator: validator,
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            fillColor: Colors.grey.withValues(alpha: 0.05),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 15,
              vertical: 12,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdownField({
    required String label,
    required String value,
    required List<String> items,
    required void Function(String?) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 5),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            color: Colors.grey.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(10),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              isExpanded: true,
              value: value,
              items: items
                  .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                  .toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPayButton(AppLocalizations l10n) {
    return Container(
      width: double.infinity,
      height: 60,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6A1B9A).withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: _handlePayment,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xff0DA5FE),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          elevation: 0,
        ),
        child: Text(
          '${l10n.pay} \$${widget.amount.toStringAsFixed(2)}',
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildBankSelection(AppLocalizations l10n) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(15),
      margin: const EdgeInsets.only(bottom: 15),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF262626) : Colors.white,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.selectBank,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
          const SizedBox(height: 10),
          DropdownButtonFormField<String>(
            value: _selectedBank,
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.grey.withValues(alpha: 0.05),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide.none,
              ),
            ),
            items: _banks
                .map((b) => DropdownMenuItem(value: b, child: Text(b)))
                .toList(),
            onChanged: (v) => setState(() => _selectedBank = v),
          ),
        ],
      ),
    );
  }

  Widget _buildWalletSelection(AppLocalizations l10n) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(15),
      margin: const EdgeInsets.only(bottom: 15),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF262626) : Colors.white,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.selectWallet,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
          const SizedBox(height: 10),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 2.5,
            ),
            itemCount: _walletProviders.length,
            itemBuilder: (context, index) {
              final wallet = _walletProviders[index];
              final isSelected = _selectedWallet == wallet['name'];
              return GestureDetector(
                onTap: () => setState(() => _selectedWallet = wallet['name']),
                child: Container(
                  decoration: BoxDecoration(
                    color: isSelected
                        ? const Color(0xff0DA5FE).withValues(alpha: 0.1)
                        : Colors.grey.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: isSelected
                          ? const Color(0xff0DA5FE)
                          : Colors.transparent,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        wallet['icon'],
                        size: 18,
                        color: isSelected
                            ? const Color(0xff0DA5FE)
                            : Colors.grey,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        wallet['name'],
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: isSelected
                              ? FontWeight.bold
                              : FontWeight.normal,
                          color: isSelected
                              ? const Color(0xff0DA5FE)
                              : (isDark ? Colors.white : Colors.black87),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
