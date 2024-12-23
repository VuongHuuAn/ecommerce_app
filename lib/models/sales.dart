

class Sales {
  final String category;
 final double earning;
 final int quantity;
  Sales({
   required this.category,
   required this.earning,
   required this.quantity,
 });
  factory Sales.fromMap(Map<String, dynamic> map) {
   return Sales(
     category: map['category'] ?? '',
     earning: (map['earning'] ?? 0).toDouble(),
     quantity: map['quantity']?.toInt() ?? 0,
   );
 }
  Map<String, dynamic> toMap() {
   return {
     'category': category,
     'earning': earning,
     'quantity': quantity,
   };
 }
}