import 'dart:math';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:oqdo_mobile_app/components/custom_app_bar.dart';
import 'package:oqdo_mobile_app/components/my_button.dart';
import 'package:oqdo_mobile_app/model/facility_list_response_model.dart';
import 'package:oqdo_mobile_app/oqdo_application.dart';
import 'package:oqdo_mobile_app/theme/oqdo_theme_data.dart';
import 'package:oqdo_mobile_app/utils/constants.dart';
import 'package:oqdo_mobile_app/utils/custom_text_view.dart';
import 'package:oqdo_mobile_app/utils/network_interceptor.dart';
import 'package:oqdo_mobile_app/utils/textfields_widget.dart';
import 'package:oqdo_mobile_app/utils/utilities.dart';
import 'package:oqdo_mobile_app/utils/validator.dart';
import 'package:oqdo_mobile_app/viewmodels/service_provider_setup_viewmodel.dart';
import 'package:progress_dialog_null_safe/progress_dialog_null_safe.dart';
import 'package:provider/provider.dart';

class AddFacilityVacationPage extends StatefulWidget {
  const AddFacilityVacationPage({Key? key}) : super(key: key);

  @override
  _AddFacilityVacationPageState createState() => _AddFacilityVacationPageState();
}

class _AddFacilityVacationPageState extends State<AddFacilityVacationPage> {
  final scaffoldKey = GlobalKey<ScaffoldState>();

  double get height => MediaQuery.of(context).size.height;

  double get width => MediaQuery.of(context).size.width;

