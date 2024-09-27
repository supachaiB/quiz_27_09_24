import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart'; // นำเข้า fl_chart
import 'firebase_options.dart';
import 'package:quiz/screen/SigninScreen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Income & Expense Tracker',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      // Change home to SigninScreen
      home: const SigninScreen(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  final String title;
  const MyHomePage({super.key, required this.title});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final List<Map<String, dynamic>> _entries = [];
  double _totalIncome = 0;
  double _totalExpense = 0;
  List<double> _monthlyIncome = List.filled(2, 0); // รายได้ 2 เดือน
  List<double> _monthlyExpense = List.filled(2, 0); // รายจ่าย 2 เดือน

  @override
  void initState() {
    super.initState();
    fetchEntries(); // เรียกฟังก์ชันดึงข้อมูล
  }

  // ฟังก์ชันดึงข้อมูลจาก Firestore
  Future<void> fetchEntries() async {
    try {
      QuerySnapshot snapshot =
          await _firestore.collection('transactions').get();

      setState(() {
        _entries.clear(); // เคลียร์รายการก่อน
        _totalIncome = 0; // รีเซ็ตค่า
        _totalExpense = 0; // รีเซ็ตค่า
        _monthlyIncome = List.filled(2, 0); // รีเซ็ตค่า
        _monthlyExpense = List.filled(2, 0); // รีเซ็ตค่า

        for (var doc in snapshot.docs) {
          var data =
              doc.data() as Map<String, dynamic>?; // ตรวจสอบค่าที่เป็น null
          if (data != null) {
            _entries.add(data);

            // คำนวณยอดรวม
            if (data['type'] == 'Income') {
              _totalIncome += data['amount'];
              // คำนวณรายได้ประจำเดือน
              _updateMonthlyData(data, true);
            } else {
              _totalExpense += data['amount'];
              // คำนวณรายจ่ายประจำเดือน
              _updateMonthlyData(data, false);
            }
          }
        }
      });
    } catch (e) {
      print('Error fetching entries: $e'); // แสดงข้อผิดพลาดในคอนโซล
    }
  }

  void _updateMonthlyData(Map<String, dynamic> data, bool isIncome) {
    DateTime date = (data['date'] as Timestamp).toDate();
    int monthIndex = DateTime.now().month - date.month;

    // ตรวจสอบว่าเดือนอยู่ในช่วง 0-1 เพื่ออัปเดต
    if (monthIndex >= 0 && monthIndex < 2) {
      if (isIncome) {
        _monthlyIncome[monthIndex] += data['amount'];
      } else {
        _monthlyExpense[monthIndex] += data['amount'];
      }
    }
  }

  void _addEntry(String note, double amount, DateTime date, String type) async {
    final entry = {
      'amount': amount,
      'date': Timestamp.fromDate(date), // ใช้ Timestamp
      'type': type,
      'note': note,
    };

    try {
      // บันทึกข้อมูลลง Firestore
      await _firestore.collection('transactions').add(entry);
      await fetchEntries(); // เรียกฟังก์ชัน fetchEntries เพื่ออัปเดต UI
    } catch (e) {
      print('Error adding entry: $e'); // แสดงข้อผิดพลาดในคอนโซล
    }
  }

  // ฟังก์ชันสำหรับเปิด Dialog เพื่อกรอกข้อมูล
  void _showAddEntryDialog() {
    final TextEditingController _amountController = TextEditingController();
    final TextEditingController _noteController = TextEditingController();
    final TextEditingController _dateController = TextEditingController();
    String _entryType = 'Income'; // กำหนดค่าเริ่มต้น

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Add Entry'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _amountController,
                decoration: const InputDecoration(labelText: 'Amount'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: _noteController,
                decoration: const InputDecoration(labelText: 'Note'),
              ),
              TextField(
                controller: _dateController,
                decoration:
                    const InputDecoration(labelText: 'Date (YYYY-MM-DD)'),
              ),
              Row(
                children: [
                  Expanded(
                    child: ListTile(
                      title: const Text('Income'),
                      leading: Radio<String>(
                        value: 'Income',
                        groupValue: _entryType,
                        onChanged: (value) {
                          _entryType = value!;
                          (context as Element).markNeedsBuild();
                        },
                      ),
                    ),
                  ),
                  Expanded(
                    child: ListTile(
                      title: const Text('Expense'),
                      leading: Radio<String>(
                        value: 'Expense',
                        groupValue: _entryType,
                        onChanged: (value) {
                          _entryType = value!;
                          (context as Element).markNeedsBuild();
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                final double amount =
                    double.tryParse(_amountController.text) ?? 0;
                final String note = _noteController.text;
                final String dateString = _dateController.text;

                if (amount <= 0) return;

                DateTime? selectedDate = DateTime.tryParse(dateString);

                if (selectedDate != null) {
                  _addEntry(note, amount, selectedDate, _entryType);
                  Navigator.of(context).pop(); // ปิด Dialog
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text(
                            'Invalid date format. Please use YYYY-MM-DD.')),
                  );
                }
              },
              child: const Text('Save'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // ปิด Dialog
              },
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text('Total Income: \$$_totalIncome'),
            Text('Total Expense: \$$_totalExpense'),
            const SizedBox(height: 20),
            // แสดงกราฟรายรับรายจ่าย
            SizedBox(
              height: 200,
              child: BarChart(
                BarChartData(
                  titlesData: FlTitlesData(
                    leftTitles:
                        AxisTitles(sideTitles: SideTitles(showTitles: true)),
                    bottomTitles:
                        AxisTitles(sideTitles: SideTitles(showTitles: true)),
                  ),
                  borderData: FlBorderData(show: true),
                  barGroups: [
                    BarChartGroupData(x: 0, barRods: [
                      BarChartRodData(
                          toY: _monthlyIncome[0], color: Colors.green)
                    ]),
                    BarChartGroupData(x: 1, barRods: [
                      BarChartRodData(
                          toY: _monthlyIncome[1], color: Colors.green)
                    ]),
                    BarChartGroupData(x: 0, barRods: [
                      BarChartRodData(
                          toY: _monthlyExpense[0], color: Colors.red)
                    ]),
                    BarChartGroupData(x: 1, barRods: [
                      BarChartRodData(
                          toY: _monthlyExpense[1], color: Colors.red)
                    ]),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: _entries.length,
                itemBuilder: (context, index) {
                  final entry = _entries[index];
                  return ListTile(
                    title: Text(
                      '${entry['type']}: \$${entry['amount'].toStringAsFixed(2)}',
                    ),
                    subtitle: Text(
                      '${entry['note']} (${(entry['date'] as Timestamp).toDate().toString().substring(0, 10)})', // แปลง Timestamp เป็น DateTime
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddEntryDialog, // แสดง Dialog เมื่อกด
        tooltip: 'Add Entry',
        child: const Icon(Icons.add),
      ),
    );
  }
}
