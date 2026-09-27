import 'package:agora_video_call_test/app/core/core_export.dart';
import 'package:agora_video_call_test/app/pages/home/home_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Future<void> pumpApp(WidgetTester tester, Widget home) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          navigatorKey: appNavigatorKey,
          theme: AppTheme.lightTheme,
          home: home,
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  Future<void> openRoomSetup(WidgetTester tester, String cardTitle) async {
    await pumpApp(tester, const HomeView());
    await tester.tap(find.text(cardTitle));
    await tester.pumpAndSettle();
  }

  testWidgets('home shows the hero and both action cards', (tester) async {
    await pumpApp(tester, const HomeView());

    expect(find.text('Video Room'), findsOneWidget);
    expect(
      find.text('Create or join a video room and start calling'),
      findsOneWidget,
    );
    expect(find.byIcon(Icons.videocam_rounded), findsOneWidget);
    expect(find.text('Create Room'), findsOneWidget);
    expect(
      find.text('Create a new room and start a video call'),
      findsOneWidget,
    );
    expect(find.text('Join Room'), findsOneWidget);
    expect(find.text('Join an existing room using room ID'), findsOneWidget);
  });

  testWidgets('tapping create room opens the room setup screen', (
    tester,
  ) async {
    await openRoomSetup(tester, 'Create Room');

    expect(
      find.text('Create a new video room and share the room ID with others'),
      findsOneWidget,
    );
    expect(find.widgetWithText(ElevatedButton, 'Start Room'), findsOneWidget);
    expect(find.text('OR'), findsOneWidget);
    expect(
      find.text('Enter the room ID to join an existing video room'),
      findsOneWidget,
    );
    expect(find.widgetWithText(ElevatedButton, 'Join Room'), findsOneWidget);
  });

  testWidgets('tapping join room opens the room setup screen', (tester) async {
    await openRoomSetup(tester, 'Join Room');

    expect(find.widgetWithText(ElevatedButton, 'Start Room'), findsOneWidget);
    expect(find.widgetWithText(ElevatedButton, 'Join Room'), findsOneWidget);
    expect(find.text('Share this Room ID with others to join'), findsOneWidget);
  });

  testWidgets('the generated room id is shown as 6 digits', (tester) async {
    await openRoomSetup(tester, 'Create Room');

    expect(find.text('Room ID'), findsOneWidget);
    expect(find.textContaining(RegExp(r'^\d{6}$')), findsOneWidget);
    expect(find.byIcon(Icons.copy_rounded), findsOneWidget);
  });

  testWidgets('joining with an invalid room id shows an error', (tester) async {
    await openRoomSetup(tester, 'Join Room');

    await tester.enterText(find.byType(TextField), '123');
    await tester.pump();
    await tester.tap(find.widgetWithText(ElevatedButton, 'Join Room'));
    await tester.pump();

    expect(find.textContaining('valid 6 digit room ID'), findsOneWidget);
  });

  testWidgets('the back button returns to the home screen', (tester) async {
    await openRoomSetup(tester, 'Create Room');

    await tester.tap(find.byIcon(Icons.chevron_left_rounded));
    await tester.pumpAndSettle();

    expect(
      find.text('Create or join a video room and start calling'),
      findsOneWidget,
    );
  });
}
