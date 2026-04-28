import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
    'Commercial International Bank (CIB)',
    'National Bank of Egypt (NBE)',
    'HSBC',
  ];

  final List<Map<String, dynamic>> _walletProviders = [
    {'name': 'Vodafone Cash', 'icon': Icons.account_balance_wallet, 'color': Colors.red},
    {'name': 'Fawry', 'icon': Icons.payments, 'color': Colors.orange},
    {'name': 'Orange Cash', 'icon': Icons.account_balance_wallet, 'color': Colors.orange},
    {'name': 'InstaPay', 'icon': Icons.bolt, 'color': Colors.blue},
    {'name': 'PayPal', 'icon': Icons.payment, 'color': Colors.blue},
  ];

  final _formKey = GlobalKey<FormState>();
  final _cardNumberController = TextEditingController();
  final _cardHolderController = TextEditingController();
  final _cvvController = TextEditingController();
  final _walletPhoneController = TextEditingController();
  String _expiryMonth = '01';
  String _expiryYear = DateTime.now().year.toString();

  final List<Map<String, String>> _savedCards = [
    {
      'type': 'Visa',
      'number': '**** **** **** 4242',
      'holder': 'Ahmed Mohamed',
      'expiry': '12/26',
      'color1': '0xFF1A237E',
      'color2': '0xFF3F51B5',
    },
    {
      'type': 'Mastercard',
      'number': '**** **** **** 5555',
      'holder': 'Ahmed Mohamed',
      'expiry': '10/25',
      'color1': '0xFF37474F',
      'color2': '0xFF546E7A',
    },
  ];

  @override
  void dispose() {
    _cardNumberController.dispose();
    _cardHolderController.dispose();
    _cvvController.dispose();
    _walletPhoneController.dispose();
    super.dispose();
  }

  // Detect card type based on first digit
  String _getCardType(String number) {
    if (number.startsWith('4')) return 'Visa';
    if (number.startsWith('5')) return 'Mastercard';
    return 'Card';
  }

  // Luhn algorithm for card validation
  bool _isValidLuhn(String number) {
    String cleanNumber = number.replaceAll(' ', '');
    if (cleanNumber.length < 13) return false;
    
    int sum = 0;
    bool alternate = false;
    for (int i = cleanNumber.length - 1; i >= 0; i--) {
      int n = int.parse(cleanNumber[i]);
      if (alternate) {
        n *= 2;
        if (n > 9) n -= 9;
      }
      sum += n;
      alternate = !alternate;
    }
    return sum % 10 == 0;
  }

  void _handlePayment() {
    final l10n = AppLocalizations.of(context);
    bool canPay = false;

    if (_selectedPaymentMethod == 'credit_card' || _selectedPaymentMethod == 'saved_card') {
      if (_selectedCardIndex != null) {
        canPay = true;
      } else if (_formKey.currentState?.validate() ?? false) {
        if (!_isValidLuhn(_cardNumberController.text)) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Invalid card number'), backgroundColor: Colors.red),
          );
          return;
        }
        canPay = true;
      }
    } else if (_selectedPaymentMethod == 'net_banking') {
      if (_selectedBank != null) {
        canPay = true;
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.pleaseSelectBank), backgroundColor: Colors.orange),
        );
      }
    } else if (_selectedPaymentMethod == 'wallets') {
      if (_selectedWallet == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.pleaseSelectWallet), backgroundColor: Colors.orange),
        );
      } else if (_walletPhoneController.text.length < 11) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.invalidPhone), backgroundColor: Colors.red),
        );
      } else {
        canPay = true;
      }
    }

    if (canPay) {
      _processPayment(l10n);
    }
  }

  void _processPayment(AppLocalizations l10n) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 30),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 20),
              Text(l10n.processing, style: const TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ),
    );

    // Simulate network delay
    Future.delayed(const Duration(seconds: 2), () {
      if (!mounted) return;
      Navigator.pop(context); // Pop loader
      
      _showSuccessDialog(l10n);
    });
  }

  void _showSuccessDialog(AppLocalizations l10n) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
        child: Padding(
          padding: const EdgeInsets.all(25),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(15),
                decoration: const BoxDecoration(
                  color: Colors.green,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check, color: Colors.white, size: 40),
              ),
              const SizedBox(height: 20),
              Text(
                l10n.paymentSuccessful,
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              const Text(
                'Your session has been booked successfully.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 25),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    // Capture navigators before any pop occurs
                    final dialogNavigator = Navigator.of(context);
                    final screenNavigator = Navigator.of(this.context);
                    
                    // 1. Pop the dialog
                    dialogNavigator.pop();
                    
                    // 2. Execute success callback
                    widget.onPaymentSuccess();
                    
                    // 3. Pop the payment screen
                    if (mounted) {
                      screenNavigator.pop();
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xff0DA5FE),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    padding: const EdgeInsets.symmetric(vertical: 15),
                  ),
                  child: const Text('OK', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : const Color(0xFFF8F9FE),
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(context, l10n),
          SliverToBoxAdapter(
            child: Padding(
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
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar(BuildContext context, AppLocalizations l10n) {
    return SliverAppBar(
      expandedHeight: 120.0,
      floating: false,
      pinned: true,
      backgroundColor: const Color(0xff0DA5FE),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
        onPressed: () => Navigator.pop(context),
      ),
      flexibleSpace: FlexibleSpaceBar(
        centerTitle: true,
        title: Text(
          l10n.payment,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xff0DA5FE), Color(0xff0077C2)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),
      ),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
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
              margin: const EdgeInsets.only(right: 15, bottom: 10),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(int.parse(card['color1']!)), Color(int.parse(card['color2']!))],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                border: isSelected
                    ? Border.all(color: const Color(0xFF0DA5FE), width: 3)
                    : null,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  Column(
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
                              fontSize: 18,
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
                          _buildCardDetail('CARD HOLDER', card['holder']!),
                          _buildCardDetail('EXPIRES', card['expiry']!),
                        ],
                      ),
                    ],
                  ),
                  if (isSelected)
                    const Positioned(
                      top: 0,
                      right: 0,
                      child: Icon(Icons.check_circle, color: Colors.white, size: 24),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCardDetail(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 10),
        ),
        Text(
          value,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildPaymentMethodItem({
    required String id,
    required String title,
    required IconData icon,
  }) {
    final isSelected = _selectedPaymentMethod == id && _selectedCardIndex == null;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedPaymentMethod = id;
          _selectedCardIndex = null;
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
            color: isSelected ? const Color(0xFF0DA5FE) : Colors.grey.withOpacity(0.2),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
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
                color: isSelected ? const Color(0xFF0DA5FE) : (isDark ? Colors.white : Colors.black87),
              ),
            ),
            const Spacer(),
            Icon(
              isSelected ? Icons.check_circle : Icons.circle_outlined,
              color: isSelected ? const Color(0xFF0DA5FE) : Colors.grey,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCreditCardForm(AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(20),
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
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
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(16),
                _CardNumberFormatter(),
              ],
              validator: (v) {
                if (v == null || v.isEmpty) return l10n.requiredField;
                if (v.replaceAll(' ', '').length < 16) return 'Incomplete number';
                return null;
              },
              suffixIcon: Icon(
                _getCardType(_cardNumberController.text) == 'Visa' 
                  ? Icons.credit_card 
                  : Icons.payment,
                color: const Color(0xFF0DA5FE),
              ),
            ),
            const SizedBox(height: 15),
            _buildTextField(
              controller: _cardHolderController,
              label: l10n.cardHolder,
              hint: l10n.fullName,
              validator: (v) => (v?.isEmpty ?? true) ? l10n.requiredField : null,
            ),
            const SizedBox(height: 15),
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: _buildDropdownField(
                    label: l10n.expiryMonth,
                    value: _expiryMonth,
                    items: List.generate(12, (i) => (i + 1).toString().padLeft(2, '0')),
                    onChanged: (v) => setState(() => _expiryMonth = v!),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  flex: 2,
                  child: _buildDropdownField(
                    label: l10n.expiryYear,
                    value: _expiryYear,
                    items: List.generate(10, (i) => (DateTime.now().year + i).toString()),
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
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(3),
                    ],
                    validator: (v) => (v?.length ?? 0) < 3 ? 'Invalid' : null,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 15),
            SwitchListTile(
              value: _saveCard,
              onChanged: (v) => setState(() => _saveCard = v),
              title: Text(l10n.saveCardFuture, style: const TextStyle(fontSize: 14)),
              activeColor: const Color(0xff0DA5FE),
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
    List<TextInputFormatter>? inputFormatters,
    String? Function(String?)? validator,
    Widget? suffixIcon,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.bold)),
        const SizedBox(height: 5),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          obscureText: obscureText,
          inputFormatters: inputFormatters,
          validator: validator,
          onChanged: (v) => setState(() {}),
          decoration: InputDecoration(
            hintText: hint,
            suffixIcon: suffixIcon,
            filled: true,
            fillColor: isDark ? const Color(0xFF262626) : Colors.grey.withOpacity(0.05),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
            contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.bold)),
        const SizedBox(height: 5),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF262626) : Colors.grey.withOpacity(0.05),
            borderRadius: BorderRadius.circular(10),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              isExpanded: true,
              value: value,
              items: items.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBankSelection(AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(15),
      margin: const EdgeInsets.only(bottom: 15),
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(15),
      ),
      child: DropdownButtonFormField<String>(
        value: _selectedBank,
        decoration: InputDecoration(
          labelText: l10n.selectBank,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        ),
        items: _banks.map((b) => DropdownMenuItem(value: b, child: Text(b, style: const TextStyle(fontSize: 14)))).toList(),
        onChanged: (v) => setState(() => _selectedBank = v),
      ),
    );
  }

  Widget _buildWalletSelection(AppLocalizations l10n) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      children: [
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
                  color: isSelected ? const Color(0xff0DA5FE).withOpacity(0.1) : Colors.grey.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: isSelected ? const Color(0xff0DA5FE) : Colors.transparent, width: 2),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(wallet['icon'], color: isSelected ? const Color(0xff0DA5FE) : wallet['color'], size: 20),
                    const SizedBox(width: 8),
                    Text(wallet['name'], style: TextStyle(fontSize: 12, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
                  ],
                ),
              ),
            );
          },
        ),
        if (_selectedWallet != null) ...[
          const SizedBox(height: 20),
          _buildTextField(
            controller: _walletPhoneController,
            label: l10n.walletPhoneNumber,
            hint: '01x xxxx xxxx',
            keyboardType: TextInputType.phone,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(11),
            ],
            suffixIcon: const Icon(Icons.phone_android, color: Color(0xff0DA5FE)),
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xff0DA5FE).withOpacity(0.05),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xff0DA5FE).withOpacity(0.2)),
            ),
            child: Row(
              children: [
                const Icon(Icons.info_outline, color: Color(0xff0DA5FE), size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    l10n.walletInstruction,
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark ? Colors.white70 : Colors.black54,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildPayButton(AppLocalizations l10n) {
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: ElevatedButton(
        onPressed: _handlePayment,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xff0DA5FE),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          elevation: 5,
          shadowColor: const Color(0xff0DA5FE).withOpacity(0.4),
        ),
        child: Text(
          '${l10n.pay} \$${widget.amount.toStringAsFixed(2)}',
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ),
    );
  }
}

class _CardNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    var text = newValue.text;
    if (newValue.selection.baseOffset == 0) return newValue;
    
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
