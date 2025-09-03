import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:oqdo_mobile_app/components/custom_app_bar.dart';
import 'package:oqdo_mobile_app/model/facility_vacation_response_model.dart';
import 'package:oqdo_mobile_app/oqdo_application.dart';
import 'package:oqdo_mobile_app/theme/oqdo_theme_data.dart';
import 'package:oqdo_mobile_app/utils/colorsUtils.dart';
import 'package:oqdo_mobile_app/utils/constants.dart';
import 'package:oqdo_mobile_app/utils/custom_text_view.dart';
import 'package:oqdo_mobile_app/utils/network_interceptor.dart';
import 'package:oqdo_mobile_app/viewmodels/service_provider_setup_viewmodel.dart';
import 'package:progress_dialog_null_safe/progress_dialog_null_safe.dart';
import 'package:provider/provider.dart';

class VacationListScreen extends StatefulWidget {
  const VacationListScreen({super.key});

  @override
  State<VacationListScreen> createState() => _VacationListScreenState();
}

class _VacationListScreenState extends State<VacationListScreen> {
  late ProgressDialog _progressDialog;
  final List<FacilityVacationResponseModel> _facilityVacationList = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      getFacilityVacationCall();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Vacations',
        onBack: () {
          Navigator.of(context).pop();
        },
      ),
      floatingActionButton: FloatingActionButton(
        // isExtended: true,
        backgroundColor: ColorsUtils.greyButton,
        onPressed: () async {
          await Navigator.pushNamed(context, Constants.ADDFACILITYVACATIONPAGE).then((value) {
            if (value != null) {
              getFacilityVacationCall();
            }
          });
        },
        // isExtended: true,
        child: Icon(
          Icons.add_rounded,
          size: 35,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
      body: SafeArea(
        child: Container(
          color: Colors.white,
          height: double.infinity,
          width: double.infinity,
          padding: const EdgeInsets.all(3.0),
          child: Column(
            children: [
              _facilityVacationList.isNotEmpty
                  ? Expanded(
                      child: ListView.builder(
                        shrinkWrap: false,
                        itemCount: _facilityVacationList.length,
                        itemBuilder: (context, index) {
                          return createSymptomWeekListItem(index);
                        },
                      ),
                    )
                  : Expanded(
                      child: Column(
                        children: [
                          Image.asset(
                            'assets/images/ic_empty_view.png',
                            fit: BoxFit.fill,
                            height: 400,
                            width: 400,
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          CustomTextView(
                            label: 'No vacation available',
                            textStyle:
                                Theme.of(context).textTheme.titleMedium!.copyWith(fontSize: 16, color: OQDOThemeData.greyColor, fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }

  createSymptomWeekListItem(int index) {
    return SizedBox(
      height: 170.0,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(0, 0, 0, 8),
        child: Card(
          semanticContainer: true,
          clipBehavior: Clip.antiAliasWithSaveLayer,
          elevation: 4.0,
          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.rectangle,
                  border: Border.all(width: 7.0, color: ColorsUtils.vacationList),
                ),
              ),
              const SizedBox(width: 20.0),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          CustomTextView(
                              label: "From",
                              textStyle: Theme.of(context).textTheme.bodyMedium!.copyWith(
                                    color: Theme.of(context).colorScheme.onSurface,
                                  )),
                          const SizedBox(width: 150),
                          CustomTextView(
                              label: "To",
                              textStyle: Theme.of(context).textTheme.bodyMedium!.copyWith(
                                    color: Theme.of(context).colorScheme.onSurface,
                                  )),
                        ],
                      ),
                      const SizedBox(
                        height: 8,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CustomTextView(
                              label: convertDateToVisibleForm(_facilityVacationList[index].fromDate!.split('T')[0]),
                              textStyle: Theme.of(context).textTheme.bodyMedium!.copyWith(color: Theme.of(context).colorScheme.shadow, fontSize: 14)),
                          const SizedBox(
                            width: 20,
                          ),
                          SizedBox(
                            height: 15,
                            child: ImageIcon(
                              const AssetImage("assets/images/arrow_right.png"),
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
                          const SizedBox(
                            width: 20,
                          ),
                          CustomTextView(
                              label: convertDateToVisibleForm(_facilityVacationList[index].toDate!.split('T')[0]),
                              textStyle: Theme.of(context).textTheme.bodyMedium!.copyWith(color: Theme.of(context).colorScheme.shadow, fontSize: 14)),
                        ],
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          CustomTextView(
                              label: "Reason ",
                              textStyle: Theme.of(context).textTheme.displaySmall!.copyWith(color: Theme.of(context).colorScheme.onSurface, fontSize: 16)),
                          const SizedBox(width: 10),
                          CustomTextView(
                              label: _facilityVacationList[index].cancelreason,
                              maxLine: 1,
                              textStyle: Theme.of(context).textTheme.displaySmall!.copyWith(color: Theme.of(context).colorScheme.shadow, fontSize: 16)),
                        ],
                      ),
                      const SizedBox(
                        height: 5,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CustomTextView(
                              label: "Name ",
                              textStyle: Theme.of(context).textTheme.displaySmall!.copyWith(color: Theme.of(context).colorScheme.onSurface, fontSize: 16)),
                          const SizedBox(width: 10),
                          Expanded(
                            child: CustomTextView(
                                label: _facilityVacationList[index].batchName,
                                maxLine: 2,
                                textOverFlow: TextOverflow.ellipsis,
                                textStyle: Theme.of(context).textTheme.displaySmall!.copyWith(color: Theme.of(context).colorScheme.shadow, fontSize: 16)),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(0, 12, 8, 0),
                child: IconButton(
                  onPressed: () {
                    deleteVacation(_facilityVacationList[index].vacationId);
                  },
                  icon: ImageIcon(
                    const AssetImage("assets/images/ic_delete.png"),
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> getFacilityVacationCall() async {
    _progressDialog = ProgressDialog(context, type: ProgressDialogType.normal, isDismissible: false);
    _progressDialog.style(message: "Please wait..");
    try {
      await _progressDialog.show();
      List<FacilityVacationResponseModel> response =
          await Provider.of<ServiceProviderSetupViewModel>(context, listen: false).getFacilityVacationCall(OQDOApplication.instance.facilityID!);
      if (!mounted) return;
      await _progressDialog.hide();
      if (response.isNotEmpty) {
        setState(() {
          _facilityVacationList.clear();
          _facilityVacationList.addAll(response);
          debugPrint(_facilityVacationList.length.toString());
        });
      } else {
        setState(() {
          _facilityVacationList.clear();
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
      if (!mounted) return;
      showSnackBarColor(Constants.internetConnectionErrorMsg, context, true);
    } catch (error) {
      await _progressDialog.hide();
      if (!mounted) return;
      debugPrint(error.toString());
      showSnackBarErrorColor('We\'re unable to connect to server. Please contact administrator or try after some time', context, true);
    }
  }

  String convertDateToVisibleForm(String date) {
    String parsingDate = '';
    DateTime dateTime = DateFormat('yyyy-MM-dd').parse(date);
    String month = DateFormat.yMMMM().format(dateTime);
    parsingDate = '${date.split('-')[2]} ${month.split(' ')[0].toUpperCase()} \'${date.split('-')[0].substring(date.split('-')[0].length - 2)}';
    return parsingDate;
  }

  Future<void> deleteVacation(int? vacationId) async {
    _progressDialog = ProgressDialog(context, type: ProgressDialogType.normal, isDismissible: false);
    _progressDialog.style(message: "Please wait..");
    try {
      await _progressDialog.show();
      Map<String, dynamic> request = {};
      request['VacationId'] = vacationId!;

      String response = await Provider.of<ServiceProviderSetupViewModel>(context, listen: false).deleteFacilityVacation(request);
      await _progressDialog.hide();
      if (response.isNotEmpty) {
        setState(() {
          showSnackBarColor('Facility vacation deleted', context, false);
          getFacilityVacationCall();
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
      showSnackBarErrorColor('We\'re unable to connect to server. Please contact administrator or try after some time', context, true);
    }
  }
}
