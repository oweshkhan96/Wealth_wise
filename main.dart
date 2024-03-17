import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:page_transition/page_transition.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';

class NavigationHelper {
  static void navigateToPage(BuildContext context, Widget page) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => page),
    );
  }

  static void navigateBack(BuildContext context) {
    Navigator.pop(context);
  }
}

void main() {
  runApp(MyApp());
}
class BalanceProvider with ChangeNotifier {
  double _balance = 50000.00;
  double get balance => _balance;
  void deductBalance(double amount) {
    _balance -= amount;
    notifyListeners();
  }
}
class Transaction {
  final String recipient;
  final double amount;
  final String status;
  final DateTime dateTime;
  Transaction({
    required this.recipient,
    required this.amount,
    required this.status,
  }) : dateTime = DateTime.now();
}
class TransactionHistoryProvider with ChangeNotifier {
  List<Transaction> _transactions = [];
  List<Transaction> get transactions => _transactions;
  void addTransaction(Transaction transaction) {
    _transactions.add(transaction);
    notifyListeners();
  }
}
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => BalanceProvider()),
        ChangeNotifierProvider(create: (context) => TransactionHistoryProvider()),
      ],
      child: MaterialApp(
        title: 'Wealth Wise',
        theme: ThemeData(primarySwatch: Colors.blue),
        home: SplashScreen(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
class SplashScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AnimatedSplashScreen(
      splash: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset('assets/logo.png'),
          const Text(
            'Powered by Veronica Ai',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.deepPurpleAccent),
          ),
        ],
      ),
      backgroundColor: Colors.black,
      nextScreen: NumberInputScreen(),
      splashIconSize: 412,
      splashTransition: SplashTransition.fadeTransition,
      pageTransitionType: PageTransitionType.rightToLeft,
      duration: 1000,
      animationDuration: const Duration(seconds: 1),
    );
  }
}
class NumberInputScreen extends StatefulWidget {
  @override
  _NumberInputScreenState createState() => _NumberInputScreenState();
}
class _NumberInputScreenState extends State<NumberInputScreen> {
  TextEditingController userNumberController = TextEditingController();
  final pinController = TextEditingController(); // Define the PIN controller here
  void _continueToHomeScreen() {
    String userNumber = userNumberController.text;
    if (userNumber.isNotEmpty && userNumber.length == 10) {
      NavigationHelper.navigateToPage(
        context,
        HomeScreen(userNumber: userNumber, pinController: pinController,),
      );
    } else {
      _showErrorDialog('Please enter a valid 10-digit number.');
    }
  }
  void _showErrorDialog(String errorMessage) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Error', style: TextStyle(color: Colors.white)),
          backgroundColor: const Color.fromRGBO(0, 0, 0, 1),
          content: Text(errorMessage, style: const TextStyle(color: Colors.white)),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all<Color>(Colors.blue),
                foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
              ),
              child: const Text('OK', style: TextStyle(color: Colors.white)),
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
        title: const Text(
          'Wealth Wise',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.blue,
      ),
      backgroundColor: const Color.fromRGBO(0, 0, 0, 1),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/logo.png', // Replace 'logo.png' with your image asset path
              width: 500,// Adjust width as needed
            ),
            const SizedBox(height: 20),
            Container(
              width: MediaQuery.of(context).size.width * 0.6,
              child: TextField(
                controller: userNumberController,
                style: const TextStyle(color: Colors.white),
                keyboardType: TextInputType.phone,
                maxLength: 10,
                decoration: InputDecoration(
                  labelText: 'Your Number',
                  labelStyle: const TextStyle(color: Colors.white),
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.3),
                  prefixIcon: Icon(Icons.phone, color: Colors.white),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Container(
              width: MediaQuery.of(context).size.width * 0.6,
              child: TextField(
                controller: pinController, // Reference the PIN controller here
                style: const TextStyle(color: Colors.white),
                keyboardType: TextInputType.number,
                maxLength: 4,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'PIN',
                  labelStyle: const TextStyle(color: Colors.white),
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.3),
                  prefixIcon: const Icon(
                    Icons.vpn_key, // Use any PIN icon you prefer
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                _continueToHomeScreen();
              },
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all<Color>(Colors.blue),
                foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
              ),
              child: const Text('Continue'),
            ),
          ],
        ),
      ),
    );
  }
}



