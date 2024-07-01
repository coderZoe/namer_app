import 'package:english_words/english_words.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  //告诉flutter运行 MyApp中定义的程序
  runApp(const MyApp());
}

//在构建每一个Flutter应用时，widget都是一个基本要素
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    ///使用 ChangeNotifierProvider 创建状态并将其提供给整个应用（参见上面 MyApp 中的代码）。这样一来，应用中的任何 widget 都可以获取状态。
    return ChangeNotifierProvider(
        create: (context) => MyAppState(),
        child: MaterialApp(
            title: "Namer App",
            theme: ThemeData(
                useMaterial3: true,
                colorScheme:
                    ColorScheme.fromSeed(seedColor: Colors.deepOrange)),
            home: MyHomePage()));
  }
}

///MyAppState定义了应用程序的状态，所谓状态就是我们理解的应用程序运行中的所需的一些数据
///比如我们当前的程序只需要一个随机的单词对
///扩展自自ChangeNotifier的类，意味着它可以通知其他人自己的更改，例如当当前当前单词对发生变化时，应用中的某些widget需要感知到这种变化
class MyAppState extends ChangeNotifier {
  var current = WordPair.random();
  //用户喜欢的内容集合
  var favorites = <WordPair>[];

  //提供getNext方法，用于获取下一对单词，通过notifyListeners方法,以确保向任何通过 watch 方法跟踪 MyAppState 的对象发出通知。
  void getNext() {
    current = WordPair.random();
    notifyListeners();
  }

  void toggleFavorite() {
    if (favorites.contains(current)) {
      favorites.remove(current);
    } else {
      favorites.add(current);
    }
    notifyListeners();
  }
}

class MyHomePage extends StatelessWidget {
  ///widget中的build方法用于每当widget的环境发生变化时，系统会自动调用当前方法，以便widget能及时响应处理，保持自己为最新状态
  @override
  Widget build(BuildContext context) {
    //使用watch跟踪当前APP状态的变更
    var appState = context.watch<MyAppState>();
    var wordPair = appState.current;
    var icon = appState.favorites.contains(wordPair)
        ? Icons.favorite
        : Icons.favorite_border;

    return Scaffold(
      //column是一种布局，它接收任意数量的children，并将这些children从上到下排列在一列中
      //其中children的每个元素都是一个widget
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Text('A random AWESOME idea:'),
            BigCard(wordPair: wordPair),
            //两个组件之间增加间隔的
            const SizedBox(height: 10),
            //添加一个按钮，其中onPressed是点击事件，而child是按钮的文本
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                ElevatedButton.icon(
                    onPressed: appState.toggleFavorite,
                    icon: Icon(icon),
                    label: const Text('like')),
                ElevatedButton(
                    onPressed: appState.getNext, child: Text('Next')),
              ],
            )
          ],
        ),
      ),
    );
  }
}

class BigCard extends StatelessWidget {
  const BigCard({
    super.key,
    required this.wordPair,
  });

  final WordPair wordPair;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    //访问字体主题displayMedium是展示大号文本
    //调用copyWith返回一个副本，将原来的文本颜色主题保存
    final style = theme.textTheme.displayMedium!.copyWith(
      color: theme.colorScheme.onPrimary,
    );
    return Card(
      color: theme.colorScheme.primary,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Text(
          wordPair.asLowerCase,
          style: style,
          //用于无障碍功能,展示给屏幕阅读器的
          semanticsLabel: "${wordPair.first} ${wordPair.second}",
        ),
      ),
    );
  }
}
