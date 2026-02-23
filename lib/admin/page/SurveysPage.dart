import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:survey_samdu/admin/page/QuestionsPage.dart';
import 'package:survey_samdu/admin/provider/SurveysProvider.dart';
import 'package:survey_samdu/models/users_model.dart';

import '../../models/surveys_model.dart';
import '../widgets/SurveyDialogWidget.dart';

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
      Provider.of<SurveysProvider>(context, listen: false)
        ..getSurveys()
        ..getUsers();
    });
  }

  void showSurveyDialog(
    BuildContext context, {
    SurveyData? data,
    Function(SurveyData)? onSave,
    UsersModel? owners,
  }) {
    showDialog(
      context: context,
      builder: (context) =>
          SurveyDialogWidget(data: data, onSave: onSave, owners: owners),
    );
  }

  @override
  Widget build(BuildContext context) {
    var provider = Provider.of<SurveysProvider>(context, listen: true);

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        backgroundColor: Colors.blue.shade700,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          "So'rovnomalar",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 2,
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blue.shade700,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
        ),
        elevation: 4,
        child: const Icon(Icons.add, color: Colors.white),
        onPressed: () {
          if (!provider.isLoading) {
            showSurveyDialog(
              context,
              owners: provider.usersModel,
              onSave: (SurveyData data) async {
                await provider.createSurvey(data);
              },
            );
          }
        },
      ),
      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
              itemCount: provider.surveysModel.dataListList!.length,
              itemBuilder: (context, index) {
                var item = provider.surveysModel.dataListList![index];

                return Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 3,
                  margin: const EdgeInsets.symmetric(
                    vertical: 6,
                    horizontal: 5,
                  ),
                  child: ListTile(
                    onTap: () {
                      print(item.id);
                      print(item.title);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (builder) => QuestionsPage(data: item),
                        ),
                      );
                    },
                    tileColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 12,
                      horizontal: 16,
                    ),
                    title: Text(
                      item.title ?? '',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.black87,
                      ),
                    ),
                    subtitle: Text(
                      item.description ?? '',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade700,
                      ),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          onPressed: () {
                            showSurveyDialog(
                              context,
                              data: item,
                              owners: provider.usersModel,
                              onSave: (SurveyData data) async {
                                if (!provider.isLoading) {
                                  await provider.updateSurvey(data);
                                }
                              },
                            );
                          },
                          icon: const Icon(Icons.edit, color: Colors.blue),
                        ),
                        IconButton(
                          onPressed: () async {
                            if (!provider.isLoading) {
                              await provider.deleteSurvey(item);
                            }
                          },
                          icon: const Icon(Icons.delete, color: Colors.red),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
