import 'package:flutter/material.dart';

class ColorsModal extends StatefulWidget {
  const ColorsModal(
      {Key? key,
      required this.colors,
      required this.selectedColor,
      this.action})
      : super(key: key);
  final List<int> colors;
  final int? selectedColor;
  final VoidCallback? action;

  @override
  ColorsModalState createState() => ColorsModalState();
}

class ColorsModalState extends State<ColorsModal> {
  ColorsModalState({Key? key});
  int? selectedColor;

  @override
  void initState() {
    selectedColor = widget.selectedColor;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      const Padding(
          padding: EdgeInsets.only(bottom: 20, top: 20),
          child: Text(
            'Pick a color',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          )),
      Expanded(
          flex: 3,
          child: GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
            ),
            itemCount: widget.colors.length,
            itemBuilder: (context, index) {
              return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedColor = widget.colors[index];
                          (widget.action)!();
                        });
                      },
                      child: Container(
                        width: 20,
                        height: 20,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Color(widget.colors[index]),
                        ),
                        child: widget.colors[index] == selectedColor
                            ? const Center(
                                child: Icon(
                                Icons.check,
                                color: Colors.black,
                              ))
                            : null,
                      )));
            },
          ))
    ]);
  }
}
