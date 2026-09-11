AI Challenge – StatsPage Flutter Riverpod
1. Tujuan

Pada tugas AI Challenge ini, AI digunakan sebagai co-developer untuk membantu membuat halaman Flutter bernama `StatsPage` menggunakan `flutter_riverpod`.

Implementasi yang dibuat harus memiliki proses pengambilan data secara asynchronous dengan delay 2 detik, kemungkinan error sebesar 30%, serta menangani tiga kondisi yaitu loading, error, dan success.

Selain itu, dibuat juga unit test untuk memastikan kode dapat berjalan dengan baik.


2. Prompt yang Digunakan

Prompt yang diberikan kepada AI coding assistant adalah:

> Buatkan halaman Flutter bernama StatsPage menggunakan flutter_riverpod.
>
> Requirements:
> - ConsumerWidget dengan satu AsyncNotifierProvider yang mensimulasikan pengambilan data statistik (delay 2 detik, kadang gagal 30%).
> - UI harus menangani loading (spinner), error (pesan + tombol retry), dan success (ListView 3 item).
> - Berikan unit test untuk notifier-nya.
> Jelaskan setiap bagian kode dalam komentar.

---

3. Output Awal dari AI

AI menghasilkan implementasi yang terdiri dari beberapa bagian utama:

1. `StatsNotifier` untuk mengatur proses pengambilan data.
2. `AsyncNotifierProvider` untuk menyediakan state asynchronous.
3. `StatsPage` sebagai halaman untuk menampilkan data.
4. Handling `loading`, `error`, dan `success`.
5. Tombol `Retry` untuk mencoba mengambil data kembali.
6. Unit test untuk melakukan pengujian.

Struktur file yang digunakan:
 
Package Riverpod yang digunakan pada project:
flutter_riverpod: ^3.4.3

4. Implementasi StatsNotifier
File:
lib/stats_notifier.dart
Notifier menggunakan AsyncNotifier dan AsyncNotifierProvider.
Proses pengambilan data dibuat secara simulasi menggunakan delay selama 2 detik.
Kemudian digunakan kondisi random untuk membuat kemungkinan error sebesar 30%.
Jika proses berhasil, data statistik yang ditampilkan terdiri dari:
•	Total Pengguna: 120 
•	Total Pesanan: 75 
•	Total Produk: 45 
Jika terjadi error, aplikasi menampilkan pesan error dan menyediakan tombol Retry.
5. Implementasi StatsPage
File:
lib/stats_page.dart
StatsPage menggunakan ConsumerWidget agar dapat mengakses state dari Riverpod.
Pada bagian build, digunakan:
ref.watch(statsProvider)
untuk mengamati perubahan state dari provider.
State asynchronous ditangani menjadi tiga kondisi:
Loading
Ketika data sedang diproses, aplikasi menampilkan:
CircularProgressIndicator
Error
Jika proses pengambilan data gagal, aplikasi menampilkan pesan error dan tombol:
Retry
Tombol Retry menggunakan:
ref.read(statsProvider.notifier).retry()
Success
Jika data berhasil diperoleh, data ditampilkan menggunakan:
ListView
dengan tiga data statistik.
________________________________________
6. Perbaikan yang Dilakukan Setelah Verifikasi
Setelah kode dari AI digunakan, dilakukan pengecekan dan perbaikan.
Perbaikan 1 – Struktur Unit Test
Pada awalnya file test sempat berada di dalam folder lib.
Kemudian diperbaiki agar berada pada folder:
test/
Struktur yang benar:
week3_todo/
├── lib/
└── test/
    └── widget_test.dart
Hal ini dilakukan agar file pengujian tidak dianggap sebagai bagian dari kode aplikasi.
Perbaikan 2 – ProviderScope
Saat menjalankan test, muncul error:
Bad state: No ProviderScope found
Masalah tersebut terjadi karena StatsPage menggunakan Riverpod tetapi test belum menyediakan ProviderScope.
Kemudian test diperbaiki dengan membungkus StatsPage menggunakan:
ProviderScope(
  child: MaterialApp(
    home: StatsPage(),
  ),
)
Perbaikan 3 – MaterialApp
Setelah ProviderScope ditambahkan, muncul masalah:
No Directionality widget found
Hal tersebut terjadi karena Scaffold membutuhkan Directionality.
Kemudian StatsPage dibungkus menggunakan:
MaterialApp(
  home: StatsPage(),
)
Perbaikan 4 – Menangani Delay 2 Detik pada Test
Karena StatsNotifier menggunakan delay selama 2 detik, test awal mengalami masalah timer yang masih berjalan.
Kemudian test diperbaiki dengan menunggu proses asynchronous menggunakan:
await tester.pump(const Duration(seconds: 2));
Setelah perbaikan tersebut, test dapat berjalan dengan baik.
________________________________________
7. Verifikasi AI Checklist
8. Apakah state diubah secara immutable?
Ya.
State tidak dimodifikasi secara langsung menggunakan state.add() atau mutasi list secara langsung.
Perubahan state dilakukan melalui state asynchronous Riverpod.
2. Apakah ref.watch hanya digunakan di dalam build?
Ya.
ref.watch(statsProvider) digunakan di dalam method build.
Sedangkan pada callback tombol Retry digunakan:
ref.read(statsProvider.notifier).retry();
3. Apakah tiga state AsyncValue ditangani?
Ya.
Ketiga kondisi sudah ditangani:
Loading
Error
Success
Loading menggunakan CircularProgressIndicator, error menampilkan pesan dan tombol Retry, sedangkan success menampilkan data menggunakan ListView.
4. Apakah provider dideklarasikan dengan tipe yang sesuai?
Ya.
Provider menggunakan:
AsyncNotifierProvider
dan notifier menggunakan:
AsyncNotifier
5. Apakah API Riverpod yang digunakan sesuai?
Ya.
Implementasi menggunakan pola Riverpod yang sesuai dengan package:
flutter_riverpod: ^3.4.3
dan tidak menggunakan pola lama seperti StateNotifierProvider untuk implementasi utama tugas ini.
6. Apakah kode berhasil melalui flutter analyze dan flutter test?
Ya.
8. Hasil Tampilan Aplikasi
Halaman StatsPage berhasil dijalankan pada Chrome.
Tampilan success menampilkan:


 Selain kondisi success, aplikasi juga memiliki kondisi loading dan error sesuai requirement.
