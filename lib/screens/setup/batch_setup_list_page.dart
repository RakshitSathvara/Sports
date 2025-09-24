// ignore_for_file: use_build_context_synchronously

import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:oqdo_mobile_app/model/CoachDetailsResponseModel.dart' as CoachDetails;
import 'package:oqdo_mobile_app/screens/setup/coach_setup/models/coach_preview_model.dart';
import 'package:oqdo_mobile_app/screens/setup/coach_setup/view/coach_training_preview_page.dart';
import 'package:oqdo_mobile_app/screens/setup/coach_setup/view/create_coach_setup_page.dart';
import 'package:oqdo_mobile_app/screens/setup/facility_setup/models/add_time_slot_model.dart';
import 'package:oqdo_mobile_app/screens/setup/facility_setup/models/grid_view_item_model.dart';
import 'package:oqdo_mobile_app/theme/custom_colors.dart';
import 'package:oqdo_mobile_app/components/custom_app_bar.dart';
import 'package:oqdo_mobile_app/model/CoachDetailsResponseModel.dart';
import 'package:oqdo_mobile_app/model/GetCoachBySetupIDModel.dart';
import 'package:oqdo_mobile_app/model/calendar_view_model.dart';
import 'package:oqdo_mobile_app/model/get_coach_batch_model/datum.dart';
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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    final customColors = theme.extension<CustomColors>()!;

    return Scaffold(
      key: scaffoldKey,
      backgroundColor: colorScheme.background,
      appBar: CustomAppBar(
        title: 'Batch Setup',
        onBack: () {
          Navigator.pop(context);
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: customColors.greyButton,
        onPressed: () async {
          await Navigator.pushNamed(context, CreateCoachSetupPage.routeName).then((value) {
            if (value != null) {
              Future.delayed(const Duration(milliseconds: 200), () {
                getCoachBatchList();
              });
            }
          });
        },
        child: Icon(
          Icons.add_rounded,
          size: 50,
          color: colorScheme.primary,
        ),
      ),
      body: SafeArea(
        child: Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          color: theme.scaffoldBackgroundColor,
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
                          return Divider(
                            height: 1,
                            thickness: 1,
                            color: theme.dividerColor,
                          );
                        },
                        itemBuilder: (BuildContext context, int index) {
                          final batchDetails = coachBatchList[index];
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
                                        label: batchDetails.name,
                                        textOverFlow: TextOverflow.ellipsis,
                                        maxLine: 2,
                                        type: styleSubTitle,
                                        textStyle: textTheme.bodyMedium!.copyWith(
                                          color: colorScheme.onSurface,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      const SizedBox(
                                        height: 7,
                                      ),
                                      GestureDetector(
                                        onTap: () {
                                          getCoachBatchDetailsById(batchDetails.coachBatchSetupId);
                                        },
                                        child: CustomTextView(
                                          label: 'Details',
                                          type: styleSubTitle,
                                          textStyle: textTheme.bodyMedium!.copyWith(
                                            color: colorScheme.primary,
                                            fontWeight: FontWeight.w500,
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
                                        calendarViewModel.coachBatchSetupId = batchDetails.coachBatchSetupId;
                                        calendarViewModel.selectedDateTime = DateTime.now();
                                        await Navigator.of(context).pushNamed(Constants.coachBatchCancelSlotScreen, arguments: calendarViewModel);
                                      },
                                      icon: ImageIcon(
                                        const AssetImage("assets/images/ic_cancel.png"),
                                        color: colorScheme.onSurface,
                                      ),
                                    ),
                                    IconButton(
                                      onPressed: () async {
                                        debugPrint(batchDetails.coachBatchSetupId.toString());
                                        getCoachBatchBySetupId(batchDetails.coachBatchSetupId!);
                                      },
                                      icon: ImageIcon(
                                        const AssetImage("assets/images/ic_edit.png"),
                                        color: colorScheme.onSurface,
                                      ),
                                    ),
                                    IconButton(
                                      onPressed: () {
                                        _showAlertDialog(context, batchDetails);
                                      },
                                      icon: ImageIcon(
                                        const AssetImage("assets/images/ic_delete.png"),
                                        color: colorScheme.onSurface,
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
                                    style: textTheme.bodyMedium?.copyWith(
                                      color: colorScheme.onSurface,
                                    ),
                                    children: [
                                      const TextSpan(text: 'There is nothing to show,\nadd Batch from '),
                                      WidgetSpan(
                                        alignment: PlaceholderAlignment.middle,
                                        child: Icon(
                                          Icons.add_rounded,
                                          size: 25,
                                          color: colorScheme.primary,
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
                  style: ElevatedButton.styleFrom(
                    backgroundColor: customColors.greyButton,
                    foregroundColor: colorScheme.primary,
                    textStyle: textTheme.labelLarge,
                  ),
                  child: const Text(
                    "Vacation",
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
    _progressDialog.style(
            message: "Please wait..",
            backgroundColor: Theme.of(context).extension<CustomColors>()!.progressDialogBackgroundColor,
            messageTextStyle: TextStyle(color: Theme.of(context).extension<CustomColors>()!.blackAndWhiteColor, fontFamily: 'Inter', fontWeight: FontWeight.bold, fontSize: 18));
    if (_progressDialog.isShowing()) {
      await _progressDialog.hide();
    }
    try {
      await _progressDialog.show();
      GetCoachBatchModel facilityListResponseModel = await Provider.of<ServiceProviderSetupViewModel>(context, listen: false).getCoachBatchList(OQDOApplication.instance.coachID!);
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
      _progressDialog.style(
              message: "Please wait..",
              backgroundColor: Theme.of(context).extension<CustomColors>()!.progressDialogBackgroundColor,
              messageTextStyle: TextStyle(color: Theme.of(context).extension<CustomColors>()!.blackAndWhiteColor, fontFamily: 'Inter', fontWeight: FontWeight.bold, fontSize: 18));
      await _progressDialog.show();
      GetCoachBySetupIdModel getCoachBySetupIdModel = await Provider.of<ServiceProviderSetupViewModel>(context, listen: false).getBatchByID(batchID);
      await _progressDialog.hide();
      debugPrint(getCoachBySetupIdModel.name);
      final result = await Navigator.pushNamed(context, CreateCoachSetupPage.routeName, arguments: getCoachBySetupIdModel);
      if (result == true) {
        Future.delayed(const Duration(milliseconds: 200), () {
          getCoachBatchList();
        });
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
    _progressDialog.style(
            message: "Please wait..",
            backgroundColor: Theme.of(context).extension<CustomColors>()!.progressDialogBackgroundColor,
            messageTextStyle: TextStyle(color: Theme.of(context).extension<CustomColors>()!.blackAndWhiteColor, fontFamily: 'Inter', fontWeight: FontWeight.bold, fontSize: 18));
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
      _progressDialog.style(
              message: "Please wait..",
              backgroundColor: Theme.of(context).extension<CustomColors>()!.progressDialogBackgroundColor,
              messageTextStyle: TextStyle(color: Theme.of(context).extension<CustomColors>()!.blackAndWhiteColor, fontFamily: 'Inter', fontWeight: FontWeight.bold, fontSize: 18));
      await _progressDialog.show();
      CoachDetailsResponseModel coachDetailsResponseModel = await Provider.of<ServiceProviderSetupViewModel>(context, listen: false).getCoachDetailsById(coachBatchSetupId!);
      await _progressDialog.hide();
      CoachPreviewModel coachPreviewModel = _convertToCoachPreviewModel(coachDetailsResponseModel);

      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => CoachTrainingPreviewPage(coachDetails: coachPreviewModel),
        ),
      );
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

  CoachPreviewModel _convertToCoachPreviewModel(CoachDetails.CoachDetailsResponseModel model) {
    // Convert slots to AddTimeSlotModel list
    List<AddTimeSlotModel> slotsList = [];

    if (model.slots != null) {
      for (CoachDetails.Slots slot in model.slots!) {
        // Convert day numbers to GridViewItemModel list
        List<GridViewItemModel> selectedDays = [];
        if (slot.dayNos != null) {
          for (int dayNo in slot.dayNos!) {
            String dayName = _getDayName(dayNo);
            selectedDays.add(GridViewItemModel(id: dayNo, imagePath: "", title: dayName));
          }
        }

        // Create controllers for the AddTimeSlotModel
        TextEditingController startTimeController = TextEditingController(text: slot.startTimeFormatted ?? '00:00');
        TextEditingController numberOfSlotsController = TextEditingController(text: (slot.noOfSlot ?? 1).toString());

        AddTimeSlotModel timeSlotModel = AddTimeSlotModel(
          selectedDays: selectedDays,
          startTime: startTimeController,
          formKey: GlobalKey<FormState>(),
          numberOfSlots: numberOfSlotsController,
          perSlotDuration: int.tryParse(model.slotTimeHour ?? '1') ?? 1,
          startTimeControllerKey: GlobalKey(),
          ratePerHour: slot.ratePerHour ?? model.ratePerHour ?? 0.0,
        );

        slotsList.add(timeSlotModel);
      }
    }

    // Determine if it's open class based on booking type
    bool isOpenClass = model.bookingType == "I" ? true : false;

    // Calculate slot duration for display
    String slotDurationFormatted = '';
    int slotDurationInMinutes = 0;
    int slotDuration = 0;

    if (model.slotTimeHour != null && model.slotTimeMinute != null) {
      int slotHours = int.tryParse(model.slotTimeHour!) ?? 0;
      slotDurationInMinutes = (slotHours * 60) + (model.slotTimeMinute ?? 0);
      slotDuration = slotHours;

      if (slotDurationInMinutes >= 60) {
        int hours = slotDurationInMinutes ~/ 60;
        int minutes = slotDurationInMinutes % 60;
        if (minutes > 0) {
          slotDurationFormatted = '${hours}h ${minutes}m';
        } else {
          slotDurationFormatted = '${hours}h';
        }
      } else {
        slotDurationFormatted = '${slotDurationInMinutes}m';
      }
    } else if (model.slotTimeHour != null) {
      slotDuration = int.tryParse(model.slotTimeHour!) ?? 0;
      slotDurationInMinutes = slotDuration * 60;
      slotDurationFormatted = '${model.slotTimeHour}h';
    }

    // Determine address type ID
    int addressTypeId = 1; // Default to coach's address
    if (model.isTrainingAddress == true && model.isTraineeAddress == true) {
      addressTypeId = 3; // Both
    } else if (model.isTrainingAddress == true) {
      addressTypeId = 1; // Coach's address
    } else if (model.isTraineeAddress == true) {
      addressTypeId = 2; // Home training
    }

    return CoachPreviewModel(
      title: model.name ?? '',
      activity: model.activities?.name ?? '',
      subActivity: model.subActivities?.name ?? '',
      slotDuration: slotDuration,
      slotDurationInMinutes: slotDurationInMinutes,
      slotDurationFormatted: slotDurationFormatted,
      slotRate: model.ratePerHour ?? 0.0,
      maxCapacityOrGroupSize: model.bookingType == "I" ? (model.batchCapacity?.toString() ?? '1') : (model.maxGroupSize?.toString() ?? '1'),
      minSessions: (model.minumumSlot ?? 1).toString(),
      isOpenClass: isOpenClass,
      addressTypeId: addressTypeId,
      slotsList: slotsList,
    );
  }

  String _getDayName(int dayNo) {
    switch (dayNo) {
      case 1:
        return 'Mon';
      case 2:
        return 'Tue';
      case 3:
        return 'Wed';
      case 4:
        return 'Thu';
      case 5:
        return 'Fri';
      case 6:
        return 'Sat';
      case 0:
        return 'Sun';
      default:
        return 'Unknown';
    }
  }
}
