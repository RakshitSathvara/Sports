import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:http/http.dart';
import 'package:oqdo_mobile_app/components/my_button.dart';
import 'package:oqdo_mobile_app/helper/helpers.dart';
import 'package:oqdo_mobile_app/model/location_selection_response_model.dart';
import 'package:oqdo_mobile_app/oqdo_application.dart';
import 'package:oqdo_mobile_app/theme/oqdo_theme_data.dart';
import 'package:oqdo_mobile_app/utils/constants.dart';
import 'package:oqdo_mobile_app/utils/custom_text_view.dart';
import 'package:oqdo_mobile_app/utils/network_interceptor.dart';
import 'package:oqdo_mobile_app/utils/string_manager.dart';
import 'package:oqdo_mobile_app/viewmodels/location_selection_viewmodel.dart';
import 'package:progress_dialog_null_safe/progress_dialog_null_safe.dart';
import 'package:provider/provider.dart';

class LocationChoosePage extends StatefulWidget {
  const LocationChoosePage({super.key});

  @override
  _LocationChoosePageState createState() => _LocationChoosePageState();
}

class _LocationChoosePageState extends State<LocationChoosePage> {
  MediaQueryData get dimensions => MediaQuery.of(context);

  Size get size => dimensions.size;

  double get height => size.height;

  double get width => size.width;

  double get radius => sqrt(pow(width, 2) + pow(height, 2));
  List<DataBean>? location = [];
  String? choosedlocation;
  DataBean? selectedLocation;
  TextEditingController pincode = TextEditingController();
  late Helper hp;

  // final LocationSelectionViewModel _locationSelectionViewModel = LocationSelectionViewModel();
  late ProgressDialog progressDialog;