Pada kondisi error, aplikasi menampilkan pesan kegagalan dan tombol Retry untuk melakukan pengambilan data kembali.

9. Hasil Testing
Perintah yang digunakan:
flutter analyze
Hasil:
No issues found!
Kemudian:
flutter test
Hasil:
00:05 +2: All tests passed!
Hasil tersebut menunjukkan bahwa kode tidak memiliki masalah yang terdeteksi oleh analyzer dan seluruh test berhasil dijalankan.
________________________________________
10. Kesimpulan
AI membantu proses pembuatan awal kode StatsPage, AsyncNotifierProvider, handling state asynchronous, dan testing.
Namun, kode dari AI tetap diverifikasi dan diperbaiki agar sesuai dengan struktur project dan kebutuhan Flutter Riverpod yang digunakan.
Beberapa perbaikan dilakukan pada bagian unit test, terutama penggunaan ProviderScope, MaterialApp, dan penanganan delay asynchronous.
Setelah dilakukan perbaikan, aplikasi berhasil dijalankan dan seluruh test berhasil.
Hasil akhir:
 

Hasil terminal 
PS C:\Users\LENOVO\Documents\SEMESTER 5\PemMob\244107020059-mobile-course\03-week-3-navigation-state-management> cd week3_todo                   
PS C:\Users\LENOVO\Documents\SEMESTER 5\PemMob\244107020059-mobile-course\03-week-3-navigation-state-management\week3_todo> flutter analyze
Analyzing week3_todo...                                                 

   info - The imported package 'flutter_test' isn't a dependency of the importing package. Try adding a
          dependency for 'flutter_test' in the 'pubspec.yaml' file - lib\test\stats_notifier_test.dart:1:8 -
          depend_on_referenced_packages

