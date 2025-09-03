// ignore_for_file: use_build_context_synchronously

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:oqdo_mobile_app/components/my_button.dart';
import 'package:oqdo_mobile_app/model/common_passing_args.dart';
import 'package:oqdo_mobile_app/utils/constants.dart';
import 'package:oqdo_mobile_app/utils/custom_text_view.dart';
import 'package:oqdo_mobile_app/utils/network_interceptor.dart';
import 'package:oqdo_mobile_app/utils/textfields_widget.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:pin_code_text_field/pin_code_text_field.dart';
import 'package:progress_dialog_null_safe/progress_dialog_null_safe.dart';
import 'package:provider/provider.dart';

import '../../../helper/helpers.dart';
import '../../../model/location_selection_response_model.dart';
import '../../../model/upload_file_response.dart';
import '../../../oqdo_application.dart';
import '../../../theme/oqdo_theme_data.dart';
import '../../../utils/string_manager.dart';
import '../../../utils/validator.dart';
import '../../../viewmodels/end_user_resgistration_view_model.dart';

class CoachAddPageOne extends StatefulWidget {
  final CommonPassingArgs commonPassingArgs;

  const CoachAddPageOne(this.commonPassingArgs, {super.key});

  @override
  CoachAddPageOneState createState() => CoachAddPageOneState();
}

class CoachAddPageOneState extends State<CoachAddPageOne> {
  MediaQueryData get dimensions => MediaQuery.of(context);

  Size get size => dimensions.size;

  double get height => size.height;

  double get width => size.width;

  double get radius => sqrt(pow(width, 2) + pow(height, 2));
  TextEditingController icNum = TextEditingController();
  TextEditingController postalcode = TextEditingController();
  TextEditingController address = TextEditingController();
  TextEditingController regNum = TextEditingController();
  TextEditingController estabSince = TextEditingController();
  TextEditingController uenNumberController = TextEditingController();
  int counter = 1;
  final picker = ImagePicker();

  // File? profilepic;
  CroppedFile? croppedFile;
  List<File> selectedimage = [];
  late Helper hp;

  late ProgressDialog _progressDialog;
  List<DataBean>? location = [];
  String? choosedlocation;
  int? selectedCityId;
  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  String? selectedCityCountryCode = '';
  String? selectedCityID = '';

