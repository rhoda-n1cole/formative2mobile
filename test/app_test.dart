import 'package:campus_incident_app/app/validators.dart';
import 'package:campus_incident_app/models/incident.dart';
import 'package:campus_incident_app/widgets/status_chip.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Validators.email', () {
    test('accepts ALU student email', () {
      expect(Validators.email('r.umutesi1@alustudent.com'), isNull);
    });
    test('rejects non-ALU email', () {
      expect(Validators.email('test@gmail.com'), isNotNull);
    });
    test('rejects empty and malformed', () {
      expect(Validators.email(''), isNotNull);
      expect(Validators.email('not-an-email'), isNotNull);
    });
  });

  group('Validators.password', () {
    test('rejects short', () => expect(Validators.password('123'), isNotNull));
    test('accepts 6+', () => expect(Validators.password('abcdef'), isNull));
  });

  group('Incident.fromMap', () {
    test('parses fields and applies defaults', () {
      final i = Incident.fromMap('abc', {
        'title': 'Broken tap',
        'description': 'Leaking badly',
        'location': 'Block B',
        'reporterId': 'u1',
      });
      expect(i.id, 'abc');
      expect(i.status, 'Submitted');
      expect(i.category, 'Other');
      expect(i.isAnonymous, false);
    });
  });

  testWidgets('StatusChip shows the status text', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: StatusChip('In Progress'))),
    );
    expect(find.text('In Progress'), findsOneWidget);
  });
}