1 issue found. (ran in 7.8s)
PS C:\Users\LENOVO\Documents\SEMESTER 5\PemMob\244107020059-mobile-course\03-week-3-navigation-state-management\week3_todo> flutter analyze
Analyzing week3_todo...                                                 
No issues found! (ran in 5.7s)
PS C:\Users\LENOVO\Documents\SEMESTER 5\PemMob\244107020059-mobile-course\03-week-3-navigation-state-management\week3_todo> flutter test
00:21 +1: C:/Users/LENOVO/Documents/SEMESTER 5/PemMob/244107020059-mobile-course/03-week-3-navigation-state-management/week3_todo/test/widget_test.dart: Counter increments smoke test
══╡ EXCEPTION CAUGHT BY WIDGETS LIBRARY ╞═══════════════════════════════════════════════════════════
The following StateError was thrown building StatsPage(dirty, state: _ConsumerState#c046d):
Bad state: No ProviderScope found

The relevant error-causing widget was:
  StatsPage
  StatsPage:file:///C:/Users/LENOVO/Documents/SEMESTER%205/PemMob/244107020059-mobile-course/03-week-3-navigation-state-management/week3_todo/lib/main.dart:28:19

When the exception was thrown, this was the stack:
#0      ProviderScope.containerOf (package:flutter_riverpod/src/core/provider_scope.dart:105:7)
#1      ConsumerStatefulElement.container (package:flutter_riverpod/src/core/consumer.dart:374:52)
#2      ConsumerStatefulElement.container (package:flutter_riverpod/src/core/consumer.dart)
#3      ConsumerStatefulElement.watch.<anonymous closure> (package:flutter_riverpod/src/core/consumer.dart:490:27)
#4      _LinkedHashMapMixin.putIfAbsent (dart:_compact_hash:631:23)
#5      ConsumerStatefulElement.watch (package:flutter_riverpod/src/core/consumer.dart:483:14)
#6      StatsPage.build (package:week3_todo/stats_page.dart:17:28)
#7      _ConsumerState.build (package:flutter_riverpod/src/core/consumer.dart:283:48)
#8      StatefulElement.build (package:flutter/src/widgets/framework.dart:5944:27)
#9      ConsumerStatefulElement.build (package:flutter_riverpod/src/core/consumer.dart:460:20)
#10     ComponentElement.performRebuild (package:flutter/src/widgets/framework.dart:5830:15)
#11     StatefulElement.performRebuild (package:flutter/src/widgets/framework.dart:5995:11)
#12     Element.rebuild (package:flutter/src/widgets/framework.dart:5542:7)
#13     ComponentElement._firstBuild (package:flutter/src/widgets/framework.dart:5812:5)
#14     StatefulElement._firstBuild (package:flutter/src/widgets/framework.dart:5986:11)
#15     ComponentElement.mount (package:flutter/src/widgets/framework.dart:5806:5)
#16     ConsumerStatefulElement.mount (package:flutter_riverpod/src/core/consumer.dart:389:11)
...     Normal element mounting (260 frames)
#276    Element.inflateWidget (package:flutter/src/widgets/framework.dart:4600:20)
#277    MultiChildRenderObjectElement.inflateWidget (package:flutter/src/widgets/framework.dart:7277:36)
#278    MultiChildRenderObjectElement.mount (package:flutter/src/widgets/framework.dart:7292:32)
...     Normal element mounting (456 frames)
#734    Element.inflateWidget (package:flutter/src/widgets/framework.dart:4600:20)
#735    Element.updateChild (package:flutter/src/widgets/framework.dart:4066:20)
#736    ComponentElement.performRebuild (package:flutter/src/widgets/framework.dart:5854:16)
#737    Element.rebuild (package:flutter/src/widgets/framework.dart:5542:7)
#738    ProxyElement.update (package:flutter/src/widgets/framework.dart:6162:5)
#739    _InheritedNotifierElement.update (package:flutter/src/widgets/inherited_notifier.dart:108:11)
#740    Element.updateChild (package:flutter/src/widgets/framework.dart:4050:15)
#741    ComponentElement.performRebuild (package:flutter/src/widgets/framework.dart:5854:16)
#742    StatefulElement.performRebuild (package:flutter/src/widgets/framework.dart:5995:11)
#743    Element.rebuild (package:flutter/src/widgets/framework.dart:5542:7)
#744    StatefulElement.update (package:flutter/src/widgets/framework.dart:6020:5)
#745    Element.updateChild (package:flutter/src/widgets/framework.dart:4050:15)
#746    ComponentElement.performRebuild (package:flutter/src/widgets/framework.dart:5854:16)
#747    Element.rebuild (package:flutter/src/widgets/framework.dart:5542:7)
#748    ProxyElement.update (package:flutter/src/widgets/framework.dart:6162:5)
#749    _InheritedNotifierElement.update (package:flutter/src/widgets/inherited_notifier.dart:108:11)
#750    Element.updateChild (package:flutter/src/widgets/framework.dart:4050:15)
#751    ComponentElement.performRebuild (package:flutter/src/widgets/framework.dart:5854:16)
#752    StatefulElement.performRebuild (package:flutter/src/widgets/framework.dart:5995:11)
#753    Element.rebuild (package:flutter/src/widgets/framework.dart:5542:7)
#754    StatefulElement.update (package:flutter/src/widgets/framework.dart:6020:5)
#755    Element.updateChild (package:flutter/src/widgets/framework.dart:4050:15)
#756    ComponentElement.performRebuild (package:flutter/src/widgets/framework.dart:5854:16)
#757    StatefulElement.performRebuild (package:flutter/src/widgets/framework.dart:5995:11)
#758    Element.rebuild (package:flutter/src/widgets/framework.dart:5542:7)
#759    StatefulElement.update (package:flutter/src/widgets/framework.dart:6020:5)
#760    Element.updateChild (package:flutter/src/widgets/framework.dart:4050:15)
#761    ComponentElement.performRebuild (package:flutter/src/widgets/framework.dart:5854:16)
#762    Element.rebuild (package:flutter/src/widgets/framework.dart:5542:7)
#763    ProxyElement.update (package:flutter/src/widgets/framework.dart:6162:5)
#764    Element.updateChild (package:flutter/src/widgets/framework.dart:4050:15)
#765    ComponentElement.performRebuild (package:flutter/src/widgets/framework.dart:5854:16)
#766    StatefulElement.performRebuild (package:flutter/src/widgets/framework.dart:5995:11)
#767    Element.rebuild (package:flutter/src/widgets/framework.dart:5542:7)
#768    StatefulElement.update (package:flutter/src/widgets/framework.dart:6020:5)
#769    Element.updateChild (package:flutter/src/widgets/framework.dart:4050:15)
#770    ComponentElement.performRebuild (package:flutter/src/widgets/framework.dart:5854:16)
#771    Element.rebuild (package:flutter/src/widgets/framework.dart:5542:7)
#772    ProxyElement.update (package:flutter/src/widgets/framework.dart:6162:5)
#773    Element.updateChild (package:flutter/src/widgets/framework.dart:4050:15)
#774    ComponentElement.performRebuild (package:flutter/src/widgets/framework.dart:5854:16)
#775    Element.rebuild (package:flutter/src/widgets/framework.dart:5542:7)
#776    ProxyElement.update (package:flutter/src/widgets/framework.dart:6162:5)
#777    Element.updateChild (package:flutter/src/widgets/framework.dart:4050:15)
#778    _RawViewElement._updateChild (package:flutter/src/widgets/view.dart:488:16)
#779    _RawViewElement.update (package:flutter/src/widgets/view.dart:575:5)
#780    Element.updateChild (package:flutter/src/widgets/framework.dart:4050:15)
#781    ComponentElement.performRebuild (package:flutter/src/widgets/framework.dart:5854:16)
#782    Element.rebuild (package:flutter/src/widgets/framework.dart:5542:7)
#783    StatelessElement.update (package:flutter/src/widgets/framework.dart:5908:5)
#784    Element.updateChild (package:flutter/src/widgets/framework.dart:4050:15)
#785    ComponentElement.performRebuild (package:flutter/src/widgets/framework.dart:5854:16)
#786    StatefulElement.performRebuild (package:flutter/src/widgets/framework.dart:5995:11)
#787    Element.rebuild (package:flutter/src/widgets/framework.dart:5542:7)
#788    StatefulElement.update (package:flutter/src/widgets/framework.dart:6020:5)
#789    Element.updateChild (package:flutter/src/widgets/framework.dart:4050:15)
#790    RootElement._rebuild (package:flutter/src/widgets/binding.dart:2091:16)
#791    RootElement.update (package:flutter/src/widgets/binding.dart:2069:5)
#792    RootElement.performRebuild (package:flutter/src/widgets/binding.dart:2083:7)
#793    Element.rebuild (package:flutter/src/widgets/framework.dart:5542:7)
#794    BuildScope._tryRebuild (package:flutter/src/widgets/framework.dart:2763:15)
#795    BuildScope._flushDirtyElements (package:flutter/src/widgets/framework.dart:2820:11)
#796    BuildOwner.buildScope (package:flutter/src/widgets/framework.dart:3124:18)
#797    AutomatedTestWidgetsFlutterBinding.drawFrame (package:flutter_test/src/binding.dart:2432:19)
#798    RendererBinding._handlePersistentFrameCallback (package:flutter/src/rendering/binding.dart:558:5)
#799    SchedulerBinding._invokeFrameCallback (package:flutter/src/scheduler/binding.dart:1430:15)
#800    SchedulerBinding.handleDrawFrame (package:flutter/src/scheduler/binding.dart:1345:9)
#801    AutomatedTestWidgetsFlutterBinding.pump.<anonymous closure> (package:flutter_test/src/binding.dart:2261:9)
#804    TestAsyncUtils.guard (package:flutter_test/src/test_async_utils.dart:74:41)
#805    AutomatedTestWidgetsFlutterBinding.pump (package:flutter_test/src/binding.dart:2250:27)
#806    WidgetTester.pumpWidget.<anonymous closure> (package:flutter_test/src/widget_tester.dart:598:22)
#809    TestAsyncUtils.guard (package:flutter_test/src/test_async_utils.dart:74:41)
#810    WidgetTester.pumpWidget (package:flutter_test/src/widget_tester.dart:595:27)
#811    main.<anonymous closure> (file:///C:/Users/LENOVO/Documents/SEMESTER%205/PemMob/244107020059-mobile-course/03-week-3-navigation-state-management/week3_todo/test/widget_test.dart:16:18)
#812    testWidgets.<anonymous closure>.<anonymous closure> (package:flutter_test/src/widget_tester.dart:192:29)
<asynchronous suspension>
#813    TestWidgetsFlutterBinding._runTestBody (package:flutter_test/src/binding.dart:1953:5)
<asynchronous suspension>
<asynchronous suspension>
(elided 5 frames from dart:async and package:stack_trace)

════════════════════════════════════════════════════════════════════════════════════════════════════
══╡ EXCEPTION CAUGHT BY FLUTTER TEST FRAMEWORK ╞════════════════════════════════════════════════════
The following TestFailure was thrown running a test:
Expected: exactly one matching candidate
  Actual: _TextWidgetFinder:<Found 0 widgets with text "0": []>
   Which: means none were found but one was expected

When the exception was thrown, this was the stack:
#4      main.<anonymous closure> (file:///C:/Users/LENOVO/Documents/SEMESTER%205/PemMob/244107020059-mobile-course/03-week-3-navigation-state-management/week3_todo/test/widget_test.dart:19:5)
<asynchronous suspension>
#5      testWidgets.<anonymous closure>.<anonymous closure> (package:flutter_test/src/widget_tester.dart:192:15)
<asynchronous suspension>
#6      TestWidgetsFlutterBinding._runTestBody (package:flutter_test/src/binding.dart:1953:5)
<asynchronous suspension>
<asynchronous suspension>
(elided one frame from package:stack_trace)

This was caught by the test expectation on the following line:
  file:///C:/Users/LENOVO/Documents/SEMESTER%205/PemMob/244107020059-mobile-course/03-week-3-navigation-state-management/week3_todo/test/widget_test.dart line 19
The test description was:
  Counter increments smoke test
════════════════════════════════════════════════════════════════════════════════════════════════════
══╡ EXCEPTION CAUGHT BY FLUTTER TEST FRAMEWORK ╞════════════════════════════════════════════════════
The following message was thrown:
Multiple exceptions (2) were detected during the running of the current test, and at least one was
unexpected.
════════════════════════════════════════════════════════════════════════════════════════════════════
00:21 +1 -1: C:/Users/LENOVO/Documents/SEMESTER 5/PemMob/244107020059-mobile-course/03-week-3-navigation-state-management/week3_todo/test/widget_test.dart: Counter increments smoke test [E]
  Test failed. See exception logs above.
  The test description was: Counter increments smoke test
  

To run this test again: C:\flutter\bin\cache\dart-sdk\bin\dart.exe test C:/Users/LENOVO/Documents/SEMESTER 5/PemMob/244107020059-mobile-course/03-week-3-navigation-state-management/week3_todo/test/widget_test.dart -p vm --plain-name "Counter increments smoke test"
00:21 +1 -1: Some tests failed.                                                                              
PS C:\Users\LENOVO\Documents\SEMESTER 5\PemMob\244107020059-mobile-course\03-week-3-navigation-state-management\week3_todo> flutter analyze
Analyzing week3_todo...                                                 
No issues found! (ran in 5.6s)
PS C:\Users\LENOVO\Documents\SEMESTER 5\PemMob\244107020059-mobile-course\03-week-3-navigation-state-management\week3_todo> flutter test
00:03 +1: C:/Users/LENOVO/Documents/SEMESTER 5/PemMob/244107020059-mobile-course/03-week-3-navigation-state-management/week3_todo/test/widget_test.dart: StatsPage dapat ditampilkan
══╡ EXCEPTION CAUGHT BY WIDGETS LIBRARY ╞═══════════════════════════════════════════════════════════
The following assertion was thrown building Scaffold(dirty, state: ScaffoldState#e7411(tickers:
tracking 3 tickers)):
No Directionality widget found.
Scaffold widgets require a Directionality widget ancestor.
The specific widget that could not find a Directionality ancestor was:
  Scaffold
