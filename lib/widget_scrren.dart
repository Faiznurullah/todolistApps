import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'db.dart';

class WidgetScreen extends StatefulWidget {
  @override
  State<WidgetScreen> createState() => _WidgetScreenState();
}

class _WidgetScreenState extends State<WidgetScreen> {
  List<Map<String, dynamic>> _allData = [];

  bool _isLoading = true;

  void _refreshData() async {
    final data = await SQLHelper.getAllData();
    setState(() {
      _allData = data;
      _isLoading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    _refreshData();
  }

  Future<void> _addData() async {
    await SQLHelper.createData(_titlecontroller.text, _desccontroller.text);
    _refreshData();
  }

  Future<void> _updateData(int id) async {
    await SQLHelper.updateData(id, _titlecontroller.text, _desccontroller.text);
    _refreshData();
  }

  void _deleteData(int id) async {
    await SQLHelper.deleteData(id);
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      backgroundColor: Colors.red,
      content: Text('Data sudah dihapus'),
    ));
    _refreshData();
  }

  final TextEditingController _titlecontroller = TextEditingController();
  final TextEditingController _desccontroller = TextEditingController();

  void showModalBottomSheetWrapper(int? id) async {
    if (id != null) {
      final existingData =
          _allData.firstWhere((element) => element['id'] == id);
      _titlecontroller.text = existingData['title'];
      _desccontroller.text = existingData['desc'];
    }

    showModalBottomSheet(
      elevation: 5,
      isScrollControlled: true,
      context: context,
      builder: (_) => Container(
        padding: EdgeInsets.only(
          left: 15,
          right: 15,
          top: 30,
          bottom: MediaQuery.of(context).viewInsets.bottom + 50,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            TextField(
              controller: _titlecontroller,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                hintText: "Title",
              ),
            ),
            SizedBox(
              height: 15,
            ),
            TextField(
              controller: _desccontroller,
              maxLines: 4,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                hintText: "Description",
              ),
            ),
            SizedBox(
              height: 15,
            ),
            Center(
              child: ElevatedButton(
                onPressed: () async {
                  if (id == null) {
                    await _addData();
                  }

                  if (id != null) {
                    await _updateData(id);
                  }

                  _titlecontroller.text = "";
                  _desccontroller.text = "";

                  Navigator.of(context).pop();
                },
                child: Center(
                    child: Text(id == null ? "Add data" : "Update data")),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Todo List'),
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : ListView.builder(
              itemCount: _allData.length,
              itemBuilder: ((context, index) => Card(
                    margin: EdgeInsets.all(15),
                    child: ListTile(
                      title: Padding(
                        padding: EdgeInsets.symmetric(
                          vertical: 5,
                        ),
                        child: Text(_allData[index]['title']),
                      ),
                      subtitle: Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: 5,
                        ),
                        child: Text(_allData[index]['desc']),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            onPressed: () {
                              showModalBottomSheetWrapper(
                                  _allData[index]['id']);
                            },
                            icon: Icon(
                              Icons.edit,
                              color: Colors.blueAccent,
                            ),
                          ),
                          SizedBox(
                            width: 10,
                          ),
                          IconButton(
                            onPressed: () {
                              _deleteData(_allData[index]['id']);
                            },
                            icon: Icon(
                              Icons.delete,
                              color: Colors.redAccent,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => showModalBottomSheetWrapper(null),
        child: Icon(Icons.add),
      ),
    );
  }
}
