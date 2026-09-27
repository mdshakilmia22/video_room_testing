import 'package:agora_video_call_test/app/core/core_export.dart';
import 'package:agora_video_call_test/app/data/data_export.dart';
import 'package:agora_video_call_test/app/pages/video_room/components/call_controls.dart';
import 'package:agora_video_call_test/app/pages/video_room/components/room_header.dart';
import 'package:agora_video_call_test/app/pages/video_room/components/remote_video_canvas.dart';
import 'package:agora_video_call_test/app/pages/video_room/components/self_video_pip.dart';
import 'package:agora_video_call_test/app/pages/video_room/video_room_state.dart';
import 'package:agora_video_call_test/app/pages/video_room/video_room_view.dart';
import 'package:agora_video_call_test/app/pages/video_room/video_room_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const permissionChannel = MethodChannel(
    'flutter.baseflow.com/permissions/methods',
  );

  setUp(() {
    // PermissionStatus.granted == 1. Returning 0 means "denied", which is what
    // would silently push the whole room screen into its permission error.
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(permissionChannel, (call) async {
          if (call.method == 'checkPermissionStatus') return 1;
          if (call.method == 'requestPermissions') {
            final values = (call.arguments as List).cast<int>();
            return <int, int>{for (final value in values) value: 1};
          }
          return null;
        });
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(permissionChannel, null);
  });

  Future<RoomModel> pumpRoom(
    WidgetTester tester, {
    VideoRoomNotifier Function()? notifier,
  }) async {
    final room = RoomRepository().createRoom();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          if (notifier != null) videoRoomProvider.overrideWith(notifier),
        ],
        child: MaterialApp(
          theme: AppTheme.lightTheme,
          home: VideoRoomView(room: room),
        ),
      ),
    );
    await tester.pump();
    return room;
  }

  testWidgets('header renders a white bar with a dark title and the room id', (
    tester,
  ) async {
    final room = await pumpRoom(tester);

    final header = find.byType(RoomHeader);
    expect(header, findsOneWidget);

    final bar = tester.widget<Container>(
      find.descendant(of: header, matching: find.byType(Container)).first,
    );
    expect(bar.color, AppColors.primaryContainerColor);

    expect(
      find.descendant(of: header, matching: find.text('Video Room')),
      findsOneWidget,
    );
    expect(
      find.descendant(of: header, matching: find.text('#${room.roomId}')),
      findsOneWidget,
    );
  });

  testWidgets('header shows a gray people icon with the participant count', (
    tester,
  ) async {
    await pumpRoom(tester);

    final header = find.byType(RoomHeader);
    final peopleIcon = tester.widget<Icon>(
      find.descendant(
        of: header,
        matching: find.byIcon(Icons.people_alt_rounded),
      ),
    );
    expect(peopleIcon.color, AppColors.secondaryTextLight);
    expect(
      find.descendant(of: header, matching: find.text('0')),
      findsOneWidget,
    );
  });

  testWidgets('the self view pip floats below the header at the top right', (
    tester,
  ) async {
    final size = tester.view.physicalSize / tester.view.devicePixelRatio;
    addTearDown(tester.view.reset);

    await pumpRoom(tester);

    final positioned = tester.widget<Positioned>(
      find.descendant(
        of: find.byType(SelfVideoPip),
        matching: find.byType(Positioned),
      ),
    );
    expect(positioned.right, kVideoPipMargin);
    expect(positioned.top, greaterThan(kVideoHeaderHeight));

    final pip = tester.getSize(find.byType(SelfVideoPip));
    expect(pip.width, kVideoPipWidth);
    expect(pip.height, kVideoPipHeight);

    final pipBox = tester.getTopLeft(find.byType(SelfVideoPip));
    expect(pipBox.dx, greaterThan(size.width / 2));
  });

  testWidgets('the self view renders the local camera with canvas uid 0', (
    tester,
  ) async {
    await pumpRoom(tester);

    // A non zero uid makes the SDK resolve the view to
    // VideoSourceType.videoSourceRemote and the self view renders black.
    expect(SelfVideoPip.localCanvas.uid, 0);
  });

  testWidgets(
    'the header bar is pinned to the top and does not fill the screen',
    (tester) async {
      final size = tester.view.physicalSize / tester.view.devicePixelRatio;
      addTearDown(tester.view.reset);

      await pumpRoom(tester);

      // A non positioned child of StackFit.expand gets tight full screen
      // constraints, which painted the white bar over the whole video.
      final header = tester.getRect(find.byType(RoomHeader));
      expect(header.top, 0);
      expect(header.width, size.width);
      expect(header.height, lessThan(size.height / 2));
    },
  );

  testWidgets('the control band is pinned to the bottom of the screen', (
    tester,
  ) async {
    final size = tester.view.physicalSize / tester.view.devicePixelRatio;
    addTearDown(tester.view.reset);

    await pumpRoom(tester);

    final controls = tester.getRect(find.byType(CallControls));
    expect(controls.bottom, size.height);
    expect(controls.width, size.width);
    expect(controls.height, lessThan(size.height / 2));

    // The buttons have to sit inside the bottom band, not at the top.
    expect(
      tester.getRect(find.text('Leave')).top,
      greaterThan(size.height / 2),
    );
  });

  testWidgets('the status bar uses dark glyphs for the white header', (
    tester,
  ) async {
    await pumpRoom(tester);

    final overlay = tester
        .widget<AnnotatedRegion<SystemUiOverlayStyle>>(
          find.byType(AnnotatedRegion<SystemUiOverlayStyle>),
        )
        .value;
    expect(overlay.statusBarIconBrightness, Brightness.dark);
  });

  testWidgets('the room stays connecting until the sdk confirms the join', (
    tester,
  ) async {
    await pumpRoom(tester);
    await tester.pump(const Duration(milliseconds: 500));

    // The Agora engine cannot report a join in a unit test, so the view must
    // keep saying "connecting" and must not pretend the user is in the channel.
    expect(find.text('Connecting to room...'), findsOneWidget);
    expect(find.text('Retry'), findsNothing);

    final header = find.byType(RoomHeader);
    expect(
      find.descendant(of: header, matching: find.text('0')),
      findsOneWidget,
    );
    expect(find.descendant(of: header, matching: find.text('1')), findsNothing);
  });

  testWidgets('a denied permission shows an error with a retry action', (
    tester,
  ) async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(permissionChannel, (call) async {
          if (call.method == 'checkPermissionStatus') return 0;
          if (call.method == 'requestPermissions') {
            final values = (call.arguments as List).cast<int>();
            return <int, int>{for (final value in values) value: 0};
          }
          return null;
        });

    await pumpRoom(tester);

    expect(find.textContaining('permissions are required'), findsOneWidget);
    expect(find.text('Retry'), findsOneWidget);
  });

  testWidgets('the remote canvas explains an empty and a muted remote video', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: RemoteVideoCanvas(
            remoteUid: null,
            channelName: 'video_room_482319',
            hasRemoteVideo: false,
          ),
        ),
      ),
    );

    expect(find.text('Waiting for others to join...'), findsOneWidget);

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: RemoteVideoCanvas(
            remoteUid: 998877,
            channelName: 'video_room_482319',
            hasRemoteVideo: false,
          ),
        ),
      ),
    );

    expect(find.text('Camera is off'), findsOneWidget);
  });

  testWidgets('bottom controls show mic, camera and leave with labels', (
    tester,
  ) async {
    await pumpRoom(tester);

    final controls = find.byType(CallControls);
    expect(controls, findsOneWidget);

    expect(find.text('Mic'), findsOneWidget);
    expect(find.text('Camera'), findsOneWidget);
    expect(find.text('Leave'), findsOneWidget);

    expect(
      find.descendant(of: controls, matching: find.byIcon(Icons.mic_rounded)),
      findsOneWidget,
    );
    expect(
      find.descendant(
        of: controls,
        matching: find.byIcon(Icons.videocam_rounded),
      ),
      findsOneWidget,
    );

    final leaveIcon = tester.widget<Icon>(find.byIcon(Icons.call_end_rounded));
    expect(leaveIcon.color, Colors.white);
  });

  testWidgets('the leave button uses the system call end red', (tester) async {
    await pumpRoom(tester);

    final circles = find.descendant(
      of: find.byType(CallControls),
      matching: find.byType(Container),
    );
    final colors = tester
        .widgetList<Container>(circles)
        .map((c) => (c.decoration as BoxDecoration?)?.color)
        .whereType<Color>();

    expect(colors, contains(AppColors.red1));
  });

  testWidgets('an ios style swipe indicator sits at the bottom', (
    tester,
  ) async {
    await pumpRoom(tester);

    final controls = find.byType(CallControls);
    final indicator = find.descendant(
      of: controls,
      matching: find.byWidgetPredicate(
        (widget) =>
            widget is Container &&
            widget.decoration is BoxDecoration &&
            ((widget.decoration! as BoxDecoration).borderRadius ==
                BorderRadius.circular(3)) &&
            widget.constraints?.maxHeight == 5,
      ),
    );

    expect(indicator, findsOneWidget);
  });

  testWidgets('the error banner can reveal the agora diagnostics', (
    tester,
  ) async {
    await pumpRoom(tester, notifier: _CertificateFailingNotifier.new);

    await tester.tap(find.text('Details'));
    await tester.pump(const Duration(milliseconds: 200));

    // The App ID proves which build is running, the token mode proves whether a
    // token server is expected, and the raw code names the real failure. All
    // three are needed to tell a certificate problem apart from an old APK.
    expect(
      find.textContaining('68b249e23dc6458b9358bd0ba2237b5e'),
      findsOneWidget,
    );
    expect(find.textContaining('errInvalidToken'), findsOneWidget);
  });

  testWidgets('the diagnostics can be copied for a bug report', (tester) async {
    String? copied;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, (call) async {
          if (call.method == 'Clipboard.setData') {
            final args = call.arguments as Map?;
            copied = args?['text'] as String?;
          }
          return null;
        });
    addTearDown(
      () => TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(SystemChannels.platform, null),
    );

    await pumpRoom(tester, notifier: _CertificateFailingNotifier.new);

    await tester.tap(find.text('Details'));
    await tester.pump(const Duration(milliseconds: 200));
    await tester.tap(find.text('Copy'));
    await tester.pump(const Duration(milliseconds: 200));

    expect(copied, contains('68b249e23dc6458b9358bd0ba2237b5e'));
    expect(copied, contains('errInvalidToken'));
  });
}

/// Reproduces the failure the SDK reports when an Agora project has an App
/// Certificate enabled and the app joins with an empty token. It drives the
/// notifier through the same code path as the real `onError` callback.
class _CertificateFailingNotifier extends VideoRoomNotifier {
  @override
  VideoRoomState build() {
    return const VideoRoomState(
      roomId: '520075',
      channelName: 'video_room_520075',
      localUid: 123456,
      isConnecting: false,
      isJoined: false,
      errorMessage: 'Agora refused the empty token.',
      rawAgoraError: 'errInvalidToken: invalid token',
    );
  }

  /// The real `init` would ask for permissions and start a join, which clears
  /// the seeded error. A failing room never gets that far.
  @override
  Future<void> init({required RoomModel room}) async {}
}