The ownership chain for the affected widget is: "Scaffold ← StatsPage ← _UncontrolledProviderScope ←
  UncontrolledProviderScope ← ProviderScope ← _FocusInheritedScope ←
  _FocusScopeWithExternalFocusNode ← _FocusInheritedScope ← Focus ← FocusTraversalGroup ← ⋯"
Typically, the Directionality widget is introduced by the MaterialApp or WidgetsApp widget at the
top of your application widget tree. It determines the ambient reading direction and is used, for
example, to determine how to lay out text, how to interpret "start" and "end" values, and to resolve
EdgeInsetsDirectional, AlignmentDirectional, and other *Directional objects.

The relevant error-causing widget was:
  Scaffold
  Scaffold:file:///C:/Users/LENOVO/Documents/SEMESTER%205/PemMob/244107020059-mobile-course/03-week-3-navigation-state-management/week3_todo/lib/stats_page.dart:19:12

When the exception was thrown, this was the stack:
#0      debugCheckHasDirectionality.<anonymous closure> (package:flutter/src/widgets/debug.dart:400:7)
#1      debugCheckHasDirectionality (package:flutter/src/widgets/debug.dart:422:4)
#2      ScaffoldState.build (package:flutter/src/material/scaffold.dart:3014:12)
#3      StatefulElement.build (package:flutter/src/widgets/framework.dart:5944:27)
#4      ComponentElement.performRebuild (package:flutter/src/widgets/framework.dart:5830:15)
#5      StatefulElement.performRebuild (package:flutter/src/widgets/framework.dart:5995:11)
#6      Element.rebuild (package:flutter/src/widgets/framework.dart:5542:7)
#7      ComponentElement._firstBuild (package:flutter/src/widgets/framework.dart:5812:5)
#8      StatefulElement._firstBuild (package:flutter/src/widgets/framework.dart:5986:11)
#9      ComponentElement.mount (package:flutter/src/widgets/framework.dart:5806:5)
...     Normal element mounting (9 frames)
#18     ConsumerStatefulElement.mount (package:flutter_riverpod/src/core/consumer.dart:389:11)
...     Normal element mounting (23 frames)
#41     Element.inflateWidget (package:flutter/src/widgets/framework.dart:4600:20)
#42     Element.updateChild (package:flutter/src/widgets/framework.dart:4066:20)
#43     ComponentElement.performRebuild (package:flutter/src/widgets/framework.dart:5854:16)
#44     Element.rebuild (package:flutter/src/widgets/framework.dart:5542:7)
#45     ProxyElement.update (package:flutter/src/widgets/framework.dart:6162:5)
#46     _InheritedNotifierElement.update (package:flutter/src/widgets/inherited_notifier.dart:108:11)
#47     Element.updateChild (package:flutter/src/widgets/framework.dart:4050:15)
#48     ComponentElement.performRebuild (package:flutter/src/widgets/framework.dart:5854:16)
#49     StatefulElement.performRebuild (package:flutter/src/widgets/framework.dart:5995:11)
#50     Element.rebuild (package:flutter/src/widgets/framework.dart:5542:7)
#51     StatefulElement.update (package:flutter/src/widgets/framework.dart:6020:5)
#52     Element.updateChild (package:flutter/src/widgets/framework.dart:4050:15)
#53     ComponentElement.performRebuild (package:flutter/src/widgets/framework.dart:5854:16)
#54     Element.rebuild (package:flutter/src/widgets/framework.dart:5542:7)
#55     ProxyElement.update (package:flutter/src/widgets/framework.dart:6162:5)
#56     _InheritedNotifierElement.update (package:flutter/src/widgets/inherited_notifier.dart:108:11)
#57     Element.updateChild (package:flutter/src/widgets/framework.dart:4050:15)
#58     ComponentElement.performRebuild (package:flutter/src/widgets/framework.dart:5854:16)
#59     StatefulElement.performRebuild (package:flutter/src/widgets/framework.dart:5995:11)
#60     Element.rebuild (package:flutter/src/widgets/framework.dart:5542:7)
#61     StatefulElement.update (package:flutter/src/widgets/framework.dart:6020:5)
#62     Element.updateChild (package:flutter/src/widgets/framework.dart:4050:15)
#63     ComponentElement.performRebuild (package:flutter/src/widgets/framework.dart:5854:16)
#64     StatefulElement.performRebuild (package:flutter/src/widgets/framework.dart:5995:11)
#65     Element.rebuild (package:flutter/src/widgets/framework.dart:5542:7)
#66     StatefulElement.update (package:flutter/src/widgets/framework.dart:6020:5)
#67     Element.updateChild (package:flutter/src/widgets/framework.dart:4050:15)
#68     ComponentElement.performRebuild (package:flutter/src/widgets/framework.dart:5854:16)
#69     Element.rebuild (package:flutter/src/widgets/framework.dart:5542:7)
#70     ProxyElement.update (package:flutter/src/widgets/framework.dart:6162:5)
#71     Element.updateChild (package:flutter/src/widgets/framework.dart:4050:15)
#72     ComponentElement.performRebuild (package:flutter/src/widgets/framework.dart:5854:16)
#73     StatefulElement.performRebuild (package:flutter/src/widgets/framework.dart:5995:11)
#74     Element.rebuild (package:flutter/src/widgets/framework.dart:5542:7)
#75     StatefulElement.update (package:flutter/src/widgets/framework.dart:6020:5)
#76     Element.updateChild (package:flutter/src/widgets/framework.dart:4050:15)
#77     ComponentElement.performRebuild (package:flutter/src/widgets/framework.dart:5854:16)
#78     Element.rebuild (package:flutter/src/widgets/framework.dart:5542:7)
#79     ProxyElement.update (package:flutter/src/widgets/framework.dart:6162:5)
#80     Element.updateChild (package:flutter/src/widgets/framework.dart:4050:15)
#81     ComponentElement.performRebuild (package:flutter/src/widgets/framework.dart:5854:16)
#82     Element.rebuild (package:flutter/src/widgets/framework.dart:5542:7)
#83     ProxyElement.update (package:flutter/src/widgets/framework.dart:6162:5)
#84     Element.updateChild (package:flutter/src/widgets/framework.dart:4050:15)
#85     _RawViewElement._updateChild (package:flutter/src/widgets/view.dart:488:16)
#86     _RawViewElement.update (package:flutter/src/widgets/view.dart:575:5)
#87     Element.updateChild (package:flutter/src/widgets/framework.dart:4050:15)
#88     ComponentElement.performRebuild (package:flutter/src/widgets/framework.dart:5854:16)
#89     Element.rebuild (package:flutter/src/widgets/framework.dart:5542:7)
#90     StatelessElement.update (package:flutter/src/widgets/framework.dart:5908:5)
#91     Element.updateChild (package:flutter/src/widgets/framework.dart:4050:15)
#92     ComponentElement.performRebuild (package:flutter/src/widgets/framework.dart:5854:16)
#93     StatefulElement.performRebuild (package:flutter/src/widgets/framework.dart:5995:11)
#94     Element.rebuild (package:flutter/src/widgets/framework.dart:5542:7)
#95     StatefulElement.update (package:flutter/src/widgets/framework.dart:6020:5)
#96     Element.updateChild (package:flutter/src/widgets/framework.dart:4050:15)
#97     RootElement._rebuild (package:flutter/src/widgets/binding.dart:2091:16)
#98     RootElement.update (package:flutter/src/widgets/binding.dart:2069:5)
#99     RootElement.performRebuild (package:flutter/src/widgets/binding.dart:2083:7)
#100    Element.rebuild (package:flutter/src/widgets/framework.dart:5542:7)
#101    BuildScope._tryRebuild (package:flutter/src/widgets/framework.dart:2763:15)
#102    BuildScope._flushDirtyElements (package:flutter/src/widgets/framework.dart:2820:11)
#103    BuildOwner.buildScope (package:flutter/src/widgets/framework.dart:3124:18)
#104    AutomatedTestWidgetsFlutterBinding.drawFrame (package:flutter_test/src/binding.dart:2432:19)
#105    RendererBinding._handlePersistentFrameCallback (package:flutter/src/rendering/binding.dart:558:5)
#106    SchedulerBinding._invokeFrameCallback (package:flutter/src/scheduler/binding.dart:1430:15)
#107    SchedulerBinding.handleDrawFrame (package:flutter/src/scheduler/binding.dart:1345:9)
#108    AutomatedTestWidgetsFlutterBinding.pump.<anonymous closure> (package:flutter_test/src/binding.dart:2261:9)
#111    TestAsyncUtils.guard (package:flutter_test/src/test_async_utils.dart:74:41)
#112    AutomatedTestWidgetsFlutterBinding.pump (package:flutter_test/src/binding.dart:2250:27)
#113    WidgetTester.pumpWidget.<anonymous closure> (package:flutter_test/src/widget_tester.dart:598:22)
#116    TestAsyncUtils.guard (package:flutter_test/src/test_async_utils.dart:74:41)
#117    WidgetTester.pumpWidget (package:flutter_test/src/widget_tester.dart:595:27)
#118    main.<anonymous closure> (file:///C:/Users/LENOVO/Documents/SEMESTER%205/PemMob/244107020059-mobile-course/03-week-3-navigation-state-management/week3_todo/test/widget_test.dart:8:18)
#119    testWidgets.<anonymous closure>.<anonymous closure> (package:flutter_test/src/widget_tester.dart:192:29)
<asynchronous suspension>
#120    TestWidgetsFlutterBinding._runTestBody (package:flutter_test/src/binding.dart:1953:5)
<asynchronous suspension>
<asynchronous suspension>
(elided 5 frames from dart:async and package:stack_trace)

