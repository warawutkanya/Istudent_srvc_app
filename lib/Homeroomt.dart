import 'package:flutter/material.dart';

class Homeroomt extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        title: Text(
          'กิจกรรมโฮมรูม',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minWidth: constraints.maxWidth,
                ),
                child: DataTable(
                  columnSpacing: 25,
                  columns: const <DataColumn>[
                    DataColumn(
                      label: Expanded(
                        child: Text(
                          'วันที่เข้าโฮมรูม',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        'สถานะ',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                  rows: <DataRow>[
                    _buildDataRow('17 มิถุนายน 2567', 'มา'),
                    _buildDataRow('18 มิถุนายน 2567', 'มา'),
                    _buildDataRow('19 มิถุนายน 2567', 'ขาด'),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  DataRow _buildDataRow(String date, String status) {
    bool isAbsent = status == 'ขาด';
    TextStyle rowTextStyle = TextStyle(
      color: isAbsent ? Colors.red : Colors.black,
    );

    return DataRow(
      cells: <DataCell>[
        DataCell(Text(date, style: rowTextStyle)),
        DataCell(Text(status, style: rowTextStyle)),
      ],
    );
  }
}
