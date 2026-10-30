import 'package:flutter_test/flutter_test.dart';
import 'package:ledective/apps/calculator/calculator.dart';

/// Presses [keys] in order: digits, `,`, `+ − × ÷ = % ± C A <` (A is AC,
/// < a swipe).
String press(String keys, [Calculator? calculator]) {
  final c = calculator ?? Calculator();
  for (final key in keys.split('')) {
    switch (key) {
      case ',':
        c.decimalPoint();
      case '+':
        c.operation(Operation.add);
      case '−':
        c.operation(Operation.subtract);
      case '×':
        c.operation(Operation.multiply);
      case '÷':
        c.operation(Operation.divide);
      case '=':
        c.equals();
      case '%':
        c.percent();
      case '±':
        c.toggleSign();
      case 'C':
        c.clearEntry();
      case 'A':
        c.clearAll();
      case '<':
        c.backspace();
      case ' ':
        break;
      default:
        c.digit(int.parse(key));
    }
  }
  return c.display;
}

void main() {
  test('adds, subtracts, multiplies and divides', () {
    expect(press('12+30='), '42');
    expect(press('7−10='), '-3');
    expect(press('6×7='), '42');
    expect(press('1÷4='), '0,25');
  });

  test('× and ÷ go before + and −', () {
    expect(press('2+3×4='), '14');
    expect(press('2×3+4='), '10');
    expect(press('10−6÷2='), '7');
    expect(press('2+3×4+1='), '15');
    // The running total shows as soon as it can be worked out.
    expect(press('2+3×4+'), '14');
  });

  test('pressing = again repeats the last step', () {
    expect(press('2+3=='), '8');
    expect(press('5+='), '10');
  });

  test('the last operation pressed counts', () {
    expect(press('8+−3='), '5');
  });

  test('percent', () {
    expect(press('50%'), '0,5');
    expect(press('50+10%='), '55');
    expect(press('200×10%='), '20');
  });

  test('shows Turkish separators and hides float noise', () {
    expect(press('1234567'), '1.234.567');
    expect(press('3,14'), '3,14');
    expect(press('0,1+0,2='), '0,3');
    expect(press('1÷3='), '0,33333333');
  });

  test('editing the number', () {
    expect(press('123<'), '12');
    expect(press('5±'), '-5');
    expect(press('5+±3='), '2');
    expect(press('12+5C7='), '19');
    expect(press('12+5A'), '0');
    expect(press('1234567890'), '123.456.789', reason: 'nine digits at most');
  });

  test('dividing by zero shows an error until the next number', () {
    final c = Calculator();
    expect(press('5÷0=', c), 'Hata');
    expect(press('3', c), '3');
  });

  test('very large results switch to exponent form', () {
    expect(press('99999×99999×99999='), '9,99970e14');
  });
}