════════════════════════════════════════════════════════════════════════════════════════════════════
══╡ EXCEPTION CAUGHT BY FLUTTER TEST FRAMEWORK ╞════════════════════════════════════════════════════
The following TestFailure was thrown running a test:
Expected: exactly one matching candidate
  Actual: _TextWidgetFinder:<Found 0 widgets with text "Statistics": []>
   Which: means none were found but one was expected

When the exception was thrown, this was the stack:
#4      main.<anonymous closure> (file:///C:/Users/LENOVO/Documents/SEMESTER%205/PemMob/244107020059-mobile-course/03-week-3-navigation-state-management/week3_todo/test/widget_test.dart:14:5)
<asynchronous suspension>
#5      testWidgets.<anonymous closure>.<anonymous closure> (package:flutter_test/src/widget_tester.dart:192:15)
<asynchronous suspension>
#6      TestWidgetsFlutterBinding._runTestBody (package:flutter_test/src/binding.dart:1953:5)
<asynchronous suspension>
<asynchronous suspension>
(elided one frame from package:stack_trace)

This was caught by the test expectation on the following line:
  file:///C:/Users/LENOVO/Documents/SEMESTER%205/PemMob/244107020059-mobile-course/03-week-3-navigation-state-management/week3_todo/test/widget_test.dart line 14