class HomeScreen extends StatelessWidget {
  final String userNumber;
  final TextEditingController pinController;

  HomeScreen({required this.userNumber, required this.pinController});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Wealth Wise',
          style: TextStyle(color: Colors.white), // Set the title color to white
        ),
        backgroundColor: Colors.blue, // Set your desired color here
      ),
      backgroundColor: const Color.fromRGBO(0, 0, 0, 1),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Consumer<BalanceProvider>(
              builder: (context, balanceProvider, child) {
                return Text('Your Number: $userNumber\nBalance: ${balanceProvider.balance.toStringAsFixed(2)}Rs',
                  style: const TextStyle(color: Colors.white,fontSize: 20,),
                  textAlign: TextAlign.center,);
              },
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                NavigationHelper.navigateToPage(
                  context,
                  SendMoneyScreen(userNumber: userNumber, pinController: pinController), // Assuming the PIN is '1234' for simplicity
                );
              },
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all<Color>(Colors.blue),
                foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
              ),
              child: const Text('Send Money'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                NavigationHelper.navigateToPage(
                  context,
                  ReceiveMoneyScreen(userNumber: userNumber),
                );
              },
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all<Color>(Colors.blue),
                foregroundColor: MaterialStateProperty.all<Color>(Colors.white),

              ),
              child: const Text('Receive Money'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                NavigationHelper.navigateToPage(
                  context,
                  BalanceScreen(userNumber: userNumber),
                );
              },
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all<Color>(Colors.blue),
                foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
              ),
              child: const Text('Check Balance'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Navigate to the QR Code Scanner Screen
                NavigationHelper.navigateToPage(
                  context,
                  QRCodeScannerScreen(userNumber: userNumber, pinController: pinController,),
                );
              },
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all<Color>(Colors.blue),
                foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
              ),
              child: const Text('Scan QR Code'),
            ),
          ],
        ),
      ),
    );
  }
}

class SendMoneyScreen extends StatefulWidget {
  final String userNumber;
  final String? preFilledRecipient; // Update the parameter type to String? to allow null values
  final String? preFilledAmount; // Add a new parameter for pre-filled amount (optional)
  final TextEditingController pinController;

  SendMoneyScreen({
    required this.userNumber, this.preFilledRecipient, this.preFilledAmount, required this.pinController});
  @override
  _SendMoneyScreenState createState() => _SendMoneyScreenState();
}

class _SendMoneyScreenState extends State<SendMoneyScreen> {
  TextEditingController recipientController = TextEditingController();
  TextEditingController amountController = TextEditingController();
  final pinController = TextEditingController(); // Reference the PIN controller here

  @override
  void initState() {
    super.initState();
    if (widget.preFilledRecipient != null) {
      recipientController.text = widget.preFilledRecipient!;
    }
    if (widget.preFilledAmount != null) {
      amountController.text = widget.preFilledAmount!;
    }
  }

  void _sendMoney() {
    String userNumber = widget.userNumber;
    String recipient = recipientController.text;
    double amount = double.tryParse(amountController.text) ?? 0.0;
    String pin = pinController.text; // Get the PIN from the PIN controller

    // Check if the amount is greater than the current balance
    if (amount > Provider.of<BalanceProvider>(context, listen: false).balance) {
      _showErrorDialog('Insufficient balance. Please check your balance and try again.');
      return;
    }

    // Check if the entered PIN matches the expected PIN
    if (pin != widget.pinController.text) {
      _showErrorDialog('Incorrect PIN. Please try again.');
      return;
    }

    Provider.of<BalanceProvider>(context, listen: false).deductBalance(amount);

    Provider.of<TransactionHistoryProvider>(context, listen: false)
        .addTransaction(Transaction(recipient: recipient, amount: amount, status: 'Success'));

    _showSuccessDialog(recipient, amount, userNumber);
  }

