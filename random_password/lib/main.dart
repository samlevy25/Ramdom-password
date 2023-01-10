import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:math';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => MyAppState(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'namer_app',
        theme: ThemeData(
          useMaterial3: true,
          colorScheme:
              ColorScheme.fromSeed(seedColor: const Color.fromARGB(255, 19, 10, 61)),
        ),
        home: MyHomePage(),
      ),
    );
  }
}

class MyAppState extends ChangeNotifier {
  String password = "12345678";

  GlobalKey? historyListKey;

  var favorites = <String>[];

  var recycling = <String>[];

  var history = <String>[];

  String generatePassword() {
    const int length = 8;
    String characters =
        'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789!@#\$%^&*';
    String word = '';
    final random = Random();

    for (int i = 0; i < length; i++) {
      word += characters[random.nextInt(characters.length)];
    }
    return word;
  }

  void getNext() {
    history.insert(0, password);
    var animatedList = historyListKey?.currentState as AnimatedListState?;
    password = generatePassword();
    notifyListeners();
  }

  void toggleFavorite([String? r]) {
    favorites.contains(password)
        ? favorites.remove(password)
        : favorites.add(password);
    notifyListeners();
  }

  void toggleFavoriteFromList(String r) {
    if (recycling.contains(r)) {
      recycling.remove(r);
    }

    favorites.contains(r) ? favorites.remove(r) : favorites.add(r);

    notifyListeners();
  }

  void removeFavorite(String r) {
    favorites.remove(r);
    notifyListeners();
  }

  void toRecycling(String e) {
    recycling.contains(e) ? recycling.remove(e) : recycling.add(e);
    notifyListeners();
  }

  void recyclingWord(String f) {
    favorites.contains(f) ? favorites.remove(f) : favorites.add(f);
    recycling.remove(f);
    notifyListeners();
  }
}

class MyHomePage extends StatefulWidget {
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    var colorScheme = Theme.of(context).colorScheme;

    Widget page;
    switch (selectedIndex) {
      case 0:
        page = GeneratorPage();
        break;
      case 1:
        page = FavoritesPage();
        break;
      case 2:
        page = page = RecyclingPage();
        break;
      default:
        throw UnimplementedError('No Found Page !');
    }

    var mainArea = ColoredBox(
      color: colorScheme.surfaceVariant,
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 250),
        child: page,
      ),
    );

    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth < 450) {
            // Use a more mobile-friendly layout with BottomNavigationBar
            // on narrow screens.
            return Column(
              children: [
                Expanded(child: mainArea),
                SafeArea(
                  child: BottomNavigationBar(
                    items: [
                      BottomNavigationBarItem(
                        icon: Icon(Icons.home),
                        label: 'Home',
                      ),
                      BottomNavigationBarItem(
                        icon: Icon(Icons.favorite),
                        label: 'Favorites',
                      ),
                      BottomNavigationBarItem(
                          icon: Icon(Icons.recycling), label: 'Recycling')
                    ],
                    currentIndex: selectedIndex,
                    onTap: (value) {
                      setState(() {
                        selectedIndex = value;
                      });
                    },
                  ),
                )
              ],
            );
          } else {
            return Row(
              children: [
                SafeArea(
                  child: NavigationRail(
                    extended: constraints.maxWidth >= 600,
                    destinations: [
                      NavigationRailDestination(
                        icon: Icon(Icons.home),
                        label: Text('Home'),
                      ),
                      NavigationRailDestination(
                        icon: Icon(Icons.favorite),
                        label: Text('Favorites'),
                      ),
                      NavigationRailDestination(
                          icon: Icon(Icons.recycling), label: Text('Recycling'))
                    ],
                    selectedIndex: selectedIndex,
                    onDestinationSelected: (value) {
                      setState(() {
                        selectedIndex = value;
                      });
                    },
                  ),
                ),
                Expanded(child: mainArea),
              ],
            );
          }
        },
      ),
    );
  }
}

class GeneratorPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();

    var pair = appState.password;

    IconData icon = appState.favorites.contains(pair)
        ? Icons.favorite
        : Icons.favorite_border;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            flex: 3,
            child: HistoryListView(),
          ),
          SizedBox(height: 10),
          BigCard(pair: pair),
          SizedBox(height: 10),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              ElevatedButton.icon(
                onPressed: () {
                  print("object");
                  appState.toggleFavorite();
                },
                icon: Icon(icon),
                label: Text('Like'),
              ),
              SizedBox(width: 10),
              ElevatedButton(
                onPressed: () {
                  appState.getNext();
                },
                child: Text('Next'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class BigCard extends StatelessWidget {
  const BigCard({
    Key? key,
    required this.pair,
  }) : super(key: key);

  final String pair;

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    var style = theme.textTheme.displayMedium!.copyWith(
      color: theme.colorScheme.onPrimary,
    );

    return Card(
      color: theme.colorScheme.primary,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text(
          pair.toLowerCase(),
          style: style,
          semanticsLabel: pair,
        ),
      ),
    );
  }
}

class FavoritesPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    var appState = context.watch<MyAppState>();

    int number_ = appState.favorites.length;

    String numFavorites = number_ == 1
        ? 'You have 1 favorite password :'
        : 'You have ${number_.toString()} favorites passwords :';

    String infoFavorites = number_ == 0 ? 'No favorites yet.' : numFavorites;

    if (appState.favorites.isEmpty) {
      return Center(
        child: Text(infoFavorites),
      );
    }

    return ListView(
      children: [
        Padding(
          padding: const EdgeInsets.all(30),
          child: Text(infoFavorites),
        ),
        for (var pair in appState.favorites)
          ListTile(
            leading: Icon(Icons.favorite),
            title: Text(pair.toLowerCase()),
            trailing: IconButton(
              icon: Icon(
                Icons.delete,
                color: theme.colorScheme.primary,
              ),
              onPressed: () {
                appState.toRecycling(pair);
                appState.removeFavorite(pair);
              },
            ),
            contentPadding:
                EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          ),
      ],
    );
  }
}

class RecyclingPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    var appState = context.watch<MyAppState>();

    int number_ = appState.recycling.length;

    String numRecycling = number_ == 1
        ? 'You have the possibility to recycle 1 word :'
        : 'You have the possibility to recycle ${number_.toString()} words :';

    String infoRecycling =
        number_ == 0 ? 'There is nothing to recycle.' : numRecycling;

    if (appState.recycling.isEmpty) {
      return Center(
        child: Text(infoRecycling),
      );
    }

    return ListView(
      children: [
        Padding(
          padding: const EdgeInsets.all(20),
          child: Text(infoRecycling),
        ),
        for (var pair in appState.recycling)
          ListTile(
            leading: IconButton(
              icon: Icon(Icons.recycling, color: theme.colorScheme.primary),
              onPressed: () {
                appState.recyclingWord(pair);
              },
            ),
            title: Text(pair.toLowerCase()),
            contentPadding:
                EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          ),
      ],
    );
  }
}

class HistoryListView extends StatefulWidget {
  const HistoryListView({Key? key}) : super(key: key);

  @override
  State<HistoryListView> createState() => _HistoryListViewState();
}

class _HistoryListViewState extends State<HistoryListView> {
  final _key = GlobalKey();

  static const Gradient _maskingGradient = LinearGradient(
    colors: [Colors.transparent, Colors.black],
    stops: [0.0, 0.5],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<MyAppState>();

    appState.historyListKey = _key;

    return ShaderMask(
      shaderCallback: (bounds) => _maskingGradient.createShader(bounds),
      blendMode: BlendMode.dstIn,
      child: AnimatedList(
        key: _key,
        reverse: true,
        padding: EdgeInsets.only(top: 100),
        initialItemCount: appState.history.length,
        itemBuilder: (context, index, animation) {
          final pair = appState.history[index];
          return SizeTransition(
            sizeFactor: animation,
            child: Center(
              child: TextButton.icon(
                onPressed: () {
                  appState.toggleFavoriteFromList(pair);
                },
                icon: appState.favorites.contains(pair)
                    ? Icon(Icons.favorite, size: 12)
                    : SizedBox(),
                label: Text(
                  pair.toLowerCase(),
                  semanticsLabel: pair,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