The test description was:
  StatsPage dapat ditampilkan
════════════════════════════════════════════════════════════════════════════════════════════════════
══╡ EXCEPTION CAUGHT BY FLUTTER TEST FRAMEWORK ╞════════════════════════════════════════════════════
The following message was thrown:
Multiple exceptions (2) were detected during the running of the current test, and at least one was
unexpected.
════════════════════════════════════════════════════════════════════════════════════════════════════
00:04 +1 -1: C:/Users/LENOVO/Documents/SEMESTER 5/PemMob/244107020059-mobile-course/03-week-3-navigation-state-management/week3_todo/test/widget_test.dart: StatsPage dapat ditampilkan [E]
  Test failed. See exception logs above.
  The test description was: StatsPage dapat ditampilkan
  

To run this test again: C:\flutter\bin\cache\dart-sdk\bin\dart.exe test C:/Users/LENOVO/Documents/SEMESTER 5/PemMob/244107020059-mobile-course/03-week-3-navigation-state-management/week3_todo/test/widget_test.dart -p vm --plain-name "StatsPage dapat ditampilkan"
00:04 +1 -1: Some tests failed.                                                                              
PS C:\Users\LENOVO\Documents\SEMESTER 5\PemMob\244107020059-mobile-course\03-week-3-navigation-state-management\week3_todo> flutter test
00:05 +1: C:/Users/LENOVO/Documents/SEMESTER 5/PemMob/244107020059-mobile-course/03-week-3-navigation-state-management/week3_todo/test/widget_test.dart: StatsPage dapat ditampilkan
Pending timers:
Timer (duration: 0:00:02.000000, periodic: false), created:
#0      new FakeTimer._ (package:fake_async/fake_async.dart:342:62)
#1      FakeAsync._createTimer (package:fake_async/fake_async.dart:260:29)
#2      FakeAsync.run.<anonymous closure> (package:fake_async/fake_async.dart:185:15)
#6      StatsNotifier._getStats (package:week3_todo/stats_notifier.dart:36:18)
#7      StatsNotifier.build (package:week3_todo/stats_notifier.dart:30:12)
#8      ElementWithFuture.handleFuture.<anonymous closure> (package:riverpod/src/core/element.dart:218:30)
#9      ElementWithFuture._handleAsync (package:riverpod/src/core/element.dart:282:35)
#10     ElementWithFuture.handleFuture (package:riverpod/src/core/element.dart:212:12)
#11     $AsyncNotifierProviderElement.handleCreate (package:riverpod/src/providers/async_notifier.dart:91:12)
#12     AsyncNotifier.runBuild (package:riverpod/src/providers/async_notifier/orphan.dart:37:47)
#13     $ClassProviderElement.create (package:riverpod/src/core/provider/notifier_provider.dart:570:43)
#14     ProviderElement.buildState (package:riverpod/src/core/element.dart:751:28)
#15     ProviderElement.mount (package:riverpod/src/core/element.dart:587:7)
#16     ProviderElement.flush (package:riverpod/src/core/element.dart:704:9)
#17     $ProviderBaseImpl._addListener (package:riverpod/src/core/provider/provider.dart:119:24)
#18     ProviderContainer.listen (package:riverpod/src/core/provider_container.dart:1141:26)
#19     ConsumerStatefulElement.watch.<anonymous closure> (package:flutter_riverpod/src/core/consumer.dart:490:37)
#20     _LinkedHashMapMixin.putIfAbsent (dart:_compact_hash:631:23)
#21     ConsumerStatefulElement.watch (package:flutter_riverpod/src/core/consumer.dart:483:14)
#22     StatsPage.build (package:week3_todo/stats_page.dart:17:28)
#23     _ConsumerState.build (package:flutter_riverpod/src/core/consumer.dart:283:48)
#24     StatefulElement.build (package:flutter/src/widgets/framework.dart:5944:27)
#25     ConsumerStatefulElement.build (package:flutter_riverpod/src/core/consumer.dart:460:20)
#26     ComponentElement.performRebuild (package:flutter/src/widgets/framework.dart:5830:15)
#27     StatefulElement.performRebuild (package:flutter/src/widgets/framework.dart:5995:11)
#28     Element.rebuild (package:flutter/src/widgets/framework.dart:5542:7)
#29     ComponentElement._firstBuild (package:flutter/src/widgets/framework.dart:5812:5)
#30     StatefulElement._firstBuild (package:flutter/src/widgets/framework.dart:5986:11)
#31     ComponentElement.mount (package:flutter/src/widgets/framework.dart:5806:5)
#32     ConsumerStatefulElement.mount (package:flutter_riverpod/src/core/consumer.dart:389:11)
...     Normal element mounting (260 frames)
#292    Element.inflateWidget (package:flutter/src/widgets/framework.dart:4600:20)
#293    MultiChildRenderObjectElement.inflateWidget (package:flutter/src/widgets/framework.dart:7277:36)
#294    MultiChildRenderObjectElement.mount (package:flutter/src/widgets/framework.dart:7292:32)
...     Normal element mounting (489 frames)
#783    Element.inflateWidget (package:flutter/src/widgets/framework.dart:4600:20)
#784    Element.updateChild (package:flutter/src/widgets/framework.dart:4066:20)
#785    ComponentElement.performRebuild (package:flutter/src/widgets/framework.dart:5854:16)
#786    Element.rebuild (package:flutter/src/widgets/framework.dart:5542:7)
#787    ProxyElement.update (package:flutter/src/widgets/framework.dart:6162:5)
#788    _InheritedNotifierElement.update (package:flutter/src/widgets/inherited_notifier.dart:108:11)
#789    Element.updateChild (package:flutter/src/widgets/framework.dart:4050:15)
#790    ComponentElement.performRebuild (package:flutter/src/widgets/framework.dart:5854:16)
#791    StatefulElement.performRebuild (package:flutter/src/widgets/framework.dart:5995:11)
#792    Element.rebuild (package:flutter/src/widgets/framework.dart:5542:7)
#793    StatefulElement.update (package:flutter/src/widgets/framework.dart:6020:5)
#794    Element.updateChild (package:flutter/src/widgets/framework.dart:4050:15)
#795    ComponentElement.performRebuild (package:flutter/src/widgets/framework.dart:5854:16)
#796    Element.rebuild (package:flutter/src/widgets/framework.dart:5542:7)
#797    ProxyElement.update (package:flutter/src/widgets/framework.dart:6162:5)
#798    _InheritedNotifierElement.update (package:flutter/src/widgets/inherited_notifier.dart:108:11)
#799    Element.updateChild (package:flutter/src/widgets/framework.dart:4050:15)
#800    ComponentElement.performRebuild (package:flutter/src/widgets/framework.dart:5854:16)
#801    StatefulElement.performRebuild (package:flutter/src/widgets/framework.dart:5995:11)
#802    Element.rebuild (package:flutter/src/widgets/framework.dart:5542:7)
#803    StatefulElement.update (package:flutter/src/widgets/framework.dart:6020:5)
#804    Element.updateChild (package:flutter/src/widgets/framework.dart:4050:15)
#805    ComponentElement.performRebuild (package:flutter/src/widgets/framework.dart:5854:16)
#806    StatefulElement.performRebuild (package:flutter/src/widgets/framework.dart:5995:11)
#807    Element.rebuild (package:flutter/src/widgets/framework.dart:5542:7)
#808    StatefulElement.update (package:flutter/src/widgets/framework.dart:6020:5)
#809    Element.updateChild (package:flutter/src/widgets/framework.dart:4050:15)
#810    ComponentElement.performRebuild (package:flutter/src/widgets/framework.dart:5854:16)
#811    Element.rebuild (package:flutter/src/widgets/framework.dart:5542:7)
#812    ProxyElement.update (package:flutter/src/widgets/framework.dart:6162:5)
#813    Element.updateChild (package:flutter/src/widgets/framework.dart:4050:15)
#814    ComponentElement.performRebuild (package:flutter/src/widgets/framework.dart:5854:16)
#815    StatefulElement.performRebuild (package:flutter/src/widgets/framework.dart:5995:11)
#816    Element.rebuild (package:flutter/src/widgets/framework.dart:5542:7)
#817    StatefulElement.update (package:flutter/src/widgets/framework.dart:6020:5)
#818    Element.updateChild (package:flutter/src/widgets/framework.dart:4050:15)
#819    ComponentElement.performRebuild (package:flutter/src/widgets/framework.dart:5854:16)
#820    Element.rebuild (package:flutter/src/widgets/framework.dart:5542:7)
#821    ProxyElement.update (package:flutter/src/widgets/framework.dart:6162:5)
#822    Element.updateChild (package:flutter/src/widgets/framework.dart:4050:15)
#823    ComponentElement.performRebuild (package:flutter/src/widgets/framework.dart:5854:16)
#824    Element.rebuild (package:flutter/src/widgets/framework.dart:5542:7)
#825    ProxyElement.update (package:flutter/src/widgets/framework.dart:6162:5)
#826    Element.updateChild (package:flutter/src/widgets/framework.dart:4050:15)
#827    _RawViewElement._updateChild (package:flutter/src/widgets/view.dart:488:16)
#828    _RawViewElement.update (package:flutter/src/widgets/view.dart:575:5)
#829    Element.updateChild (package:flutter/src/widgets/framework.dart:4050:15)
#830    ComponentElement.performRebuild (package:flutter/src/widgets/framework.dart:5854:16)
#831    Element.rebuild (package:flutter/src/widgets/framework.dart:5542:7)
#832    StatelessElement.update (package:flutter/src/widgets/framework.dart:5908:5)
#833    Element.updateChild (package:flutter/src/widgets/framework.dart:4050:15)
#834    ComponentElement.performRebuild (package:flutter/src/widgets/framework.dart:5854:16)
#835    StatefulElement.performRebuild (package:flutter/src/widgets/framework.dart:5995:11)
#836    Element.rebuild (package:flutter/src/widgets/framework.dart:5542:7)
#837    StatefulElement.update (package:flutter/src/widgets/framework.dart:6020:5)
#838    Element.updateChild (package:flutter/src/widgets/framework.dart:4050:15)
#839    RootElement._rebuild (package:flutter/src/widgets/binding.dart:2091:16)
#840    RootElement.update (package:flutter/src/widgets/binding.dart:2069:5)
#841    RootElement.performRebuild (package:flutter/src/widgets/binding.dart:2083:7)
#842    Element.rebuild (package:flutter/src/widgets/framework.dart:5542:7)
#843    BuildScope._tryRebuild (package:flutter/src/widgets/framework.dart:2763:15)
#844    BuildScope._flushDirtyElements (package:flutter/src/widgets/framework.dart:2820:11)
#845    BuildOwner.buildScope (package:flutter/src/widgets/framework.dart:3124:18)
#846    AutomatedTestWidgetsFlutterBinding.drawFrame (package:flutter_test/src/binding.dart:2432:19)
#847    RendererBinding._handlePersistentFrameCallback (package:flutter/src/rendering/binding.dart:558:5)
#848    SchedulerBinding._invokeFrameCallback (package:flutter/src/scheduler/binding.dart:1430:15)
#849    SchedulerBinding.handleDrawFrame (package:flutter/src/scheduler/binding.dart:1345:9)
#850    AutomatedTestWidgetsFlutterBinding.pump.<anonymous closure> (package:flutter_test/src/binding.dart:2261:9)
#853    TestAsyncUtils.guard (package:flutter_test/src/test_async_utils.dart:74:41)
#854    AutomatedTestWidgetsFlutterBinding.pump (package:flutter_test/src/binding.dart:2250:27)
#855    WidgetTester.pumpWidget.<anonymous closure> (package:flutter_test/src/widget_tester.dart:598:22)
#858    TestAsyncUtils.guard (package:flutter_test/src/test_async_utils.dart:74:41)
#859    WidgetTester.pumpWidget (package:flutter_test/src/widget_tester.dart:595:27)
#860    main.<anonymous closure> (file:///C:/Users/LENOVO/Documents/SEMESTER%205/PemMob/244107020059-mobile-course/03-week-3-navigation-state-management/week3_todo/test/widget_test.dart:9:18)
#861    testWidgets.<anonymous closure>.<anonymous closure> (package:flutter_test/src/widget_tester.dart:192:29)
<asynchronous suspension>
#862    TestWidgetsFlutterBinding._runTestBody (package:flutter_test/src/binding.dart:1953:5)
<asynchronous suspension>
<asynchronous suspension>
(elided 8 frames from dart:async and package:stack_trace)

