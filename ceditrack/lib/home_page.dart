import 'package:flutter/material.dart';
import 'database_helper.dart';
import 'expense.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _titleCtrl = TextEditingController();
  final _catCtrl = TextEditingController();
  final _amountCtrl = TextEditingController();

  List<Expense> _expenses = [];
  bool _isLoading = true;

  double get _total =>
      _expenses.fold(0.0, (sum, expense) => sum + expense.amount);

  @override
  void initState() {
    super.initState();
    _refreshExpenses();
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _catCtrl.dispose();
    _amountCtrl.dispose();
    super.dispose();
  }

  Future<void> _refreshExpenses() async {
    final data = await DatabaseHelper.instance.getExpenses();

    if (!mounted) return;

    setState(() {
      _expenses = data;
      _isLoading = false;
    });
  }

  void _showForm(Expense? expense) {
    _titleCtrl.text = expense?.title ?? '';
    _catCtrl.text = expense?.category ?? '';
    _amountCtrl.text = expense?.amount.toString() ?? '';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: 16,
          right: 16,
          top: 16,
        ),
        child: _buildFormFields(expense),
      ),
    );
  }

  Future<void> _saveExpense(Expense? expense) async {
    final title = _titleCtrl.text.trim();
    final category = _catCtrl.text.trim();
    final amount = double.tryParse(_amountCtrl.text.trim());

    if (title.isEmpty || category.isEmpty || amount == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill in all fields correctly'),
        ),
      );
      return;
    }

    if (expense == null) {
      final newExpense = Expense(
        title: title,
        category: category,
        amount: amount,
        date: DateTime.now().toString(),
      );

      await DatabaseHelper.instance.insertExpense(newExpense);
    } else {
      final updatedExpense = Expense(
        id: expense.id,
        title: title,
        category: category,
        amount: amount,
        date: expense.date,
      );

      await DatabaseHelper.instance.updateExpense(updatedExpense);
    }

    if (!mounted) return;

    Navigator.pop(context);

    _titleCtrl.clear();
    _catCtrl.clear();
    _amountCtrl.clear();

    await _refreshExpenses();
  }

  Future<void> _deleteExpense(int id) async {
    await DatabaseHelper.instance.deleteExpense(id);

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Expense deleted'),
      ),
    );

    await _refreshExpenses();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('CediTrack'),
        backgroundColor: const Color(0xFF002060),
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          _buildTotalCard(),
          Expanded(
            child: _buildBody(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFFD4A017),
        onPressed: () => _showForm(null),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildTotalCard() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.all(12),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF002060),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'TOTAL SPENT',
            style: TextStyle(
              color: Color(0xFFD4A017),
              fontSize: 12,
              letterSpacing: 2,
            ),
          ),
          Text(
            'GHS ${_total.toStringAsFixed(2)}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_expenses.isEmpty) {
      return const Center(
        child: Text('No expenses yet. Tap + to add.'),
      );
    }

    return ListView.builder(
      itemCount: _expenses.length,
      itemBuilder: (context, index) {
        final expense = _expenses[index];

        return _buildExpenseCard(expense);
      },
    );
  }

  Widget _buildExpenseCard(Expense expense) {
    return Card(
      margin: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 6,
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: const Color(0xFF002060),
          child: Text(
            expense.category.isNotEmpty
                ? expense.category[0].toUpperCase()
                : '?',
            style: const TextStyle(
              color: Color(0xFFD4A017),
            ),
          ),
        ),
        title: Text(expense.title),
        subtitle: Text(
          '${expense.category} • ${expense.date}',
        ),
        trailing: Text(
          'GHS ${expense.amount.toStringAsFixed(2)}',
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
        onTap: () => _showForm(expense),
        onLongPress: () {
          if (expense.id != null) {
            _deleteExpense(expense.id!);
          }
        },
      ),
    );
  }

  Widget _buildFormFields(Expense? expense) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        TextField(
          controller: _titleCtrl,
          decoration: const InputDecoration(
            labelText: 'Title',
          ),
        ),
        TextField(
          controller: _catCtrl,
          decoration: const InputDecoration(
            labelText: 'Category',
            hintText: 'Food, Transport, Data...',
          ),
        ),
        TextField(
          controller: _amountCtrl,
          keyboardType: const TextInputType.numberWithOptions(
            decimal: true,
          ),
          decoration: const InputDecoration(
            labelText: 'Amount (GHS)',
          ),
        ),
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: () => _saveExpense(expense),
          child: Text(
            expense == null ? 'Add Expense' : 'Update',
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }
}