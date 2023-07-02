import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:ledective/apps/phone_app/call_screen.dart';
import 'package:ledective/apps/tools/round_icon_button.dart';

import '../../data_base/datas.dart';

class PhoneContacts extends StatefulWidget {
  const PhoneContacts({Key? key}) : super(key: key);

  @override
  State<PhoneContacts> createState() => _PhoneContactsState();
}

class _PhoneContactsState extends State<PhoneContacts> {
  PageController pageController = PageController(initialPage: 0);
  int _currentPageIndex = 0;
  String _phoneNumber = '';

  @override
  void initState() {
    super.initState();
    _currentPageIndex = 0;
  }

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }

  void _updatePhoneNumber(String digit) {
    setState(() {
      final bool startsWithZero = _phoneNumber.startsWith('0');

      if(_phoneNumber.length<14){
      _phoneNumber += digit;
      }

      final List<int> lengths = startsWithZero ? [1,4, 8,11] : [3, 7, 10];

      if (lengths.contains(_phoneNumber.length)) {
        _phoneNumber += ' ';
      }

    });
  }

  void _deleteDigit() {
    setState(() {
      if (_phoneNumber.isNotEmpty) {
        _phoneNumber = _phoneNumber.substring(0, _phoneNumber.length - 1);

        if(_phoneNumber.endsWith(' ')){
          _phoneNumber = _phoneNumber.substring(0, _phoneNumber.length - 1);
        }
      }
    });
  }

  void _clearPhoneNumber() {
    setState(() {
      _phoneNumber = '';
    });
  }

  DataDepo db = DataDepo();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          leading: BackButton(
            color: Colors.grey,
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          backgroundColor: Colors.green.shade200,
          shadowColor: Colors.green,
          elevation: 5.0,
          title: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              GestureDetector(
                onTap: () {
                  pageController.animateToPage(
                    0,
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeInOut,
                  );
                },
                child: Text(
                  'KeyPad',
                  style: TextStyle(
                    color: _currentPageIndex == 0
                        ? Colors.green.shade800
                        : Colors.grey,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 20),
              GestureDetector(
                onTap: () {
                  pageController.animateToPage(
                    1,
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                  );
                },
                child: Text(
                  'Recents',
                  style: TextStyle(
                    color: _currentPageIndex == 1
                        ? Colors.green.shade800
                        : Colors.grey,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 70),
            ],
          ),
        ),
        body: PageView(
          onPageChanged: (int pageIndex) {
            setState(() {
              _currentPageIndex = pageIndex;
            });
          },
          controller: pageController,
          physics: const ClampingScrollPhysics(),
          children: [
            Container(
              color: Colors.green.shade200,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    Expanded(
                      flex: 1,
                      child: SizedBox(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              _phoneNumber,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 50,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 3,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              RoundIconButton(
                                buttonText: '1',
                                onPressed: () {
                                  _updatePhoneNumber('1');
                                },
                              ),
                              RoundIconButton(
                                buttonText: '2',
                                onPressed: () {
                                  _updatePhoneNumber('2');
                                },
                              ),
                              RoundIconButton(
                                buttonText: '3',
                                onPressed: () {
                                  _updatePhoneNumber('3');
                                },
                              ),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              RoundIconButton(
                                buttonText: '4',
                                onPressed: () {
                                  _updatePhoneNumber('4');
                                },
                              ),
                              RoundIconButton(
                                buttonText: '5',
                                onPressed: () {
                                  _updatePhoneNumber('5');
                                },
                              ),
                              RoundIconButton(
                                buttonText: '6',
                                onPressed: () {
                                  _updatePhoneNumber('6');
                                },
                              ),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              RoundIconButton(
                                buttonText: '7',
                                onPressed: () {
                                  _updatePhoneNumber('7');
                                },
                              ),
                              RoundIconButton(
                                buttonText: '8',
                                onPressed: () {
                                  _updatePhoneNumber('8');
                                },
                              ),
                              RoundIconButton(
                                buttonText: '9',
                                onPressed: () {
                                  _updatePhoneNumber('9');
                                },
                              ),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              RoundIconButton(
                                myIcon: CupertinoIcons.phone,
                                onPressed: (){
                                  if(_phoneNumber.isNotEmpty){
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => CallScreen(number: _phoneNumber),
                                      ),
                                    );
                                  }
                                },
                              ),
                              RoundIconButton(
                                buttonText: '0',
                                onPressed: () {
                                  _updatePhoneNumber('0');
                                },
                              ),
                              RoundIconButton(
                                myIcon: CupertinoIcons.delete_left,
                                onPressed: _deleteDigit,
                                onLongPressed: _clearPhoneNumber,
                              ),
                            ],
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ),
            Container(
              color: Colors.green.shade200,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: ListView(
                  children: [
                    ...(db.recents)
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