══╡ EXCEPTION CAUGHT BY FLUTTER TEST FRAMEWORK ╞════════════════════════════════════════════════════
The following assertion was thrown running a test:
A Timer is still pending even after the widget tree was disposed.
'package:flutter_test/src/binding.dart':
Failed assertion: line 2543 pos 12: '!timersPending'

When the exception was thrown, this was the stack:
#2      AutomatedTestWidgetsFlutterBinding._verifyInvariants (package:flutter_test/src/binding.dart:2543:12)
#3      TestWidgetsFlutterBinding._runTestBody (package:flutter_test/src/binding.dart:1974:7)
<asynchronous suspension>
<asynchronous suspension>
(elided 3 frames from class _AssertionError and package:stack_trace)

The test description was:
  StatsPage dapat ditampilkan
════════════════════════════════════════════════════════════════════════════════════════════════════
00:05 +1 -1: C:/Users/LENOVO/Documents/SEMESTER 5/PemMob/244107020059-mobile-course/03-week-3-navigation-state-management/week3_todo/test/widget_test.dart: StatsPage dapat ditampilkan [E]
  Test failed. See exception logs above.
  The test description was: StatsPage dapat ditampilkan
  

To run this test again: C:\flutter\bin\cache\dart-sdk\bin\dart.exe test C:/Users/LENOVO/Documents/SEMESTER 5/PemMob/244107020059-mobile-course/03-week-3-navigation-state-management/week3_todo/test/widget_test.dart -p vm --plain-name "StatsPage dapat ditampilkan"
00:05 +1 -1: Some tests failed.                                                                              
PS C:\Users\LENOVO\Documents\SEMESTER 5\PemMob\244107020059-mobile-course\03-week-3-navigation-state-management\week3_todo> flutter test
00:05 +2: All tests passed!                                                                                  
PS C:\Users\LENOVO\Documents\SEMESTER 5\PemMob\244107020059-mobile-course\03-week-3-navigation-state-management\week3_todo> flutter analyze
Analyzing week3_todo...                                                 
No issues found! (ran in 5.8s)