  double get radius => sqrt(pow(width, 2) + pow(height, 2));
  TextEditingController fromDateController = TextEditingController();
  TextEditingController toDateController = TextEditingController();
  TextEditingController reasonController = TextEditingController();
  DateTime todayDate = DateTime.now();
  DateTime selectedDate = DateTime.now();
  String? choosedinterest;
  String? reasonSelect;
  late ProgressDialog _progressDialog;
  List<Data> facilitySetupList = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      getFacilitySetupList();
    });
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.onBackground,
      key: scaffoldKey,
      appBar: CustomAppBar(
        title: 'Add Vacation',
        onBack: () {
          Navigator.pop(context);
        },
        actions: [
          IconButton(
            onPressed: () {},
            icon: ImageIcon(
              const AssetImage("assets/images/notify_icon.png"),
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.white
                  : Colors.black,
            ),
          ),
          IconButton(
            onPressed: () {},
            icon: ImageIcon(
              const AssetImage("assets/images/search_icon.png"),
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.fromLTRB(18.0, 18.0, 18.0, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GestureDetector(
                  onTap: () async {
                    await Navigator.pushNamed(context, Constants.VACATIONLISTPAGE);
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      CustomTextView(
                        label: "Go to the list",
                        type: styleSubTitle,
                        textStyle: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      Image.asset(
                        "assets/images/list_menu.png",
                        width: 30,
                        height: 30,
                      ),
                    ],
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  SizedBox(
                    width: 180,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CustomTextView(
                          label: "From",
                          type: styleSubTitle,
                          textStyle: Theme.of(context).textTheme.bodyMedium!.copyWith(color: Theme.of(context).colorScheme.error),
                        ),
                        const SizedBox(
                          height: 6,
                        ),
                        GestureDetector(
                          onTap: () {
                            _selectDate(context);
                          },
                          child: TextField(
                            enabled: false,
                            controller: fromDateController,
                            style: Theme.of(context).textTheme.bodyMedium!.copyWith(color: Theme.of(context).colorScheme.shadow),
                            decoration: InputDecoration(
                              hintText: 'Select date',
                              counterText: "",
                              contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                              hintStyle: const TextStyle(
                                color: Colors.black26,
                              ),
                              filled: true,
                              suffixIcon: Padding(
                                padding: const EdgeInsets.fromLTRB(6.0, 2.0, 8.0, 2.0),
                                child: Image.asset(
                                  "assets/images/calendar_cicular.png",
                                  fit: BoxFit.contain,
                                  width: 18,
                                  height: 18,
                                ),
                              ),
                              fillColor: Colors.white70,
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Theme.of(context).colorScheme.primary, width: 1.3),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Theme.of(context).colorScheme.primary, width: 1.3),
                              ),
                              disabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Theme.of(context).colorScheme.primary, width: 1.3),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    width: 180,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CustomTextView(
                          label: "To",
                          type: styleSubTitle,
                          textStyle: Theme.of(context).textTheme.bodyMedium!.copyWith(color: Theme.of(context).colorScheme.error),
                        ),
                        const SizedBox(
                          height: 6,
                        ),
                        GestureDetector(
                          onTap: () {
                            _selectDate(context);
                          },
                          child: TextField(
                            controller: fromDateController,
                            enabled: false,
                            style: Theme.of(context).textTheme.bodyMedium!.copyWith(color: Theme.of(context).colorScheme.shadow),
                            decoration: InputDecoration(
                              hintText: 'Select date',
                              counterText: "",
                              contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                              hintStyle: const TextStyle(color: Colors.black26),
                              filled: true,
                              suffixIcon: Padding(
                                padding: const EdgeInsets.fromLTRB(6.0, 4.0, 8.0, 4.0),
                                child: Image.asset(
                                  "assets/images/calendar_cicular.png",
                                  fit: BoxFit.contain,
                                  width: 18,
                                  height: 18,
                                ),
                              ),
                              fillColor: Colors.white70,
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Theme.of(context).colorScheme.primary, width: 1.3),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Theme.of(context).colorScheme.primary, width: 1.3),
                              ),
                              disabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Theme.of(context).colorScheme.primary, width: 1.3),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                ]),
                const SizedBox(
                  height: 30,
                ),
                Flexible(
                  fit: FlexFit.loose,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(0, 12, 0, 0),
                        child: CustomTextView(
                          label: "Reason",
                          type: styleSubTitle,
                          textStyle: Theme.of(context).textTheme.bodyMedium!.copyWith(color: Theme.of(context).colorScheme.error, fontSize: 22),
                        ),
                      ),
                      const SizedBox(
                        width: 20,
                      ),
                      Expanded(
                        child: Column(
                          children: [
                            ListTile(
                              horizontalTitleGap: 0,
                              title: Text(
                                'Medical Reason',
                                style: Theme.of(context).textTheme.bodyMedium!.copyWith(color: Theme.of(context).colorScheme.shadow, fontSize: 18),
                              ),
                              leading: Radio(
                                value: "Medical Reason",
                                activeColor: Theme.of(context).colorScheme.primary,
                                groupValue: reasonSelect,
                                onChanged: (String? value) {
                                  setState(() {
                                    reasonSelect = value;
                                  });
                                },
                              ),
                            ),
                            ListTile(
                              horizontalTitleGap: 0,
                              title: Text(
                                'Travel Reason',
                                style: Theme.of(context).textTheme.bodyMedium!.copyWith(color: Theme.of(context).colorScheme.shadow, fontSize: 18),
                              ),
                              leading: Radio(
                                value: "Travel Reason",
                                activeColor: Theme.of(context).colorScheme.primary,
                                groupValue: reasonSelect,
                                onChanged: (String? value) {
                                  setState(() {
                                    reasonSelect = value;
                                  });
                                },
                              ),
                            ),
                            ListTile(
                              horizontalTitleGap: 0,
                              title: Text(
                                'Personal Reason',
                                style: Theme.of(context).textTheme.bodyMedium!.copyWith(color: Theme.of(context).colorScheme.shadow, fontSize: 18),
                              ),
                              leading: Radio(
                                value: "Personal Reason",
                                activeColor: Theme.of(context).colorScheme.primary,
                                groupValue: reasonSelect,
                                onChanged: (String? value) {
                                  setState(() {
                                    reasonSelect = value;
                                  });
                                },
                              ),
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                CustomTextFormField(
                  controller: reasonController,
                  read: false,
                  obscureText: false,
                  labelText: 'Specify your reason here',
                  validator: Validator.notEmpty,
                  keyboardType: TextInputType.text,
                  maxlines: 4,
                ),
                // const SizedBox(
                //   height: 30,
                // ),
                // CustomTextView(
                //   label: "List of facilities:",
                //   type: styleSubTitle,
                //   textStyle: Theme.of(context).textTheme.bodyText2!.copyWith(
                //       color: Theme.of(context).colorScheme.error, fontSize: 22),
                // ),
                // const SizedBox(
                //   height: 10,
                // ),
                // facilitySetupList.isNotEmpty
                //     ? createFacilityList()
                //     : Container(),
                const SizedBox(
                  height: 20,
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(0, 0, 0, 16),
                  child: MyButton(
                    text: "Submit",
                    textcolor: Theme.of(context).colorScheme.onBackground,
                    textsize: 16,
                    fontWeight: FontWeight.w600,
                    letterspacing: 0.7,
                    buttoncolor: Theme.of(context).colorScheme.secondaryContainer,
                    buttonbordercolor: Theme.of(context).colorScheme.secondaryContainer,
                    buttonheight: 50,
                    buttonwidth: width,
                    radius: 15,
                    onTap: () async {},
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget createFacilityList() {
    return ListView.builder(
        shrinkWrap: true,
        itemCount: 1,
        physics: const NeverScrollableScrollPhysics(),
        itemBuilder: (BuildContext context, int index) {
          return Container(
            padding: const EdgeInsets.only(left: 20.0, right: 20.0, top: 20.0),
            child: Row(
              children: [
                Transform.scale(
                  scale: 1.3,
                  child: Checkbox(
                      fillColor: MaterialStateProperty.resolveWith(Utils.getColor),
                      checkColor: Theme.of(context).colorScheme.primaryContainer,
                      value: facilitySetupList[index].isFacilitySelected,
                      onChanged: (value) {
                        setState(() {
                          facilitySetupList[index].isFacilitySelected = value;
                        });
                      }),
                ),
                const SizedBox(
                  width: 15.0,
                ),
                CustomTextView(
                  label: '${facilitySetupList[index].facilityName}',
                  textStyle: Theme.of(context).textTheme.titleMedium!.copyWith(fontSize: 18.0, fontWeight: FontWeight.w500, color: OQDOThemeData.greyColor),
                )
              ],
            ),
          );
        });
  }

  Future<void> _selectDate(BuildContext context) async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: todayDate,
      firstDate: todayDate,
      lastDate: DateTime(2030),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: ColorScheme.light(
              primary: Theme.of(context).colorScheme.primary,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
            dialogBackgroundColor: Colors.white,
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
        fromDateController.text = DateFormat('dd-MM-yyyy').format(selectedDate);
      });
    }
  }

  Future<void> getFacilitySetupList() async {
    _progressDialog = ProgressDialog(context, type: ProgressDialogType.normal, isDismissible: false);
    _progressDialog.style(message: "Please wait..");
    try {
      _progressDialog.show();
      FacilityListResponseModel facilityListResponseModel =
          await Provider.of<ServiceProviderSetupViewModel>(context, listen: false).getFacilitySetupList(OQDOApplication.instance.facilityID!);

      _progressDialog.hide();
      setState(() {
        // facilitySetupList = facilityListResponseModel.data!;
        facilitySetupList.addAll(facilityListResponseModel.data!);
        debugPrint(facilityListResponseModel.data!.toString());
      });
    } on NoConnectivityException catch (_) {
      _progressDialog.hide();
      showSnackBarColor(Constants.internetConnectionErrorMsg, context, true);
    } catch (error) {
      _progressDialog.hide();
      debugPrint(error.toString());
      showSnackBarErrorColor('We\'re unable to connect to server. Please contact administrator or try after some time', context, true);
    }
  }
}
