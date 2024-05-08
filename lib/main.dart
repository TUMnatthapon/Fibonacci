import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Fibonacci Test',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const Fibonacci(title: 'Fibonacci Test'),
    );
  }
}

class Fibonacci extends StatefulWidget {
  const Fibonacci({super.key, required this.title});

  final String title;

  @override
  State<Fibonacci> createState() => _FibonacciState();
}

class _FibonacciState extends State<Fibonacci> {
  int? actionIndex;
  double itemHeight = 50.0;
  List<int> fibonacciList = [];
  Map<int, int> modalData = {};
  ScrollController scrollController = ScrollController();
  ScrollController modalScrollController = ScrollController();
  List<IconData> iconList = [
    Icons.circle,
    Icons.square_outlined,
    Icons.close,
  ];

  void generateFibonacci(int number) {
    fibonacciList.clear();
    for (int i = 0; i < number; i++) {
      if (i == 0 || i == 1) {
        fibonacciList.add(i);
      } else {
        fibonacciList.add(fibonacciList[i - 1] + fibonacciList[i - 2]);
      }
    }
  }

  void setModalData(int index) async {
    actionIndex = index;
    modalData[index] = fibonacciList[index];
    final sortedKeys = modalData.keys.toList()..sort();

    Map<int, int> sortedMap = {};
    int countUnshow = 0;

    for (final key in sortedKeys) {
      sortedMap[key] = modalData[key]!;
      if (modalData[key]! % 3 != fibonacciList[index] % 3) countUnshow++;
    }

    modalData.clear();
    modalData.addAll(sortedMap);
    setState(() {});

    Future.delayed(const Duration(milliseconds: 100), () {
      modalScrollController.animateTo(
        (double.parse('$actionIndex') - countUnshow) * itemHeight,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  void initState() {
    super.initState();
    generateFibonacci(41);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: ListView.builder(
        controller: scrollController,
        itemCount: fibonacciList.length,
        itemBuilder: (context, index) {
          final textColor = actionIndex == index ? Colors.white : Colors.black;
          final groupIndex = fibonacciList[index] % 3;
          if (modalData.containsKey(index)) return Container();
          return InkWell(
            onTap: () async {
              setModalData(index);
              bottomSheetMethod(context: context, groupIndex: groupIndex).then((value) {
                if (value != null) {
                  modalData.remove(value);
                  actionIndex = value;
                  setState(() {});

                  scrollController.animateTo(
                    (double.parse('$actionIndex') - modalData.length) * itemHeight,
                    duration: const Duration(milliseconds: 500),
                    curve: Curves.easeInOut,
                  );
                }
              });
            },
            child: Container(
              color: actionIndex == index ? Colors.red : Colors.white,
              height: itemHeight,
              child: ListTile(
                title: Text(
                  'Index $index, Number : ${fibonacciList[index]}',
                  style: TextStyle(color: textColor),
                ),
                trailing: Icon(
                  iconList[groupIndex],
                  color: textColor,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Future<dynamic> bottomSheetMethod({required BuildContext context, required int groupIndex}) {
    return showModalBottomSheet(
      context: context,
      builder: (context) => ClipRRect(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20.0),
          topRight: Radius.circular(20.0),
        ),
        child: Container(
          color: Colors.white,
          width: double.infinity,
          height: MediaQuery.of(context).size.height * 0.5,
          child: ListView.builder(
              controller: modalScrollController,
              itemCount: modalData.length,
              itemBuilder: (context, xIndex) {
                final key = modalData.keys.elementAt(xIndex);
                final value = modalData[key]!;
                final textColor = actionIndex == key ? Colors.white : Colors.black;
                if (!(groupIndex == (value % 3))) return Container();
                return InkWell(
                  onTap: () => Navigator.pop(context, key),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12.0),
                    color: actionIndex == key ? Colors.green : Colors.white,
                    height: itemHeight,
                    child: Row(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          mainAxisSize: MainAxisSize.max,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Number : $value',
                              style: TextStyle(color: textColor),
                            ),
                            Text('Index : $key', style: TextStyle(color: textColor)),
                          ],
                        ),
                        Icon(
                          iconList[groupIndex],
                          color: textColor,
                        ),
                      ],
                    ),
                  ),
                );
              }),
        ),
      ),
    );
  }
}