  void _showSuccessDialog(String recipient, double amount, String userNumber) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Money Sent', style: TextStyle(color: Colors.white)),
          backgroundColor: const Color.fromRGBO(0, 0, 0, 1),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('To: $recipient', style: const TextStyle(color: Colors.white)),
              Text('Amount: Rs ${amount.toStringAsFixed(2)}', style: const TextStyle(color: Colors.white)),
              Text('Your UPI: $userNumber@Bank', style: const TextStyle(color: Colors.white)),
            ],
          ),
          actions: <Widget>[
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
                _navigateToHomeScreen();
              },
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all<Color>(Colors.blue),
                foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
              ),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _navigateToHomeScreen() {
    // Navigate to the HomeScreen and remove all previous routes
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => HomeScreen(userNumber: widget.userNumber, pinController: pinController,)),
          (route) => false,
    );
  }


  void _showErrorDialog(String errorMessage) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Error', style: TextStyle(color: Colors.white)),
          backgroundColor: const Color.fromRGBO(0, 0, 0, 1),
          content: Text(errorMessage, style: const TextStyle(color: Colors.white)),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all<Color>(Colors.blue),
                foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
              ),
              child: const Text('OK', style: TextStyle(color: Colors.white)),
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
        title: const Text(
          'Send Money',
          style: TextStyle(color: Colors.white), // Set the title color to white
        ),
        backgroundColor: Colors.blue, // Set your desired color here
      ),
      backgroundColor: const Color.fromRGBO(0, 0, 0, 1),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: MediaQuery.of(context).size.width * 0.6,
              child: TextField(
                controller: recipientController,
                style: const TextStyle(color: Colors.white),
                keyboardType: TextInputType.phone,
                maxLength: 10,
                decoration: InputDecoration(
                  labelText: 'Recipient Number',
                  labelStyle: const TextStyle(color: Colors.white),
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.3),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Container(
              width: MediaQuery.of(context).size.width * 0.6,
              child: TextField(
                controller: amountController,
                style: const TextStyle(color: Colors.white),
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Amount',
                  labelStyle: const TextStyle(color: Colors.white),
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.3),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Container(
              width: MediaQuery.of(context).size.width * 0.6,
              child: TextField(
                controller: pinController, // Reference the PIN controller here
                style: const TextStyle(color: Colors.white),
                keyboardType: TextInputType.number,
                maxLength: 4,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'PIN',
                  labelStyle: const TextStyle(color: Colors.white),
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.3),
                ),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                _sendMoney();
              },
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all<Color>(Colors.blue),
                foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
              ),
              child: const Text('Send'),
            ),
          ],
        ),
      ),
    );
  }
}

class ReceiveMoneyScreen extends StatelessWidget {
  final String userNumber;

  ReceiveMoneyScreen({required this.userNumber});

  @override
  Widget build(BuildContext context) {
    String cleanedUserNumber = userNumber.substring(3);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Receive Money',
          style: TextStyle(color: Colors.white), // Set the title color to white
        ),
        backgroundColor: Colors.blue, // Set your desired color here
      ),
      backgroundColor: const Color.fromRGBO(0, 0, 0, 1),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            QrImageView(
              data: '$cleanedUserNumber@Bank',
              version: QrVersions.auto,
              size: 200,
              backgroundColor: Colors.white,
            ),
            const SizedBox(height: 20),
            Text('Your UPI: $cleanedUserNumber@Bank', style: const TextStyle(color: Colors.white)),
            const Text('Wealth Wise', style: TextStyle(color: Colors.greenAccent)),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                NavigationHelper.navigateBack(context);
              },
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all<Color>(Colors.blue),
                foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
              ),
              child: const Text('OK'),
            ),
          ],
        ),
      ),
    );
  }
}

class BalanceScreen extends StatelessWidget {
  final String userNumber;

