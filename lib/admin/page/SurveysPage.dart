import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:survey_samdu/admin/provider/SurveysProvider.dart';

class SurveysPage extends StatefulWidget {
  const SurveysPage({super.key});

  @override
  State<SurveysPage> createState() => _SurveysPageState();
}

class _SurveysPageState extends State<SurveysPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<SurveysProvider>(context, listen: false).getSurveys();
    });
  }

  @override
  Widget build(BuildContext context) {
    var provider = Provider.of<SurveysProvider>(context, listen: true);

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        backgroundColor: Colors.blue,
        iconTheme: IconThemeData(color: Colors.white),
        title: const Text(
          "So'rovnomalar",
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blue,
        shape: OvalBorder(),
        child: Icon(Icons.add, color: Colors.white),
        onPressed: () {},
      ),
      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: provider.surveysModel.dataListList!.length,
              itemBuilder: (context, index) {
                var item = provider.surveysModel.dataListList![index];

                return Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 8.0,
                    horizontal: 10,
                  ),
                  child: ListTile(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    tileColor: Colors.white,
                    title: Text(item.title!,
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold
                    ),),
                    subtitle: Text(item.description!),
                    trailing: SizedBox(
                      width: 80,
                      child: Row(
                        children: [
                          IconButton(

                            onPressed: () {},
                            icon: const Icon(Icons.edit,color: Colors.blue,),
                          ),
                          IconButton(
                            onPressed: () {},
                            icon: const Icon(Icons.delete,color: Colors.red,),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
