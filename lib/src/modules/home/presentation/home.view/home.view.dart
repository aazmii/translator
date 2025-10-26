import 'package:flutter/material.dart';

import 'components/language.selector/language.selector.tile.dart';
import 'components/source.card/souce.card.dart';
import 'components/target.card/target.card.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: HomeAppbar(),
      drawer: Drawer(),
      resizeToAvoidBottomInset: false,
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Expanded(child: SourceCard()),
            SizedBox(height: 8),
            Expanded(child: TargetCard()),
          ],
        ),
      ),
    );
  }
}

// class HomeView extends StatelessWidget {
//   const HomeView({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('Home')),
//       body: Center(
//         child: ElevatedButton(
//           onPressed: () async => await fadePush(context, const SettingView()),
//           child: Text(t!.setting),
//         ),
//       ),
//     );
//   }
// }