  @override
  void initState() {
    super.initState();
    hp = Helper.of(context);
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      progressDialog = ProgressDialog(context, type: ProgressDialogType.normal, isDismissible: false);
      progressDialog.style(message: 'Please wait...');
      progressDialog.show();
      getLocationsDetails();
    });
    // _locationSelectionViewModel.getAllCities();
    // progressDialog = ProgressDialog(context, type: ProgressDialogType.normal, isDismissible: false);
    // progressDialog.style(message: 'Please wait...');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // observableWidget(),
          Container(
            width: double.infinity,
            height: double.infinity,
            color: OQDOThemeData.backgroundColor,
            child: SingleChildScrollView(
              child: Form(
                key: hp.formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Stack(
                      alignment: Alignment.topLeft,
                      children: [
                        Container(
                          width: width / 1.1,
                          height: height / 1.9,
                          decoration: const BoxDecoration(
                            image: DecorationImage(
                              fit: BoxFit.fill,
                              image: AssetImage('assets/images/login_bg.png'),
                            ),
                          ),
                        ),
                        // Image.asset("assets/images/login_bg.png"),
                        Positioned(
                          top: 100,
                          left: 30,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Image.asset(
                                "assets/images/logo.png",
                                height: 100,
                                width: 140,
                              ),
                              CustomTextView(
                                label: 'Welcome',
                                textStyle: Theme.of(context)
                                    .textTheme
                                    .bodyLarge!
                                    .copyWith(color: const Color(0xFF595959), fontWeight: FontWeight.w400, fontSize: 24.0),
                              ),
                              CustomTextView(
                                label: 'back',
                                textStyle: Theme.of(context)
                                    .textTheme
                                    .bodyLarge!
                                    .copyWith(color: const Color(0xFF595959), fontWeight: FontWeight.w400, fontSize: 24.0),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 40,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CustomTextView(
                            label: 'Choose Your Location:',
                            type: styleSubTitle,
                            textStyle: Theme.of(context)
                                .textTheme
                                .titleMedium!
                                .copyWith(color: OQDOThemeData.dividerColor, fontWeight: FontWeight.w700, fontSize: 22.0),
                          ),
                          const SizedBox(
                            height: 30.0,
                          ),
                          Container(
                            decoration: BoxDecoration(
                              border: Border.all(color: Theme.of(context).colorScheme.primaryContainer),
                              borderRadius: BorderRadius.circular(15),
                              color: OQDOThemeData.backgroundColor,
                            ),
                            child: Padding(
                              padding: const EdgeInsets.only(left: 10, right: 10),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  const Icon(
                                    Icons.location_on_outlined,
                                    color: OQDOThemeData.dividerColor,
                                  ),
                                  const SizedBox(
                                    width: 10.0,
                                  ),
                                  Expanded(
                                    child: DropdownButton<dynamic>(
                                        isExpanded: true,
                                        underline: const SizedBox(),
                                        borderRadius: BorderRadius.circular(15),
                                        icon: const Icon(Icons.keyboard_arrow_down_rounded, color: OQDOThemeData.dividerColor),
                                        dropdownColor: Theme.of(context).colorScheme.onBackground,
                                        hint: CustomTextView(
                                          label: 'Select Location',
                                          textStyle: Theme.of(context)
                                              .textTheme
                                              .titleSmall!
                                              .copyWith(fontSize: 16.0, fontWeight: FontWeight.w400, color: OQDOThemeData.dividerColor),
                                        ),
                                        value: choosedlocation,
                                        items: location!.map((country) {
                                          return DropdownMenuItem(
                                            value: country.CountryName,
                                            child: CustomTextView(
                                              label: country.CountryName!,
                                              textStyle: Theme.of(context)
                                                  .textTheme
                                                  .titleSmall!
                                                  .copyWith(fontSize: 16.0, fontWeight: FontWeight.w400, color: OQDOThemeData.dividerColor),
                                            ),
                                          );
                                        }).toList(),
                                        onChanged: (value) {
                                          // WidgetsBinding.instance
                                          //     .addPostFrameCallback((_) {
                                          SchedulerBinding.instance.addPostFrameCallback((_) {
                                            setState(() {
                                              choosedlocation = value;
                                              checkForSelectedCity();
                                            });
                                          });

                                          // });
                                        }),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          const SizedBox(
                            height: 30,
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 15.0, right: 15.0),
                            child: MyButton(
                              text: "Get Started",
                              textcolor: Theme.of(context).colorScheme.onBackground,
                              textsize: 16,
                              fontWeight: FontWeight.w600,
                              letterspacing: 0.7,
                              buttoncolor: Theme.of(context).colorScheme.secondaryContainer,
                              buttonbordercolor: Theme.of(context).colorScheme.secondaryContainer,
                              buttonheight: 60,
                              buttonwidth: width,
                              radius: 15,
                              onTap: () async {
                                // print(choosedlocation);
                                if (choosedlocation != null) {
                                  await Navigator.pushNamedAndRemoveUntil(context, Constants.APPPAGES, Helper.of(context).predicate, arguments: 0);
                                } else {
                                  showSnackBar('Please select location', context);
                                }
                              },
                            ),
                          ),
                          const SizedBox(
                            height: 30,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> getLocationsDetails() async {
    try {
      await Provider.of<LocationSelectionViewModel>(context, listen: false).getAllCities().then(
        (value) async {
          Response res = value;

          // Hide progress dialog when API call completes
          if (progressDialog.isShowing()) {
            progressDialog.hide();
          }

          if (res.statusCode == 500 || res.statusCode == 404) {
            showSnackBarErrorColor(AppStrings.internalServerErrorMessage, context, true);
          } else if (res.statusCode == 200) {
            LocationSelectionResponseModel? list = LocationSelectionResponseModel.fromMap(jsonDecode(res.body));
            if (list!.Data!.isNotEmpty) {
              setState(() {
                location = list.Data;
              });
            }
          } else {
            Map<String, dynamic> errorModel = jsonDecode(res.body);
            if (errorModel.containsKey('ModelState')) {
              Map<String, dynamic> modelState = errorModel['ModelState'];
              if (modelState.containsKey('ErrorMessage')) {
                showSnackBarColor(modelState['ErrorMessage'][0], context, true);
              }
            }
          }
        },
      );
    } on NoConnectivityException catch (_) {
      // Hide progress dialog on error
      if (progressDialog.isShowing()) {
        progressDialog.hide();
      }
      showSnackBarErrorColor(AppStrings.noInternet, context, true);
    } on TimeoutException catch (_) {
      // Hide progress dialog on error
      if (progressDialog.isShowing()) {
        progressDialog.hide();
      }
      showSnackBarErrorColor(AppStrings.timeout, context, true);
    } on ServerException catch (_) {
      // Hide progress dialog on error
      if (progressDialog.isShowing()) {
        progressDialog.hide();
      }
      showSnackBarErrorColor(AppStrings.serverError, context, true);
    } catch (exception) {
      // Hide progress dialog on error
      if (progressDialog.isShowing()) {
        progressDialog.hide();
      }
      showSnackBarErrorColor(exception.toString(), context, true);
    }
  }

  // Widget observableWidget() {
  //   switch (_locationSelectionViewModel.locationResponse.state) {
  //     case Status.LOADING:
  //       WidgetsBinding.instance.addPostFrameCallback((_) {
  //         progressDialog.show();
  //       });

  //       break;
  //     case Status.COMPLETED:
  //       progressDialog.hide();
  //       if (_locationSelectionViewModel.locationResponse.data!.Data!.isNotEmpty) {
  //         location = _locationSelectionViewModel.locationResponse.data!.Data;
  //       }
  //       break;
  //     case Status.ERROR:
  //       progressDialog.hide();
  //       break;
  //   }
  //   return const SizedBox(
  //     height: 0,
  //   );
  // }

  void checkForSelectedCity() async {
    List<DataBean> selectedCityList = location!.where((element) => element.CountryName == choosedlocation).toList();

    // print(selectedCityList[0].MobileNoLength);

    await OQDOApplication.instance.storage.setStringValue(key: AppStrings.selectedCountryName, value: selectedCityList[0].CountryName!);
    await OQDOApplication.instance.storage.setStringValue(key: AppStrings.selectedCountryID, value: selectedCityList[0].CountryId.toString());
    await OQDOApplication.instance.storage.setStringValue(key: AppStrings.selectedCountryCode, value: selectedCityList[0].CountryCode!);
    await OQDOApplication.instance.storage.setStringValue(key: AppStrings.mobileNoLength, value: selectedCityList[0].MobileNoLength.toString());
  }
}
