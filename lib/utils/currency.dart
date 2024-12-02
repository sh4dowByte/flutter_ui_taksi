String formatToIRR(double amount,
    {String symbol = 'IRR', int decimalDigits = 0}) {
  // Pisahkan bagian desimal jika diperlukan
  String formattedAmount = amount.toStringAsFixed(decimalDigits);

  // Format angka dengan tanda ribuan
  List<String> parts = formattedAmount.split('.');
  String integerPart = parts[0];
  String fractionalPart = parts.length > 1 ? parts[1] : '';

  // Tambahkan tanda titik pada angka ribuan
  String result = integerPart.replaceAllMapped(
    RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
    (Match match) => '${match.group(1)}.',
  );

  // Gabungkan desimal jika ada
  if (fractionalPart.isNotEmpty) {
    result = '$result,$fractionalPart';
  }

  return '$result $symbol';
}

double calculateDiscountedPrice({
  required double originalPrice,
  required double discountPercentage,
}) {
  if (discountPercentage < 0 || discountPercentage > 100) {
    throw ArgumentError('Discount percentage must be between 0 and 100');
  }
  return originalPrice - (originalPrice * (discountPercentage / 100));
}
