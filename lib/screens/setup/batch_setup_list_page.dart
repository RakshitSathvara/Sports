// ignore_for_file: use_build_context_synchronously

import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:oqdo_mobile_app/components/custom_app_bar.dart';
import 'package:oqdo_mobile_app/model/CoachDetailsResponseModel.dart';
import 'package:oqdo_mobile_app/model/GetCoachBySetupIDModel.dart';
import 'package:oqdo_mobile_app/model/calendar_view_model.dart';
import 'package:oqdo_mobile_app/model/get_coach_batch_model/datum.dart';
import 'package:oqdo_mobile_app/utils/colorsUtils.dart';
import 'package:oqdo_mobile_app/utils/constants.dart';
import 'package:oqdo_mobile_app/utils/custom_text_view.dart';
import 'package:oqdo_mobile_app/utils/network_interceptor.dart';
import 'package:progress_dialog_null_safe/progress_dialog_null_safe.dart';
import 'package:provider/provider.dart';

import '../../model/get_coach_batch_model/get_coach_batch_model.dart';
import '../../oqdo_application.dart';
import '../../viewmodels/service_provider_setup_viewmodel.dart';

class BatchSetupListPage extends StatefulWidget {
  const BatchSetupListPage({super.key});

  @override
  BatchSetupListPageState createState() => BatchSetupListPageState();
}

