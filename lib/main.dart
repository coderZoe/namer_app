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
            home: const MyHomePage()));
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

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  var selectedIndex = 0;
  @override
  Widget build(BuildContext context) {
    Widget page;
    switch (selectedIndex) {
      case 0:
        page = const GeneratorPage();
        break;
      case 1:
        page = const FavoritesPage();
        break;
      default:
        throw UnimplementedError('no widget for $selectedIndex');
    }
    return LayoutBuilder(builder: (context, constraints) {
      return Scaffold(
        body: Row(
          children: [
            //这是导航的widget
            //SafeArea 将确保其子项不会被硬件凹口或状态栏遮挡
            SafeArea(
              child: NavigationRail(
                extended: constraints.maxWidth >= 600,
                destinations: const [
                  NavigationRailDestination(
                    icon: Icon(Icons.home),
                    label: Text('Home'),
                  ),
                  NavigationRailDestination(
                    icon: Icon(Icons.favorite),
                    label: Text('Favorites'),
                  ),
                ],
                selectedIndex: selectedIndex,
                onDestinationSelected: (value) {
                  //这是个方法调用，在这个方法调用中更新selectedIndex的值
                  //为什么要这样写？这涉及到flutter的状态变更重绘UI机制
                  //只有使用setState更新变量才会重绘UI
                  //这有些类似于vue下的reactive和ref包装对象，只有这样改数据，UI才会变化
                  setState(() {
                    selectedIndex = value;
                  });
                },
              ),
            ),
            //展开的 widget 在行和列中极具实用性 — 它们可用于呈现以下布局：一些子项仅占用其所需要的空间（在本例中为 NavigationRail），而其他 widget 则尽可能多地占用其余空间（在本例中为 Expanded）。可以将 Expanded widget 视为一种“贪婪的”元素。如果您想要更好地感受此 widget 的作用
            Expanded(
              //这是我们原来的widget
              child: Container(
                color: Theme.of(context).colorScheme.primaryContainer,
                child: page,
              ),
            ),
          ],
        ),
      );
    });
  }
}

class GeneratorPage extends StatelessWidget {
  const GeneratorPage({super.key});

  ///widget中的build方法用于每当widget的环境发生变化时，系统会自动调用当前方法，以便widget能及时响应处理，保持自己为最新状态
  @override
  Widget build(BuildContext context) {
    //使用watch跟踪当前APP状态的变更
    var appState = context.watch<MyAppState>();
    var wordPair = appState.current;
    var icon = appState.favorites.contains(wordPair)
        ? Icons.favorite
        : Icons.favorite_border;

    return Center(
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
                  onPressed: appState.getNext, child: const Text('Next')),
            ],
          )
        ],
      ),
    );
  }
}

class FavoritesPage extends StatelessWidget {
  const FavoritesPage({super.key});

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    var favorites = appState.favorites;
    if (favorites.isEmpty) {
      return const Center(child: Text('No favorites yet.'));
    }
    return FavoriteView(favorites: favorites);
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

class FavoriteView extends StatelessWidget {
  final List<WordPair> favorites;
  const FavoriteView({super.key, required this.favorites});

  @override
  Widget build(BuildContext context) {
    // return Column(
    //     mainAxisAlignment: MainAxisAlignment.center,
    //     children: favorites.map((p) => p.asLowerCase)
    //     .map(Text.new)
    //     .toList());
    //使用ListView 其中children内是这个widget的子组件
    return ListView(
      children: [
        //第一个子组件我们用了一个Padding组件
        //但在这个Padding里面还是加了一个Text 作为一开始的说明
        Padding(
            padding: const EdgeInsets.all(20),
            child: Text('You have ${favorites.length} favorites:')),
        //这里使用解构和spread
        ...favorites.map((p) => p.asLowerCase).map((p) =>
            ListTile(leading: const Icon(Icons.favorite), title: Text(p))),
      ],
    );
  }
}
