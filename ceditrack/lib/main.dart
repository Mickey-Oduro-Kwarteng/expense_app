import 'package:flutter/material.dart';
import 'database_helper.dart';
import 'expense.dart';
void main() async {
WidgetsFlutterBinding.ensureInitialized();

final db = DatabaseHelper.instance;
await db.insertExpense(Expense(
title: 'Waakye & fish',
category: 'Food',
amount: 25.00,
date: '2026-07-13',
));

final expenses = await db.getExpenses();
for (final e in expenses) {
print('${e.id}: ${e.title} (${e.category})'
' GHS ${e.amount}');
}
}