class BatchSetupListPageState extends State<BatchSetupListPage> {
  final scaffoldKey = GlobalKey<ScaffoldState>();
  List<Datum> coachBatchList = [];
  late ProgressDialog _progressDialog;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      getCoachBatchList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      appBar: CustomAppBar(
        title: 'Batch Setup',
        onBack: () {
          Navigator.pop(context);
        },
      ),
      floatingActionButton: FloatingActionButton(
        // isExtended: true,
        backgroundColor: ColorsUtils.greyButton,
        onPressed: () async {
          await Navigator.pushNamed(context, Constants.ADDBATCHSETUPPAGE).then((value) {
            if (value != null) {
              Future.delayed(const Duration(milliseconds: 200), () {
                getCoachBatchList();
              });
            }
          });
        },
        // isExtended: true,
        child: Icon(
          Icons.add_rounded,
          size: 50,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
      body: SafeArea(
        child: Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          color: Theme.of(context).colorScheme.onBackground,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(
                height: 8,
              ),
              Expanded(
                child: coachBatchList.isNotEmpty
                    ? ListView.separated(
                        shrinkWrap: true,
                        scrollDirection: Axis.vertical,
                        itemCount: coachBatchList.length,
                        separatorBuilder: (context, index) {
                          return const Divider();
                        },
                        itemBuilder: (BuildContext context, int index) {
                          return Padding(
                            padding: const EdgeInsets.fromLTRB(20, 0, 10, 10),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Flexible(
                                  flex: 1,
                                  fit: FlexFit.tight,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      CustomTextView(
                                        label: coachBatchList[index].name,
                                        textOverFlow: TextOverflow.ellipsis,
                                        maxLine: 2,
                                        type: styleSubTitle,
                                        textStyle: Theme.of(context).textTheme.bodyMedium!.copyWith(
                                              color: Theme.of(context).colorScheme.onSurface,
                                            ),
                                      ),
                                      const SizedBox(
                                        height: 7,
                                      ),
                                      GestureDetector(
                                        onTap: () {
                                          getCoachBatchDetailsById(coachBatchList[index].coachBatchSetupId);
                                        },
                                        child: CustomTextView(
                                          label: 'Details',
                                          type: styleSubTitle,
                                          textStyle: Theme.of(context).textTheme.bodyMedium!.copyWith(
                                                color: Theme.of(context).colorScheme.shadow,
                                                fontWeight: FontWeight.w300,
                                                fontSize: 14,
                                                decoration: TextDecoration.underline,
                                              ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Row(
                                  children: [
                                    IconButton(
                                      onPressed: () async {
                                        CalendarViewModel calendarViewModel = CalendarViewModel();
                                        calendarViewModel.coachBatchSetupId = coachBatchList[index].coachBatchSetupId;
                                        calendarViewModel.selectedDateTime = DateTime.now();
                                        await Navigator.of(context).pushNamed(Constants.coachBatchCancelSlotScreen, arguments: calendarViewModel);
                                      },
                                      icon: ImageIcon(
                                        const AssetImage("assets/images/ic_cancel.png"),
                                        color: Theme.of(context).colorScheme.onSurface,
                                      ),
                                    ),
                                    IconButton(
                                      onPressed: () async {
                                        debugPrint(coachBatchList[index].coachBatchSetupId.toString());
                                        getCoachBatchBySetupId(coachBatchList[index].coachBatchSetupId!);
                                      },
                                      icon: ImageIcon(
                                        const AssetImage("assets/images/ic_edit.png"),
                                        color: Theme.of(context).colorScheme.onSurface,
                                      ),
                                    ),
                                    IconButton(
                                      onPressed: () {
                                        _showAlertDialog(context, coachBatchList[index]);
                                      },
                                      icon: ImageIcon(
                                        const AssetImage("assets/images/ic_delete.png"),
                                        color: Theme.of(context).colorScheme.onSurface,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          );
                        })
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Image.asset(
                            'assets/images/ic_setup_empty.png',
                            width: 400,
                            height: 400,
                          ),
                          SizedBox(
                              width: double.infinity,
                              child: Center(
                                child: RichText(
                                  textAlign: TextAlign.center,
                                  text: TextSpan(
                                    style: Theme.of(context).textTheme.bodyMedium,
                                    children: [
                                      const TextSpan(text: 'There is nothing to show,\nadd Batch from '),
                                      WidgetSpan(
                                        alignment: PlaceholderAlignment.middle,
                                        child: Icon(
                                          Icons.add_rounded,
                                          size: 25,
                                          color: Theme.of(context).colorScheme.primary,
                                        ),
                                      ),
                                      const TextSpan(text: ' icon below.'),
                                    ],
                                  ),
                                ),
                              )),
                        ],
                      ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20.0, 0, 0, 18),
                child: ElevatedButton(
                  onPressed: () async {
                    await Navigator.pushNamed(context, Constants.coachVacationListScreen);
                  },
                  // icon: Icon(
                  //   Icons.add_rounded,
                  //   color: Theme.of(context).colorScheme.primary,
                  // ),
                  style: ButtonStyle(
                    foregroundColor: MaterialStateProperty.all<Color>(
                      Theme.of(context).colorScheme.onBackground,
                    ),
                    backgroundColor: MaterialStateProperty.all<Color>(
                      ColorsUtils.greyButton,
                    ),
                  ),
                  child: Text(
                    "Vacation",
                    style: TextStyle(color: Theme.of(context).colorScheme.primary),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  void getCoachBatchList() async {
    _progressDialog = ProgressDialog(context, type: ProgressDialogType.normal, isDismissible: false);
    _progressDialog.style(message: "Please wait..");
    if (_progressDialog.isShowing()) {
      await _progressDialog.hide();
    }
    try {
      await _progressDialog.show();
      GetCoachBatchModel facilityListResponseModel =
          await Provider.of<ServiceProviderSetupViewModel>(context, listen: false).getCoachBatchList(OQDOApplication.instance.coachID!);
      await _progressDialog.hide();
      setState(() {});
      coachBatchList = facilityListResponseModel.data!;
      debugPrint(facilityListResponseModel.data!.toString());
    } on CommonException catch (commonError) {
      await _progressDialog.hide();
      debugPrint(commonError.toString());
      if (commonError.code == 400) {
        Map<String, dynamic> errorModel = jsonDecode(commonError.message);
        if (errorModel.containsKey('ModelState')) {
          Map<String, dynamic> modelState = errorModel['ModelState'];
          if (modelState.containsKey('ErrorMessage')) {
            showSnackBarColor(modelState['ErrorMessage'][0], context, true);
          } else {
            showSnackBarColor('We\'re unable to connect to server. Please contact administrator or try after some time', context, true);
          }
        } else {
          showSnackBarColor('We\'re unable to connect to server. Please contact administrator or try after some time', context, true);
        }
      } else {
        showSnackBarColor('We\'re unable to connect to server. Please contact administrator or try after some time', context, true);
      }
    } on NoConnectivityException catch (_) {
      await _progressDialog.hide();
      showSnackBarColor(Constants.internetConnectionErrorMsg, context, true);
    } catch (error) {
      await _progressDialog.hide();
      debugPrint(error.toString());
      showSnackBarErrorColor('We\'re unable to connect to server. Please contact administrator or try after some time', context, true);
    }
  }

  Future<void> getCoachBatchBySetupId(int batchID) async {
    try {
      _progressDialog = ProgressDialog(context, type: ProgressDialogType.normal, isDismissible: false);
      _progressDialog.style(message: "Please wait..");
      await _progressDialog.show();
      GetCoachBySetupIdModel getCoachBySetupIdModel = await Provider.of<ServiceProviderSetupViewModel>(context, listen: false).getBatchByID(batchID);
      await _progressDialog.hide();
      debugPrint(getCoachBySetupIdModel.name);
      await Navigator.of(context).pushNamed(Constants.editBatchSetup, arguments: getCoachBySetupIdModel).then((value) {
        if (value != null) {
          Future.delayed(const Duration(milliseconds: 200), () {
            getCoachBatchList();
          });
        }
      });
    } on CommonException catch (error) {
      await _progressDialog.hide();
      debugPrint(error.toString());
      if (error.code == 400) {
        Map<String, dynamic> errorModel = jsonDecode(error.message);
        if (errorModel.containsKey('ModelState')) {
          Map<String, dynamic> modelState = errorModel['ModelState'];
          if (modelState.containsKey('ErrorMessage')) {
            showSnackBarColor(modelState['ErrorMessage'][0], context, true);
          } else {
            showSnackBarColor('We\'re unable to connect to server. Please contact administrator or try after some time', context, true);
          }
        } else {
          showSnackBarColor('We\'re unable to connect to server. Please contact administrator or try after some time', context, true);
        }
      } else {
        showSnackBarColor('We\'re unable to connect to server. Please contact administrator or try after some time', context, true);
      }
    } on NoConnectivityException catch (_) {
      await _progressDialog.hide();
      showSnackBarColor(Constants.internetConnectionErrorMsg, context, true);
    } catch (error) {
      await _progressDialog.hide();
      debugPrint(error.toString());
      // showSnackBarErrorColor('We\'re unable to connect to server. Please contact administrator or try after some time', context, true);
    }
  }

  void _showAlertDialog(BuildContext context, Datum batchModel) {
    showCupertinoModalPopup<void>(
      context: context,
      builder: (BuildContext context) => CupertinoAlertDialog(
        title: const Text('Batch Setup'),
        content: const Text('Are you sure you want to delete this Batch Setup?'),
        actions: <CupertinoDialogAction>[
          CupertinoDialogAction(
            isDefaultAction: true,
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('No'),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            onPressed: () async {
              Navigator.pop(context);
              deleteBatchSetup(batchModel);
            },
            child: const Text('Yes'),
          )
        ],
      ),
    );
  }

  Future<void> deleteBatchSetup(Datum selectedBatchModel) async {
    _progressDialog = ProgressDialog(context, type: ProgressDialogType.normal, isDismissible: false);
    _progressDialog.style(message: "Please wait..");
    Map deleteSetupMap = {};
    deleteSetupMap['CoachBatchSetupId'] = selectedBatchModel.coachBatchSetupId;
    deleteSetupMap['CoachId'] = OQDOApplication.instance.coachID;
    deleteSetupMap['SubActivityId'] = selectedBatchModel.subActivityId;
    deleteSetupMap['CoachBatchSetupDetailDtos'] = [];
    debugPrint(json.encode(deleteSetupMap));
    try {
      await _progressDialog.show();
      var response = await Provider.of<ServiceProviderSetupViewModel>(context, listen: false).deleteCoachBatchSetup(deleteSetupMap);
      debugPrint(response);
      if (response.isNotEmpty) {
        showSnackBarColor('Deleted Successfully', context, false);
        Future.delayed(const Duration(milliseconds: 200), () {
          getCoachBatchList();
        });
      } else {
        showSnackBarErrorColor('We\'re unable to connect to server. Please contact administrator or try after some time', context, true);
      }
    } on CommonException catch (error) {
      debugPrint(error.toString());
      await _progressDialog.hide();
      if (error.code == 400) {
        Map<String, dynamic> errorModel = jsonDecode(error.message);
        if (errorModel.containsKey('ModelState')) {
          Map<String, dynamic> modelState = errorModel['ModelState'];
          if (modelState.containsKey('ErrorMessage')) {
            showSnackBarColor(modelState['ErrorMessage'][0], context, true);
          } else {
            showSnackBarColor('We\'re unable to connect to server. Please contact administrator or try after some time', context, true);
          }
        } else {
          showSnackBarColor('We\'re unable to connect to server. Please contact administrator or try after some time', context, true);
        }
      } else {
        showSnackBarColor('We\'re unable to connect to server. Please contact administrator or try after some time', context, true);
      }
    } on NoConnectivityException catch (_) {
      await _progressDialog.hide();
      showSnackBarColor(Constants.internetConnectionErrorMsg, context, true);
    } catch (error) {
      debugPrint(error.toString());
      await _progressDialog.hide();
      showSnackBarColor('We\'re unable to connect to server. Please contact administrator or try after some time', context, true);
    }
  }

  Future<void> getCoachBatchDetailsById(int? coachBatchSetupId) async {
    try {
      _progressDialog = ProgressDialog(context, type: ProgressDialogType.normal, isDismissible: false);
      _progressDialog.style(message: "Please wait..");
      await _progressDialog.show();
      CoachDetailsResponseModel coachDetailsResponseModel =
          await Provider.of<ServiceProviderSetupViewModel>(context, listen: false).getCoachDetailsById(coachBatchSetupId!);
      await _progressDialog.hide();
      if (coachDetailsResponseModel.coachName!.isNotEmpty) {
        Navigator.pushNamed(context, Constants.coachDetailScreen, arguments: coachDetailsResponseModel);
      }
    } on CommonException catch (error) {
      await _progressDialog.hide();
      debugPrint(error.toString());
      if (error.code == 400) {
        Map<String, dynamic> errorModel = jsonDecode(error.message);
        if (errorModel.containsKey('ModelState')) {
          Map<String, dynamic> modelState = errorModel['ModelState'];
          if (modelState.containsKey('ErrorMessage')) {
            showSnackBarColor(modelState['ErrorMessage'][0], context, true);
          } else {
            showSnackBarColor('We\'re unable to connect to server. Please contact administrator or try after some time', context, true);
          }
        } else {
          showSnackBarColor('We\'re unable to connect to server. Please contact administrator or try after some time', context, true);
        }
      } else {
        showSnackBarColor('We\'re unable to connect to server. Please contact administrator or try after some time', context, true);
      }
    } on NoConnectivityException catch (_) {
      await _progressDialog.hide();
      showSnackBarColor(Constants.internetConnectionErrorMsg, context, true);
    } catch (error) {
      await _progressDialog.hide();
      debugPrint(error.toString());
      showSnackBarErrorColor('We\'re unable to connect to server. Please contact administrator or try after some time', context, true);
    }
  }
}