  @override
  void initState() {
    super.initState();
    hp = Helper.of(context);
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      _progressDialog = ProgressDialog(context, type: ProgressDialogType.normal, isDismissible: false);
      _progressDialog.style(message: "Please wait..");
      // getAllCity();
      getPrefValue();
    });
  }

  void getPrefValue() async {
    choosedlocation = OQDOApplication.instance.storage.getStringValue(AppStrings.selectedCountryName);
    selectedCityCountryCode = OQDOApplication.instance.storage.getStringValue(AppStrings.selectedCountryCode);
    selectedCityID = OQDOApplication.instance.storage.getStringValue(AppStrings.selectedCountryID);
    debugPrint(choosedlocation);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    // var ph = MediaQuery.of(context).size.height;
    // TODO: implement build
    return Scaffold(
      body: SafeArea(
        child: Container(
          width: double.infinity,
          height: double.infinity,
          color: OQDOThemeData.backgroundColor,
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.only(left: 25, right: 25),
              child: Form(
                key: formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(
                      height: 20.0,
                    ),
                    Center(
                      child: Image.asset(
                        "assets/images/logo.png",
                        height: 80,
                        width: 130,
                      ),
                    ),
                    const SizedBox(
                      height: 15.0,
                    ),
                    Center(
                      child: CustomTextView(
                        label: 'Coach',
                        type: styleSubTitle,
                        textStyle: Theme.of(context).textTheme.titleMedium!.copyWith(
                              fontSize: 22.0,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF006590),
                            ),
                      ),
                    ),
                    const Divider(
                      thickness: 3,
                      color: Color.fromRGBO(0, 101, 144, 0.78),
                    ),
                    const SizedBox(
                      height: 30,
                    ),
                    CustomTextFormField(
                      controller: icNum,
                      read: false,
                      maxlines: 1,
                      obscureText: false,
                      fillColor: OQDOThemeData.backgroundColor,
                      maxlength: 4,
                      inputformat: [
                        FilteringTextInputFormatter.allow(RegExp(r'^[a-zA-Z0-9]+')),
                      ],
                      labelText: 'IC Number (Last 4 Digits)',
                      validator: Validator.notEmpty,
                      keyboardType: TextInputType.text,
                    ),
                    const SizedBox(
                      height: 10.0,
                    ),
                    Align(
                      alignment: Alignment.topLeft,
                      child: CustomTextView(
                        label: 'Select City',
                        textStyle: Theme.of(context)
                            .textTheme
                            .titleMedium!
                            .copyWith(color: const Color.fromRGBO(129, 129, 129, 1), fontWeight: FontWeight.w400, fontSize: 17.0),
                      ),
                    ),
                    const SizedBox(
                      height: 15.0,
                    ),
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Theme.of(context).colorScheme.primaryContainer),
                        borderRadius: BorderRadius.circular(15),
                        color: OQDOThemeData.backgroundColor,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.only(left: 10, right: 10),
                        child: DropdownButton<dynamic>(
                            isExpanded: true,
                            icon: const Icon(Icons.keyboard_arrow_down_rounded, color: OQDOThemeData.dividerColor),
                            dropdownColor: Theme.of(context).colorScheme.onBackground,
                            underline: const SizedBox(),
                            borderRadius: BorderRadius.circular(15),
                            hint: CustomTextView(
                              label: choosedlocation ?? "City",
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
                              debugPrint('Selected city : - $value');
                              SchedulerBinding.instance.addPostFrameCallback((_) {
                                setState(() {
                                  choosedlocation = value;
                                });
                                checkForSelectedCity();
                              });
                            }),
                      ),
                    ),
                    const SizedBox(
                      height: 20.0,
                    ),
                    Align(
                      alignment: Alignment.topLeft,
                      child: CustomTextView(
                        label: 'Postal Code',
                        type: styleSubTitle,
                        textStyle: Theme.of(context)
                            .textTheme
                            .bodyLarge!
                            .copyWith(color: const Color.fromRGBO(129, 129, 129, 1), fontWeight: FontWeight.w400, fontSize: 16.0),
                      ),
                    ),
                    PinCodeTextField(
                      pinBoxHeight: 55,
                      pinBoxWidth: MediaQuery.of(context).size.width / 8,
                      pinBoxRadius: 5,
                      autofocus: false,
                      controller: postalcode,
                      hideCharacter: false,
                      highlight: true,
                      highlightColor: Theme.of(context).colorScheme.secondaryContainer,
                      defaultBorderColor: const Color.fromRGBO(0, 101, 144, 0.53),
                      hasTextBorderColor: const Color.fromRGBO(0, 101, 144, 0.53),
                      errorBorderColor: Colors.red,
                      maxLength: 6,
                      hasError: false,
                      maskCharacter: "*",
                      //😎
                      onTextChanged: (text) {},
                      onDone: (text) async {},
                      wrapAlignment: WrapAlignment.spaceEvenly,
                      pinBoxDecoration: ProvidedPinBoxDecoration.underlinedPinBoxDecoration,
                      pinTextStyle: const TextStyle(fontSize: 25.0, color: Colors.black),
                      pinTextAnimatedSwitcherTransition: ProvidedPinBoxTextAnimation.scalingTransition,
                      pinBoxColor: Theme.of(context).colorScheme.secondaryContainer,
                      pinTextAnimatedSwitcherDuration: const Duration(milliseconds: 300),
                      //                    highlightAnimation: true,
                      //highlightPinBoxColor: Colors.red,
                      highlightAnimationBeginColor: Colors.black,
                      highlightAnimationEndColor: Colors.white12,
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(
                      height: 30,
                    ),
                    CustomTextFormField(
                      controller: address,
                      read: false,
                      obscureText: false,
                      fillColor: OQDOThemeData.backgroundColor,
                      labelText: 'Address',
                      maxlength: 200,
                      validator: Validator.notEmpty,
                      keyboardType: TextInputType.text,
                      maxlines: 4,
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    CustomTextView(
                      label: 'Upload Profile Photo',
                      textStyle:
                          Theme.of(context).textTheme.titleMedium!.copyWith(fontSize: 17.0, color: OQDOThemeData.otherTextColor, fontWeight: FontWeight.w400),
                    ),
                    const SizedBox(
                      height: 10.0,
                    ),
                    Row(
                      children: [
                        GestureDetector(
                          onTap: () {
                            bottomSheetImage();
                          },
                          child: const CircleAvatar(
                            radius: 50,
                            backgroundColor: Colors.transparent,
                            backgroundImage: AssetImage("assets/images/camera.png"),
                          ),
                        ),
                        const SizedBox(
                          width: 40.0,
                        ),
                        croppedFile != null
                            ? SizedBox(
                                width: 110,
                                height: 70,
                                child: Card(
                                  clipBehavior: Clip.antiAliasWithSaveLayer,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10.0),
                                  ),
                                  child: Image.file(
                                    File(croppedFile!.path),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              )
                            : Container(),
                        const SizedBox(
                          width: 20.0,
                        ),
                        croppedFile != null
                            ? GestureDetector(
                                onTap: () {
                                  setState(() {
                                    croppedFile = null;
                                    widget.commonPassingArgs.profileImageUploadId = "";
                                  });
                                },
                                child: CustomTextView(
                                  label: 'Clear',
                                  textStyle: Theme.of(context)
                                      .textTheme
                                      .titleLarge!
                                      .copyWith(color: Theme.of(context).colorScheme.primary, fontSize: 16.0, fontWeight: FontWeight.w600),
                                ),
                              )
                            : Container(),
                      ],
                    ),
                    const SizedBox(
                      height: 30.0,
                    ),
                    CustomTextFormField(
                      controller: regNum,
                      read: false,
                      fillColor: OQDOThemeData.backgroundColor,
                      maxlines: 1,
                      maxlength: 30,
                      inputformat: [
                        FilteringTextInputFormatter.allow(RegExp(r'^[a-zA-Z0-9]+')),
                      ],
                      obscureText: false,
                      labelText: 'Coach Registry Number',
                      // validator: Validator.notEmpty,
                      keyboardType: TextInputType.text,
                    ),
                    const SizedBox(
                      height: 20.0,
                    ),
                    CustomTextFormField(
                      controller: estabSince,
                      read: false,
                      maxlines: 1,
                      fillColor: OQDOThemeData.backgroundColor,
                      obscureText: false,
                      maxlength: 2,
                      inputformat: [FilteringTextInputFormatter.allow(RegExp(r'[0-9]')), FilteringTextInputFormatter.digitsOnly],
                      labelText: 'Years of Experience',
                      validator: Validator.notEmpty,
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(
                      height: 20.0,
                    ),
                    CustomTextFormField(
                      controller: uenNumberController,
                      read: false,
                      maxlines: 1,
                      fillColor: OQDOThemeData.backgroundColor,
                      obscureText: false,
                      maxlength: 12,
                      inputformat: [
                        FilteringTextInputFormatter.allow(RegExp(r'^[a-zA-Z0-9]+')),
                      ],
                      labelText: 'UEN Number',
                      keyboardType: TextInputType.text,
                    ),
                    const SizedBox(
                      height: 40.0,
                    ),
                    MyButtonWithoutBackground(
                      text: "Next",
                      textcolor: Theme.of(context).colorScheme.secondaryContainer,
                      textsize: 16,
                      fontWeight: FontWeight.w600,
                      letterspacing: 0.7,
                      buttoncolor: OQDOThemeData.backgroundColor,
                      buttonbordercolor: Theme.of(context).colorScheme.secondaryContainer,
                      buttonheight: 60,
                      buttonwidth: width,
                      radius: 15,
                      onTap: () async {
                        hideKeyboard();
                        // if (formKey.currentState!.validate()) {
                        validatePage();
                        // }
                      },
                    ),
                    const SizedBox(
                      height: 30,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  bottomSheetImage() async {
    await showModalBottomSheet(
        context: context,
        builder: (context) {
          return SafeArea(
            child: Wrap(
              children: <Widget>[
                ListTile(
                    leading: const Icon(Icons.photo_library),
                    title: const Text(
                      'Photo Library',
                      style: TextStyle(
                          // fontFamily: 'Fingbanger',
                          ),
                    ),
                    onTap: () async {
                      // final serviceStatus = await Permission.storage.isGranted;
                      if (Constants.androidVersion >= 13) {
                        getPicFromGallery();
                      } else {
                        // final serviceStatus = await Permission.storage.isGranted;
                        var status = await Permission.storage.request();
                        if (status == PermissionStatus.granted) {
                          getPicFromGallery();
                        } else if (status == PermissionStatus.denied) {
                          showSnackBar('Permission denied.Please Allow Permission.', context);
                        } else if (status == PermissionStatus.permanentlyDenied) {
                          await openAppSettings();
                        }
                      }
                    }),
                ListTile(
                    leading: const Icon(Icons.photo_camera),
                    title: const Text(
                      'Camera',
                      style: TextStyle(
                          // fontFamily: 'Fingbanger',
                          ),
                    ),
                    onTap: () async {
                      // final serviceStatus = await Permission.camera.isGranted;
                      var status = await Permission.camera.request();
                      if (status == PermissionStatus.granted) {
                        getPicFromCam();
                      } else if (status == PermissionStatus.denied) {
                        if (status == PermissionStatus.granted) {
                          getPicFromCam();
                        } else {
                          showSnackBar('Permission denied.Please Allow Permission.', context);
                        }
                      } else if (status == PermissionStatus.permanentlyDenied) {
                        await openAppSettings();
                      }
                    } //getPicFromCam
                    ),
              ],
            ),
          );
        });
  }

  Future getPicFromCam() async {
    Navigator.pop(context);
    await _progressDialog.hide();
    setState(() {});
    var pickedFile = await picker.pickImage(source: ImageSource.camera);

    if (pickedFile != null) {
      _cropImage(pickedFile);
      // final byte = await File(pickedFile.path).length();
      // final kb = byte / 1024;
      // final mb = kb / 1024;
      // debugPrint("File size -> ${mb.toString()}");
      // if (mb < 10.0) {
      //   await _progressDialog.hide();
      //   profilepic = File(pickedFile.path);
      //   setState(() {});
      // } else {
      //   await _progressDialog.hide();
      //   setState(() {});
      //   showSnackBarErrorColor("Please select image below 10 MB", context, true);
      // }
    } else {
      await _progressDialog.hide();
      setState(() {});
    }
  }

  Future getPicFromGallery() async {
    Navigator.pop(context);
    await _progressDialog.show();
    setState(() {});
    var pickedFile = await picker.pickImage(source: ImageSource.gallery, imageQuality: 60);

    if (pickedFile != null) {
      _cropImage(pickedFile);
      // final byte = await File(pickedFile.path).length();
      // final kb = byte / 1024;
      // final mb = kb / 1024;
      // debugPrint("File size -> ${mb.toString()}");
      // if (mb < 10.0) {
      //   await _progressDialog.hide();
      //   profilepic = File(pickedFile.path);
      //   selectedimage.add(profilepic!);
      //   setState(() {});
      // } else {
      //   await _progressDialog.hide();
      //   setState(() {});
      //   showSnackBarErrorColor("Please select image below 10 MB", context, true);
      // }
    } else {
      await _progressDialog.hide();
      setState(() {});
    }
  }

  Future<void> _cropImage(XFile pickedFile) async {
    var mCroppedFile = await ImageCropper().cropImage(sourcePath: pickedFile.path, compressFormat: ImageCompressFormat.jpg, compressQuality: 100, uiSettings: [
      AndroidUiSettings(
          toolbarTitle: 'Cropper',
          toolbarColor: OQDOThemeData.buttonColor,
          toolbarWidgetColor: Colors.white,
          initAspectRatio: CropAspectRatioPreset.square,
          lockAspectRatio: false),
      IOSUiSettings(
        title: 'Cropper',
      ),
    ]);

    if (mCroppedFile != null) {
      var byte = await File(pickedFile.path).length();
      var kb = byte / 1024;
      var mb = kb / 1024;
      debugPrint("File size -> ${mb.toString()}");
      if (mb < 10.0) {
        await _progressDialog.hide();
        croppedFile = mCroppedFile;
        setState(() {});
      } else {
        await _progressDialog.hide();
        setState(() {});
        showSnackBarErrorColor("Please select image below 10 MB", context, true);
      }
    } else {
      await _progressDialog.hide();
      setState(() {});
    }
  }

  void checkForSelectedCity() {
    List<DataBean> selectedCityList = location!.where((element) => element.CountryName == choosedlocation).toList();
    selectedCityId = selectedCityList[0].CityId;
    widget.commonPassingArgs.selectedCityDetails = selectedCityList;
  }

  Future<void> getAllCity() async {
    try {
      await _progressDialog.show();
      await Provider.of<EndUserRegistrationViewModel>(context, listen: false).getAllCities().then(
        (value) async {
          Response res = value;

          if (res.statusCode == 500 || res.statusCode == 404) {
            await _progressDialog.hide();
            showSnackBarErrorColor(AppStrings.internalServerErrorMessage, context, true);
          } else if (res.statusCode == 200) {
            await _progressDialog.hide();
            LocationSelectionResponseModel? locationSelectionResponseModel = LocationSelectionResponseModel.fromMap(jsonDecode(res.body));
            if (locationSelectionResponseModel!.Data!.isNotEmpty) {
              await _progressDialog.hide();
              setState(() {
                location = locationSelectionResponseModel.Data!;
              });
            }
          } else {
            await _progressDialog.hide();
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
      await _progressDialog.hide();
      showSnackBarErrorColor(AppStrings.noInternet, context, true);
    } on TimeoutException catch (_) {
      await _progressDialog.hide();
      showSnackBarErrorColor(AppStrings.timeout, context, true);
    } on ServerException catch (_) {
      await _progressDialog.hide();
      showSnackBarErrorColor(AppStrings.serverError, context, true);
    } catch (exception) {
      await _progressDialog.hide();
      showSnackBarErrorColor(exception.toString(), context, true);
    }
  }

  void validatePage() {
    if (!(formKey.currentState!.validate())) {
      return;
    } else {
      if (choosedlocation != null) {
        if (croppedFile == null) {
          showSnackBar('Profile image required', context);
        } else if (address.text.toString().trim().isEmpty) {
          showSnackBar('Address is required', context);
        } else if (postalcode.text.toString().trim().isNotEmpty && postalcode.text.toString().trim().length < 6) {
          showSnackBar('6 digit postal code is required', context);
        } else if (icNum.text.toString().trim().length < 4) {
          showSnackBar('4 digit IC Number is required', context);
        } else {
          _progressDialog = ProgressDialog(context, type: ProgressDialogType.normal, isDismissible: false);
          _progressDialog.style(message: "Please wait..");
          // final bytes = File(croppedFile!.path).readAsBytesSync();
          // String convertedBytes = base64Encode(bytes);
          // debugPrint(convertedBytes);
          // debugPrint(croppedFile!.path);
          // debugPrint(croppedFile!.path.split('/').last);
          // debugPrint(croppedFile!.path.split('/').last.split('.')[1]);
          uploadFile();
        }
      } else {
        showSnackBar('Please select city', context);
      }
    }
  }

  Future<void> uploadFile() async {
    await _progressDialog.show();

    var bytes = File(croppedFile!.path).readAsBytesSync();
    String convertedBytes = base64Encode(bytes);

    Map uploadFileRequest = {};
    uploadFileRequest['FileStorageId'] = null;
    uploadFileRequest['FileName'] = croppedFile!.path.split('/').last;
    uploadFileRequest['FileExtension'] = croppedFile!.path.split('/').last.split('.')[1];
    uploadFileRequest['FilePath'] = convertedBytes;

    try {
      await Provider.of<EndUserRegistrationViewModel>(context, listen: false).uploadFile(uploadFileRequest).then(
        (value) async {
          Response res = value;

          if (res.statusCode == 500 || res.statusCode == 404) {
            await _progressDialog.hide();
            showSnackBarErrorColor(AppStrings.internalServerErrorMessage, context, true);
          } else if (res.statusCode == 200) {
            await _progressDialog.hide();
            UploadFileResponse? uploadFileResponse = UploadFileResponse.fromMap(jsonDecode(res.body));
            debugPrint('Upload File Response -> ${uploadFileResponse!.FileStorageId}');
            widget.commonPassingArgs.profileImageUploadId = uploadFileResponse.FileStorageId.toString();
            setPassingArgsAndNavigate();
          } else {
            await _progressDialog.hide();
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
      await _progressDialog.hide();
      showSnackBarErrorColor(AppStrings.noInternet, context, true);
    } on TimeoutException catch (_) {
      await _progressDialog.hide();
      showSnackBarErrorColor(AppStrings.timeout, context, true);
    } on ServerException catch (_) {
      await _progressDialog.hide();
      showSnackBarErrorColor(AppStrings.serverError, context, true);
    } catch (exception) {
      await _progressDialog.hide();
      showSnackBarErrorColor(exception.toString(), context, true);
    }
  }

  void setPassingArgsAndNavigate() {
    widget.commonPassingArgs.coachICNumber = icNum.text.toString().trim();
    widget.commonPassingArgs.postalCode = postalcode.text.toString().trim();
    widget.commonPassingArgs.address = address.text.toString().trim();
    widget.commonPassingArgs.coachRegistryNumber = regNum.text.toString().trim();
    widget.commonPassingArgs.coachEstablishmentYear = estabSince.text.toString().trim();
    widget.commonPassingArgs.uenNUmber = uenNumberController.text.toString().trim();
    debugPrint(widget.commonPassingArgs.tempRegisterId.toString());
    Navigator.of(context).pushNamed(Constants.COACHADDTWO, arguments: widget.commonPassingArgs);
  }
}
