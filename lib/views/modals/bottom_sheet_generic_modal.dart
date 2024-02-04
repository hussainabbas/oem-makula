import 'package:flutter/material.dart';
import 'package:makula_oem/helper/utils/colors.dart';
import 'package:makula_oem/helper/utils/context_function.dart';

import '../widgets/makula_text_view.dart';

class BottomSheetGenericModal<T> {
  static void show<T>(
      BuildContext context,
      String title,
      List<T>? list,
      T? selectedItem,
      String Function(T?) getName,
      Function(T?) onSelect,
      ) {
    final TextEditingController searchController = TextEditingController();

    showModalBottomSheet(
      barrierLabel: title,
      barrierColor: Colors.black.withOpacity(0.5),
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        List<T>? filteredList = list;

        return StatefulBuilder(
            builder: (context, setState) {
            return SingleChildScrollView(

              child: Container(
                color: Colors.white,
                padding: const EdgeInsets.only(top: 16, bottom: 16),
                child: Column(
                  children: [
                    TextView(
                      text: title,
                      textColor: primaryColor,
                      textFontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                    const Divider(
                      color: Colors.grey,
                      height: 24,
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextField(
                        controller: searchController,
                        decoration: const InputDecoration(
                          hintText: 'Search...',
                          prefixIcon: Icon(Icons.search),
                        ),
                        onChanged: (query) {
                          // Filter the list based on the search query
                          if (query.isNotEmpty) {
                            filteredList = list
                                ?.where((item) =>
                                getName(item)
                                    .toLowerCase()
                                    .contains(query.toLowerCase()))
                                .toList();
                          } else {
                            filteredList = list;
                          }
                          setState((){});
                        },
                      ),
                    ),
                    SizedBox(
                      height: context.fullHeight(multiplier: 0.7 ),
                      child: ListView.builder(
                        itemCount: filteredList?.length,
                        itemBuilder: (context, index) {
                          final item = filteredList?[index];
                          return ListTile(
                            onTap: () async {
                              onSelect(filteredList?[index]);
                              Navigator.pop(context);
                            },
                            title: Text(getName(item)),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            );
          }
        );
      },
    );
  }
}