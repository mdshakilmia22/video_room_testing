import 'package:agora_video_call_test/main.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('the app boots into the home screen', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: MyApp()));
    await tester.pumpAndSettle();

    expect(find.text('Video Room'), findsOneWidget);
    expect(
      find.text('Create or join a video room and start calling'),
      findsOneWidget,
    );
    expect(find.text('Create Room'), findsOneWidget);
    expect(find.text('Join Room'), findsOneWidget);
  });
}