  BalanceScreen({required this.userNumber});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Check Balance',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.blue,
      ),
      backgroundColor: const Color.fromRGBO(0, 0, 0, 1),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Consumer<BalanceProvider>(
              builder: (context, balanceProvider, child) {
                return const Text(
                  'Your Balance:',
                  style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                );
              },
            ),
            const SizedBox(height: 10),
            Consumer<BalanceProvider>(
              builder: (context, balanceProvider, child) {
                return Text(
                  'Rs ${balanceProvider.balance}',
                  style: const TextStyle(color: Colors.greenAccent, fontSize: 40, fontWeight: FontWeight.bold),
                );
              },
            ),
            const SizedBox(height: 20),
            Consumer<TransactionHistoryProvider>(
              builder: (context, transactionHistoryProvider, child) {
                if (transactionHistoryProvider.transactions.isEmpty) {
                  return const Text(
                    'No Transaction History',
                    style: TextStyle(
                      color: Colors.red,
                      fontSize: 18,  // Adjust the font size as needed
                      fontWeight: FontWeight.bold,  // Adjust the font weight as needed
                      fontStyle: FontStyle.italic,  // Add italic style if desired
                    ),
                  );
                }

                return Expanded(
                  child: ListView.builder(
                    itemCount: transactionHistoryProvider.transactions.length * 2 - 1,
                    itemBuilder: (context, index) {
                      if (index.isOdd) {
                        return Divider(
                          color: Colors.white.withOpacity(0.5),
                          thickness: 1,
                          height: 1,
                        );
                      }

                      final transactionIndex = index ~/ 2;
                      if (transactionIndex < transactionHistoryProvider.transactions.length) {
                        Transaction transaction = transactionHistoryProvider.transactions[transactionIndex];
                        return Container(
                          color: transactionIndex % 1 == 0 ? Colors.blue.withOpacity(1) : Colors.transparent,
                          child: ListTile(
                            title: Text('Recipient: ${transaction.recipient}'),
                            subtitle: Text(
                              'Amount: Rs ${transaction.amount.toStringAsFixed(2)}',
                              style: const TextStyle(color: Colors.amberAccent),
                            ),
                            trailing: ElevatedButton(
                              onPressed: () {},
                              style: ButtonStyle(
                                backgroundColor: MaterialStateProperty.all<Color>(
                                  transaction.status == 'Success' ? Colors.greenAccent : Colors.green,
                                ),
                              ),
                              child: Text(
                                '${transaction.status}',
                                style: const TextStyle(color: Colors.black),
                              ),
                            ),
                          ),
                        );
                      } else {
                        return Container();
                      }
                    },
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}


class QRCodeScannerScreen extends StatefulWidget {
  final String userNumber;
  final TextEditingController pinController;

  QRCodeScannerScreen({required this.userNumber,required this.pinController});

  @override
  _QRCodeScannerScreenState createState() => _QRCodeScannerScreenState();
}

class _QRCodeScannerScreenState extends State<QRCodeScannerScreen> {
  final GlobalKey _qrKey = GlobalKey(debugLabel: 'QR');
  TextEditingController pinController = TextEditingController();
  late QRViewController _qrViewController;
  // ignore: unused_field
  late Barcode _scanResult;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Scan QR Code',
          style: TextStyle(color: Colors.white), // Set the title color to white
        ),
        backgroundColor: Colors.blue, // Set your desired color here
      ),
      backgroundColor: const Color.fromRGBO(0, 0, 0, 1),
      body: Column(
        children: [
          Expanded(
            child: QRView(
              key: _qrKey,
              onQRViewCreated: _onQRViewCreated,
              overlay: QrScannerOverlayShape(
                borderRadius: 10,
                borderColor: Colors.green,
                borderLength: 30,
                borderWidth: 10,
                cutOutSize: 300,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _onQRViewCreated(QRViewController controller) {
    _qrViewController = controller;

    _qrViewController.scannedDataStream.listen((scanData) {
      setState(() {
        _scanResult = scanData;
      });

      // Process the scanned QR code data
      _processScannedData(scanData.code);
    });
  }

  void _processScannedData(String? scannedData) {
    if (scannedData != null) {
      // Assuming the scanned data is in the format: 'recipientNumber@Bank'
      List<String> dataParts = scannedData.split('@');
      if (dataParts.length == 2) {
        String recipientNumber = dataParts[0];
        NavigationHelper.navigateToPage(
          context,
          SendMoneyScreen(
              userNumber: widget.userNumber,
              pinController: pinController,
              preFilledRecipient: recipientNumber),
        );
      } else {
        _showErrorDialog('Invalid QR Code');
      }
    } else {
      _showErrorDialog('Invalid QR Code');
    }
  }

  void _showErrorDialog(String errorMessage) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Error', style: TextStyle(color: Colors.white)),
          backgroundColor: const Color.fromRGBO(0, 0, 0, 1),
          content: Text(errorMessage, style: const TextStyle(color: Colors.white)),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                NavigationHelper.navigateBack(context);
              },
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all<Color>(Colors.blue),
                foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
              ),
              child: const Text('OK', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _qrViewController.dispose();
    super.dispose();
  }
}