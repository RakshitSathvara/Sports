import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:oqdo_mobile_app/model/GetFacilityByIdModel.dart';
import 'package:oqdo_mobile_app/model/get_all_activity_and_sub_activity_response.dart';
import 'package:oqdo_mobile_app/model/upload_file_response.dart';
import 'package:oqdo_mobile_app/oqdo_application.dart';
import 'package:oqdo_mobile_app/repository/service_provider_repository/service_provider_repository_impl.dart';
import 'package:oqdo_mobile_app/screens/setup/facility_setup/models/add_time_slot_model.dart';
import 'package:oqdo_mobile_app/screens/setup/facility_setup/models/facility_preview_model.dart';
import 'package:oqdo_mobile_app/screens/setup/facility_setup/models/grid_view_item_model.dart';
import 'package:oqdo_mobile_app/screens/setup/facility_setup/models/selected_image_model.dart';
import 'package:oqdo_mobile_app/screens/setup/facility_setup/view/widgets/time_input_field.dart';
import 'package:oqdo_mobile_app/screens/setup/facility_setup/viewmodel/stepper_mixin.dart';
import 'package:oqdo_mobile_app/utils/constants.dart';
import 'package:oqdo_mobile_app/utils/network_interceptor.dart';
import 'package:progress_dialog_null_safe/progress_dialog_null_safe.dart';

enum BookingSlotSheetState { ideal, hide }

enum FacilitySetupState { ideal, success, failure }

class CreateFacilityViewModel extends ChangeNotifier with StepperMixin {
  final _facilitySetupRepo = ServiceProviderSetupRepositoryImpl();

  bool isEdit = false;

  final GetFacilityByIdModel? getFacilityByIdModel;

  CreateFacilityViewModel({required this.getFacilityByIdModel}) {
    if (getFacilityByIdModel != null) {
      setFacilityData(getFacilityByIdModel);
      return;
    }
    getAllActivity();
  }

  ProgressDialog? progressDialog;

  void onBackPressed(BuildContext context) {
    hideKeyboard();
    if (currentStep == 1) {
      Navigator.of(context).pop();
    } else if (currentStep == 2) {
      decrementCurrentStep();
      notifyListeners();
    } else {
      decrementCurrentStep();
      notifyListeners();
    }
  }

  void nextStep() {
    hideKeyboard();
    if (!isLastStep) {
      if (currentStep == 1) {
        final isValidate = validateFirstStep();
        if (isValidate) {
          incrementCurrentStep();
          notifyListeners();
        }
      } else {
        final isValidate = validateSecondStep();
        if (isValidate) {
          incrementCurrentStep();
          notifyListeners();
        }
      }
    }
  }

  void previousStep() {
    hideKeyboard();
    if (canGoPrevious) {
      decrementCurrentStep();
      notifyListeners();
    }
  }

  ////////////////////////////////////////////////// Step 1 ////////////////////////////////////////////////

  final firstStepFormKey = GlobalKey<FormState>();
  final titleController = TextEditingController();
  final subTitleController = TextEditingController();

  List<ActivityBean> activityList = [];
  ActivityBean? selectedActivity;
  List<SubActivitiesBean> subActivityList = [];
  SubActivitiesBean? selectedSubActivity;

  final List<GridViewItemModel> bookingTypes = [
    GridViewItemModel(
        id: 1,
        imagePath: "assets/images/ic_group_class.png",
        title: "Shared Rental"),
    GridViewItemModel(
        id: 2,
        imagePath: "assets/images/ic_open_class.png",
        title: "Private Rental"),
  ];

  GridViewItemModel? selectedBookingType;

  // function to select activity
  void onSelectActivity(ActivityBean item) {
    hideKeyboard();
    if (selectedActivity?.ActivityId == item.ActivityId) return;
    selectedActivity = item;
    selectedSubActivity = null;
    subActivityList = selectedActivity?.SubActivities ?? [];
    subActivityHint = "Select ${selectedActivity?.Name?.toLowerCase() ?? ""}";
    notifyListeners();
  }

  String subActivityHint = "Select";

  // function to select booking type
  void onSelectBookingType(GridViewItemModel item) {
    hideKeyboard();
    if (selectedBookingType?.id == item.id) return;
    selectedBookingType = item;
    capacityController.clear();
    notifyListeners();
  }

  // function to select sub activity
  void onSelectSubActivity(SubActivitiesBean value) {
    if (selectedSubActivity?.SubActivityId == value.SubActivityId) return;
    selectedSubActivity = value;
    notifyListeners();
  }

  bool validateFirstStep() {
    bool result = true;
    if (!(firstStepFormKey.currentState!.validate())) {
      return false;
    } else if (selectedActivity == null) {
      setError(error: "Please select Activity");
      notifyListeners();
      return false;
    } else if (selectedSubActivity == null) {
      setError(error: "Please select Subactivity");
      notifyListeners();
      return false;
    } else if (selectedBookingType == null) {
      setError(error: "Please select Booking Type");
      notifyListeners();
      return false;
    }
    return result;
  }

  Future<void> getAllActivity({bool showLoader = true}) async {
    if (showLoader) {
      setLoaderState(state: LoaderState.showLoader);
      notifyListeners();
    }
    try {
      var response = await _facilitySetupRepo.getAllActivityAndSubActivity();
      if (response.Data != null && response.Data!.isNotEmpty) {
        activityList = response.Data ?? [];
        for (var element in activityList) {
          if (element.Name?.toLowerCase().contains("wellness") ?? false) {
            element.localIconPath = "assets/images/icon_wellness.png";
          } else if (element.Name?.toLowerCase().contains("hobbies") ?? false) {
            element.localIconPath = "assets/images/icon_hobbies.png";
          } else if (element.Name?.toLowerCase().contains("sports") ?? false) {
            element.localIconPath = "assets/images/icon_sports.png";
          }
        }
      }
      if (showLoader) {
        setLoaderState(state: LoaderState.hideLoader);
        notifyListeners();
      }
    } on CommonException catch (error) {
      if (error.code == 400) {
        Map<String, dynamic> errorModel = jsonDecode(error.message);
        if (errorModel.containsKey('ModelState')) {
          Map<String, dynamic> modelState = errorModel['ModelState'];
          if (modelState.containsKey('ErrorMessage')) {
            setError(error: modelState['ErrorMessage'][0]);
          } else {
            setError(
                error:
                    'We\'re unable to connect to server. Please contact administrator or try after some time');
          }
        } else {
          setError(
              error:
                  'We\'re unable to connect to server. Please contact administrator or try after some time');
        }
      } else {
        setError(
            error:
                'We\'re unable to connect to server. Please contact administrator or try after some time');
      }
      if (showLoader) {
        setLoaderState(state: LoaderState.showLoader);
        notifyListeners();
      }
      debugPrint(error.message);
    } on NoConnectivityException catch (_) {
      setError(error: Constants.internetConnectionErrorMsg);
      if (showLoader) {
        setLoaderState(state: LoaderState.showLoader);
        notifyListeners();
      }
    } catch (error) {
      setError(
          error:
              'We\'re unable to connect to server. Please contact administrator or try after some time');
      if (showLoader) {
        setLoaderState(state: LoaderState.showLoader);
        notifyListeners();
      }
    }
  }

  ////////////////////////////////////////////////// Step 2 ////////////////////////////////////////////////

  final secondStepFormKey = GlobalKey<FormState>();
  final imagePicker = ImagePicker();
  bool isMultipleImgsEdited = false;
  bool isListImage = false;

  bool isSlotTimeChangeRequestAccepted = true;

  // manage image ids on delete
  List<SelectedImageModel> galleryImages = [];
  SelectedImageModel? selectedCoverImage;
  int? selectedCoverImageId;

  final descriptionController = TextEditingController();
  final rentalDurationController = TextEditingController();
  final capacityController = TextEditingController();

  // Store previous rental duration for reverting changes
  String _previousRentalDuration = "";

  /// Convert duration string from HH:MM format to hours integer (for slot duration display)
  int getRentalDurationInHours() {
    final durationText = rentalDurationController.text.trim();
    if (durationText.contains(':')) {
      // Parse HH:MM format - return only the hours part for slot duration display
      final parts = durationText.split(':');
      if (parts.length == 2) {
        final hours = int.tryParse(parts[0]) ?? 0;
        return hours;
      }
    }
    // Fall back to parsing as simple integer
    return int.tryParse(durationText) ?? 0;
  }

  /// Convert duration string to total minutes for API calls
  int getRentalDurationInMinutes() {
    final durationText = rentalDurationController.text.trim();
    if (durationText.contains(':')) {
      // Parse HH:MM format
      final parts = durationText.split(':');
      if (parts.length == 2) {
        final hours = int.tryParse(parts[0]) ?? 0;
        final minutes = int.tryParse(parts[1]) ?? 0;
        
        // Convert to total minutes
        return (hours * 60) + minutes;
      }
    }
    // Fall back to parsing as simple integer (assume hours)
    final hours = int.tryParse(durationText) ?? 0;
    return hours * 60;
  }

  /// Set rental duration from total minutes to HH:MM format
  void setRentalDurationFromMinutes(int totalMinutes) {
    if (totalMinutes > 0) {
      final hours = totalMinutes ~/ 60;
      final minutes = totalMinutes % 60;
      final formatted = '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}';
      rentalDurationController.text = formatted;
    }
  }

  /// Set rental duration from hours integer to HH:MM format (legacy method)
  void setRentalDurationFromHours(int hours) {
    setRentalDurationFromMinutes(hours * 60);
  }

  /// Store current rental duration as previous (for reverting changes)
  void storePreviousRentalDuration() {
    _previousRentalDuration = rentalDurationController.text.trim();
  }

  /// Revert rental duration to previous value
  void revertRentalDurationChange() {
    if (_previousRentalDuration.isNotEmpty) {
      rentalDurationController.text = _previousRentalDuration;
    }
    notifyListeners();
  }

  /// Format duration for display (e.g., "4h 30m" or "2h")
  String getFormattedDurationForDisplay() {
    final durationText = rentalDurationController.text.trim();
    if (durationText.contains(':')) {
      final parts = durationText.split(':');
      if (parts.length == 2) {
        final hours = int.tryParse(parts[0]) ?? 0;
        final minutes = int.tryParse(parts[1]) ?? 0;
        
        if (minutes == 0) {
          return '${hours}h';
        } else {
          return '${hours}h ${minutes}m';
        }
      }
    }
    // Fall back to simple hours format
    final hours = int.tryParse(durationText) ?? 0;
    return '${hours}h';
  }

  /// Format duration for slot details display (e.g., "4 hours 30 minutes" or "2 hours")
  String getFormattedSlotDurationForDisplay() {
    final durationText = rentalDurationController.text.trim();
    if (durationText.contains(':')) {
      final parts = durationText.split(':');
      if (parts.length == 2) {
        final hours = int.tryParse(parts[0]) ?? 0;
        final minutes = int.tryParse(parts[1]) ?? 0;
        
        if (minutes == 0) {
          return hours == 1 ? '1 hour' : '$hours hours';
        } else {
          String hourText = hours == 1 ? '1 hour' : '$hours hours';
          String minuteText = minutes == 1 ? '1 minute' : '$minutes minutes';
          return '$hourText $minuteText';
        }
      }
    }
    // Fall back to simple hours format
    final hours = int.tryParse(durationText) ?? 0;
    return hours == 1 ? '1 hour' : '$hours hours';
  }

  /// Calculate and format total duration for a slot (numberOfSlots * slotDuration)
  String getFormattedTotalDurationForDisplay(int numberOfSlots) {
    final durationMinutes = getRentalDurationInMinutes();
    final totalMinutes = numberOfSlots * durationMinutes;
    
    final totalHours = totalMinutes ~/ 60;
    final remainingMinutes = totalMinutes % 60;
    
    if (remainingMinutes == 0) {
      return totalHours == 1 ? '1 hour' : '$totalHours hours';
    } else {
      String hourText = totalHours == 1 ? '1 hour' : '$totalHours hours';
      String minuteText = remainingMinutes == 1 ? '1 minute' : '$remainingMinutes minutes';
      return '$hourText $minuteText';
    }
  }

  /// Calculate accurate time range for a slot (startTime to endTime)
  String getAccurateTimeRangeForDisplay(String startTime, int numberOfSlots) {
    try {
      // Parse the start time (expecting format like "14:00" or "14:30")
      List<String> timeParts = startTime.split(':');
      if (timeParts.length != 2) {
        return startTime;
      }

      int startHours = int.parse(timeParts[0]);
      int startMinutes = int.parse(timeParts[1]);

      // Validate time values
      if (startHours < 0 || startHours > 23 || startMinutes < 0 || startMinutes > 59) {
        return startTime;
      }

      // Calculate total duration in minutes
      final durationMinutes = getRentalDurationInMinutes();
      final totalDurationMinutes = numberOfSlots * durationMinutes;

      // Convert start time to minutes
      int startTimeInMinutes = (startHours * 60) + startMinutes;

      // Add total duration
      int endTimeInMinutes = startTimeInMinutes + totalDurationMinutes;

      // Convert back to hours and minutes
      int endHours = (endTimeInMinutes ~/ 60) % 24;
      int endMinutes = endTimeInMinutes % 60;

      // Format the end time
      String endTime = '${endHours.toString().padLeft(2, '0')}:${endMinutes.toString().padLeft(2, '0')}';

      return '$startTime - $endTime';
    } catch (e) {
      // Return start time if any error occurs
      return startTime;
    }
  }

  /// Calculate accurate end time for a slot
  String getAccurateEndTimeForDisplay(String startTime, int numberOfSlots) {
    try {
      // Parse the start time (expecting format like "14:00" or "14:30")
      List<String> timeParts = startTime.split(':');
      if (timeParts.length != 2) {
        return startTime;
      }

      int startHours = int.parse(timeParts[0]);
      int startMinutes = int.parse(timeParts[1]);

      // Validate time values
      if (startHours < 0 || startHours > 23 || startMinutes < 0 || startMinutes > 59) {
        return startTime;
      }

      // Calculate total duration in minutes
      final durationMinutes = getRentalDurationInMinutes();
      final totalDurationMinutes = numberOfSlots * durationMinutes;

      // Convert start time to minutes
      int startTimeInMinutes = (startHours * 60) + startMinutes;

      // Add total duration
      int endTimeInMinutes = startTimeInMinutes + totalDurationMinutes;

      // Convert back to hours and minutes
      int endHours = (endTimeInMinutes ~/ 60) % 24;
      int endMinutes = endTimeInMinutes % 60;

      // Format the end time
      return '${endHours.toString().padLeft(2, '0')}:${endMinutes.toString().padLeft(2, '0')}';
    } catch (e) {
      // Return start time if any error occurs
      return startTime;
    }
  }

  // clear data on previous button click
  void clearStepTwoData() {
    galleryImages.clear();
    selectedCoverImage = null;
    descriptionController.clear();
    rentalDurationController.clear();
    capacityController.clear();
    notifyListeners();
  }

  // remove selected gallery section image
  void removeGalleryImage(SelectedImageModel image) {
    galleryImages.removeWhere((value) => value.serverId == image.serverId);
    notifyListeners();
  }

  // remove selected cover section image
  void removeCoverImage() {
    selectedCoverImage = null;
    selectedCoverImageId = null;
    notifyListeners();
  }

  void onAcceptSlotTimeChangeRequest() {
    isSlotTimeChangeRequestAccepted = true;
    addedTimeSlotList.clear();
    notifyListeners();
  }

  // select multiple photo for gallery section
  Future getMultiplePicFromGallery() async {
    setLoaderState(state: LoaderState.showLoader);
    notifyListeners();

    var pickedFile = await imagePicker.pickMultiImage(imageQuality: 60);

    if ((galleryImages.length + pickedFile.length) > 3) {
      setLoaderState(state: LoaderState.hideLoader);
      setError(error: 'Maximum 3 images allowed');
      notifyListeners();
      return;
    } else {
      if (pickedFile.length > 3) {
        setLoaderState(state: LoaderState.hideLoader);
        setError(error: 'Maximum 3 images allowed');
        notifyListeners();
        return;
      }
    }
    double maxMb = 0.00;

    for (int i = 0; i < pickedFile.length; i++) {
      var byte = (await pickedFile[i].readAsBytes()).lengthInBytes;
      var kb = byte / 1024;
      var mb = kb / 1024;
      if (mb > 10.0) {
        setLoaderState(state: LoaderState.hideLoader);
        maxMb = 0.0;
        setError(error: 'Please select image below 10 MB');
        notifyListeners();
        return;
      } else {
        maxMb = maxMb + mb;
      }
    }

    if (maxMb < 30.0) {
      isMultipleImgsEdited = true;
      await uploadFacilityImgFiles(pickedFile);
    } else {
      setError(error: 'Please select images below 30 MB');
    }
    setLoaderState(state: LoaderState.hideLoader);
    notifyListeners();
  }

  Future<void> uploadFacilityImgFiles(List<XFile> pickedFile) async {
    for (int i = 0; i < pickedFile.length; i++) {
      Map uploadFileRequest = {};
      uploadFileRequest['FileStorageId'] = null;
      uploadFileRequest['FileName'] = pickedFile[i].path.split('/').last;
      uploadFileRequest['FileExtension'] =
          pickedFile[i].path.split('/').last.split('.')[1];
      var bytes = File(pickedFile[i].path).readAsBytesSync();
      String convertedBytes = base64Encode(bytes);
      uploadFileRequest['FilePath'] = convertedBytes;
      try {
        UploadFileResponse uploadFileResponse =
            await _facilitySetupRepo.uploadImage(uploadFileRequest);
        debugPrint(
            'Upload File Response -> ${uploadFileResponse.FileStorageId}');
        galleryImages.add(SelectedImageModel(
            serverId: uploadFileResponse.FileStorageId!, image: pickedFile[i]));
      } on CommonException catch (error) {
        if (error.code == 400) {
          Map<String, dynamic> errorModel = jsonDecode(error.message);
          if (errorModel.containsKey('ModelState')) {
            Map<String, dynamic> modelState = errorModel['ModelState'];
            if (modelState.containsKey('ErrorMessage')) {
              setError(error: modelState['ErrorMessage'][0] ?? "");
            } else {
              setError(
                  error:
                      'We\'re unable to connect to server. Please contact administrator or try after some time');
            }
          } else {
            setError(
                error:
                    'We\'re unable to connect to server. Please contact administrator or try after some time');
          }
        } else {
          setError(
              error:
                  'We\'re unable to connect to server. Please contact administrator or try after some time');
        }
        debugPrint(error.message);
      } on NoConnectivityException catch (_) {
        setError(error: Constants.internetConnectionErrorMsg);
      } catch (error) {
        setError(
            error:
                'We\'re unable to connect to server. Please contact administrator or try after some time');
      }
    }
  }

  // Get single photo for cover section from Camera
  Future getPhotoFromCamera() async {
    if (selectedCoverImage != null) {
      setError(error: "Maximum 1 image allowed");
      notifyListeners();
      return;
    }

    setLoaderState(state: LoaderState.showLoader);
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 250));

    var pickedFile = await imagePicker.pickImage(
        source: ImageSource.camera, imageQuality: 60);

    if (pickedFile != null) {
      var byte = await File(pickedFile.path).length();
      var kb = byte / 1024;
      var mb = kb / 1024;
      debugPrint("File size -> ${mb.toString()}");
      if (mb < 10.0) {
        isListImage = true;
        await uploadSinglePhotoFile(pickedFile);
      } else {
        setError(error: "Please select image below 10 MB");
      }
      setLoaderState(state: LoaderState.hideLoader);
      notifyListeners();
    } else {
      setLoaderState(state: LoaderState.hideLoader);
      notifyListeners();
    }
  }

  // select single photo for cover section
  Future getSinglePhotoFromGallery() async {
    if (selectedCoverImage != null) {
      setError(error: "Maximum 1 image allowed");
      notifyListeners();
      return;
    }

    setLoaderState(state: LoaderState.showLoader);
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 250));

    var pickedFile = await imagePicker.pickImage(
        source: ImageSource.gallery, imageQuality: 60);

    if (pickedFile != null) {
      var byte = await File(pickedFile.path).length();
      var kb = byte / 1024;
      var mb = kb / 1024;
      debugPrint("File size -> ${mb.toString()}");
      if (mb < 10.0) {
        isListImage = true;
        await uploadSinglePhotoFile(pickedFile);
      } else {
        setError(error: "Please select image below 10 MB");
      }
      setLoaderState(state: LoaderState.hideLoader);
      notifyListeners();
    } else {
      setLoaderState(state: LoaderState.hideLoader);
      notifyListeners();
    }
  }

  Future<void> uploadSinglePhotoFile(XFile pickedFile) async {
    var bytes = File(pickedFile.path).readAsBytesSync();
    String convertedBytes = base64Encode(bytes);
    Map uploadFileRequest = {};
    uploadFileRequest['FileStorageId'] = null;
    uploadFileRequest['FileName'] = pickedFile.path.split('/').last;
    uploadFileRequest['FileExtension'] =
        pickedFile.path.split('/').last.split('.')[1];
    uploadFileRequest['FilePath'] = convertedBytes;
    try {
      UploadFileResponse uploadFileResponse =
          await _facilitySetupRepo.uploadImage(uploadFileRequest);
      debugPrint(
          'Listing Upload File Response -> ${uploadFileResponse.FileStorageId}');
      selectedCoverImage = SelectedImageModel(
          serverId: uploadFileResponse.FileStorageId!, image: pickedFile);
    } on CommonException catch (error) {
      if (error.code == 400) {
        Map<String, dynamic> errorModel = jsonDecode(error.message);
        if (errorModel.containsKey('ModelState')) {
          Map<String, dynamic> modelState = errorModel['ModelState'];
          if (modelState.containsKey('ErrorMessage')) {
            setError(error: modelState['ErrorMessage'][0]);
          } else {
            setError(
                error:
                    'We\'re unable to connect to server. Please contact administrator or try after some time');
          }
        } else {
          setError(
              error:
                  'We\'re unable to connect to server. Please contact administrator or try after some time');
        }
      } else {
        setError(
            error:
                'We\'re unable to connect to server. Please contact administrator or try after some time');
      }
      debugPrint(error.message);
    } on NoConnectivityException catch (_) {
      setError(error: Constants.internetConnectionErrorMsg);
    } catch (error) {
      setError(
          error:
              'We\'re unable to connect to server. Please contact administrator or try after some time');
    }
  }

  bool validateSecondStep() {
    bool result = true;
    if (galleryImages.isEmpty) {
      setError(error: "Please upload at least one Gallery Image");
      notifyListeners();
      return false;
    } else if (selectedCoverImage == null) {
      setError(error: "Please upload Cover Image");
      notifyListeners();
      return false;
    } else if (!(secondStepFormKey.currentState!.validate())) {
      return false;
    }
    return result;
  }

  ////////////////////////////////////////////////// Step 3 ////////////////////////////////////////////////

  FacilitySetupState setupState = FacilitySetupState.ideal;
  final thirdStepFormKey = GlobalKey<FormState>();
  bool isSameRates = false;
  final hourlyRateController = TextEditingController();
  String? savedSetupId;

  void onToggleSameRatesSwitch(bool value) {
    // after added slots when toggle remove slots - nehal ma'am
    hideKeyboard();
    isSameRates = value;
    hourlyRateController.clear();
    addedTimeSlotList.clear();
    notifyListeners();
  }

  //////////////////////////////////////////////// Add Slot variables ////////////////////////////////////////////////

  BookingSlotSheetState bookingSlotSheetState = BookingSlotSheetState.ideal;

  final slotFormKey = GlobalKey<FormState>();

  List<AddTimeSlotModel> addedTimeSlotList = [];
  List<AddTimeSlotModel> editTimeSlotList = [];

  FacilityPreviewModel? facilityPreview;

  final List<String> popularTimes = [
    '06:00',
    '08:00',
    '10:00',
    '14:00',
    '16:00',
    '18:00',
    '20:00'
  ];

  final List<String> popularDurations = [ 
    '01:00',
    '01:15',
    '01:30',
    '01:45',
    '02:00',
    '02:15',
    '02:30'
  ];

  final List<GridViewItemModel> days = [
    GridViewItemModel(id: 1, imagePath: "", title: "Mon"),
    GridViewItemModel(id: 2, imagePath: "", title: "Tue"),
    GridViewItemModel(id: 3, imagePath: "", title: "Wed"),
    GridViewItemModel(id: 4, imagePath: "", title: "Thu"),
    GridViewItemModel(id: 5, imagePath: "", title: "Fri"),
    GridViewItemModel(id: 6, imagePath: "", title: "Sat"),
    GridViewItemModel(id: 0, imagePath: "", title: "Sun"),
  ];

  List<GridViewItemModel> _selectedDays = [];

  List<GridViewItemModel> get selectedDays => _selectedDays;

  void toggleDay(GridViewItemModel day) {
    if (_selectedDays.contains(day)) {
      _selectedDays = List.from(_selectedDays)..remove(day);
    } else {
      _selectedDays = List.from(_selectedDays)..add(day);
    }
    notifyListeners();
  }

  void setStartTime(String time, int index) {
    hideKeyboard();
    final currentAddedTime = editTimeSlotList[index].startTime.text;
    if (currentAddedTime == time) return;
    editTimeSlotList[index].startTimeControllerKey.currentState?.setTime(time);
  }

  void setRentalDuration(String duration) {
    hideKeyboard();
    final currentDuration = rentalDurationController.text.trim();
    if (currentDuration == duration) return;
    
    // Store previous duration before changing
    storePreviousRentalDuration();
    
    // Set the new duration
    rentalDurationController.text = duration;
    
    // Check if there are existing slots and trigger slot clearing if needed
    if (addedTimeSlotList.isNotEmpty) {
      // This will be handled by the UI layer through a callback
      _shouldShowClearSlotsDialog = true;
    }
    
    notifyListeners();
  }

  // Flag to indicate when slots clearing dialog should be shown
  bool _shouldShowClearSlotsDialog = false;
  bool get shouldShowClearSlotsDialog => _shouldShowClearSlotsDialog;
  
  void clearShouldShowClearSlotsDialogFlag() {
    _shouldShowClearSlotsDialog = false;
  }

  void clearSelectionOfAddTimeBottomSheet() {
    _selectedDays.clear();
    editTimeSlotList.clear();
    if (!isSameRates) {
      hourlyRateController.clear();
    }
    notifyListeners();
  }

  void onClickOfAddTimeSlot() {
    hideKeyboard();
    if (_selectedDays.isEmpty) {
      setError(error: "Please select at least one booking day");
      notifyListeners();
      return;
    }
    if (!isSameRates && (!(slotFormKey.currentState?.validate() ?? false))) {
      return;
    }
    if (editTimeSlotList.isEmpty) {
      setError(error: "Please add at least one booking slot");
      notifyListeners();
      return;
    }
    for (var element in editTimeSlotList) {
      if (element.startTime.text.isEmpty) {
        setError(error: "Please select/enter start time in current entry");
        notifyListeners();
        return;
      } else if (element.startTimeControllerKey.currentState?.hasError ??
          true) {
        return;
      } else if ((!(element.formKey.currentState?.validate() ?? false))) {
        return;
      }
      if (!(slotFormKey.currentState?.validate() ?? false)) {
        return;
      }
      element.selectedDays.clear();
      element.selectedDays.addAll(_selectedDays);
      element.ratePerHour = double.tryParse(hourlyRateController.text.trim());
    }
    isSlotsChanged = true;
    addedTimeSlotList.addAll(editTimeSlotList);
    clearSelectionOfAddTimeBottomSheet();
    bookingSlotSheetState = BookingSlotSheetState.hide;
    isSlotTimeChangeRequestAccepted = false;
    notifyListeners();
  }

  void onTapAddBookingSlot() {
    hideKeyboard();
    if (selectedDays.isEmpty) {
      setError(error: "Please select at least one booking day");
      notifyListeners();
      return;
    }
    if (editTimeSlotList.isEmpty) {
      editTimeSlotList.add(
        AddTimeSlotModel(
          selectedDays: [],
          formKey: GlobalKey<FormState>(),
          startTime: TextEditingController(),
          numberOfSlots: TextEditingController(),
          perSlotDuration: getRentalDurationInHours(),
          startTimeControllerKey: GlobalKey<TimeInputFieldState>(),
        ),
      );
    } else {
      for (var element in editTimeSlotList) {
        if (element.startTime.text.isEmpty) {
          setError(error: "Please select/enter start time in current entry");
          notifyListeners();
          return;
        } else if ((!(element.formKey.currentState?.validate() ?? false))) {
          return;
        }
      }
      editTimeSlotList.add(
        AddTimeSlotModel(
          selectedDays: [],
          formKey: GlobalKey<FormState>(),
          startTime: TextEditingController(),
          numberOfSlots: TextEditingController(),
          perSlotDuration: getRentalDurationInHours(),
          startTimeControllerKey: GlobalKey<TimeInputFieldState>(),
        ),
      );
    }
    notifyListeners();
  }

  void onClearSession(int index) {
    editTimeSlotList.removeAt(index);
    notifyListeners();
  }

  void onRemoveAddedSlot(int index) {
    addedTimeSlotList.removeAt(index);
    isSlotsChanged = true;
    notifyListeners();
  }

  void clearNumberOfSlots(AddTimeSlotModel editSlot) {
    editSlot.numberOfSlots.clear();
    notifyListeners();
  }

  double tempSlotRates = 0.0;

  void setupApiCall() {
    final bookingType = (selectedBookingType?.id == 1) ? "I" : "G";
    Map addFacility = {};
    List<Map> slotList = [];
    tempSlotRates = addedTimeSlotList.first.ratePerHour ?? 0.00;
    for (int i = 0; i < addedTimeSlotList.length; i++) {
      Map slotMap = {};
      final slotsModel = addedTimeSlotList[i];
      slotMap['DayNos'] =
          slotsModel.sortedSelectedDays.map((element) => element.id).toList();
      slotMap['StartTimeInMinute'] = slotsModel.startTimeInMinutes;
      slotMap['NoOfSlot'] = slotsModel.tempNumberOfSlots;
      slotMap['EndTimeInMinute'] = slotsModel.endTimeInMinutes;
      slotMap['RatePerHour'] = slotsModel.ratePerHour;
      tempSlotRates = tempSlotRates < slotsModel.ratePerHour!
          ? tempSlotRates
          : slotsModel.ratePerHour!;
      slotList.add(slotMap);
    }
    List<Map> facilityImagesList = [];
    for (int i = 0; i < galleryImages.length; i++) {
      Map map = {};
      map['FileStorageId'] = galleryImages[i].serverId;
      map['FileName'] = '';
      map['FilePath'] = '';
      map['FileExtension'] = '';
      map['FileBase64'] = '';
      facilityImagesList.add(map);
    }
    addFacility['FacilitySetupId'] =
        isEdit ? getFacilityByIdModel?.facilitySetupId : 0;
    addFacility['FacilityProviderId'] = OQDOApplication.instance.facilityID;
    addFacility['Title'] = titleController.text.toString().trim();
    addFacility['SubTitle'] = subTitleController.text.toString().trim();
    addFacility['Description'] = descriptionController.text.toString().trim();
    DateTime now = DateTime.now();
    String formattedDate =
        DateFormat("yyyy-MM-dd'T'HH:mm:ss.SSS'Z'").format(now);
    debugPrint(formattedDate);
    addFacility['EffectiveDate'] = formattedDate;
    addFacility['ListingPageImageId'] = selectedCoverImage?.serverId;
    addFacility['SubactivityId'] =
        selectedSubActivity?.SubActivityId.toString();
    addFacility['BookingType'] = (selectedBookingType?.id == 1) ? "I" : "G";
    addFacility['SlotTimeMinute'] = getRentalDurationInMinutes();
    addFacility['RatePerHour'] = isSameRates
        ? double.parse(hourlyRateController.text.trim().isEmpty
            ? "0"
            : hourlyRateController.text.trim())
        : null;
    addFacility['FacilityCapacity'] =
        bookingType == "I" ? capacityController.text.toString().trim() : "1";
    addFacility["FacilitySetupDaySlotDtos"] = slotList;
    addFacility["FacilityImages"] = facilityImagesList;
    addFacility["FacilitySetupPrvReviewDtos"] = [];
    addFacility['IsSameSlotRate'] = isSameRates;
    addFacility['MaxGroupSize'] = bookingType == "G"
        ? int.parse(capacityController.text.trim().isEmpty
                    ? "0"
                    : capacityController.text.trim()) ==
                0
            ? null
            : int.parse(capacityController.text.trim().isEmpty
                ? "0"
                : capacityController.text.trim())
        : null;
    debugPrint("Create Facility Request ===> ${json.encode(addFacility)}");
    callAddFacilitySetup(addFacility);
    facilityPreview = FacilityPreviewModel(
      title: titleController.text.trim(),
      subTitle: subTitleController.text.trim(),
      activity: selectedActivity?.Name ?? "",
      subActivity: selectedSubActivity?.Name ?? "",
      description: descriptionController.text.trim(),
      slotDuration: getFormattedDurationForDisplay(),
      rentalDurationInMinutes: getRentalDurationInMinutes(),
      slotRate: tempSlotRates,
      maxCapacityOrGroupSize: capacityController.text.trim(),
      isPrivateRental: bookingType == "I",
      slotsList: addedTimeSlotList,
    );
  }

  Future<void> callAddFacilitySetup(Map addFacility) async {
    setLoaderState(state: LoaderState.showLoader);
    notifyListeners();
    try {
      String response = "";
      if (isEdit) {
        response = await _facilitySetupRepo.editFacilitySetup(addFacility);
      } else {
        response = await _facilitySetupRepo.addFacilitySetup(addFacility);
      }
      debugPrint('callAddFacilitySetup -> $response');
      if (response.isNotEmpty) {
        setInfo(info: 'Setup ${isEdit ? "updated" : "added"} successfully');
        savedSetupId = response;
        // After successful save/edit, fetch latest data and show preview
        await _fetchFacilityDataAndShowPreview(response);
      } else {
        setError(
            error:
                'We\'re unable to connect to server. Please contact administrator or try after some time');
        setLoaderState(state: LoaderState.hideLoader);
        notifyListeners();
      }
    } on CommonException catch (error) {
      debugPrint(error.toString());
      if (error.code == 400) {
        Map<String, dynamic> errorModel = jsonDecode(error.message);
        if (errorModel.containsKey('ModelState')) {
          Map<String, dynamic> modelState = errorModel['ModelState'];
          if (modelState.containsKey('ErrorMessage')) {
            setError(error: modelState['ErrorMessage'][0] ?? "");
          } else {
            setError(
                error:
                    'We\'re unable to connect to server. Please contact administrator or try after some time');
          }
        } else {
          setError(
              error:
                  'We\'re unable to connect to server. Please contact administrator or try after some time');
        }
      } else {
        setError(
            error:
                'We\'re unable to connect to server. Please contact administrator or try after some time');
      }
      setLoaderState(state: LoaderState.hideLoader);
      notifyListeners();
    } on NoConnectivityException catch (_) {
      setError(error: Constants.internetConnectionErrorMsg);
      setLoaderState(state: LoaderState.hideLoader);
      notifyListeners();
    } catch (error) {
      debugPrint(error.toString());
      setError(
          error:
              'We\'re unable to connect to server. Please contact administrator or try after some time');
      setLoaderState(state: LoaderState.hideLoader);
      notifyListeners();
    }
  }

  ///////////////////////////////////////// EDIT TIME Variables & Methods ////////////////////////////////////

  String? previousPrice;
  String? previousCapacity;
  int? previousBookingTypeId;
  String? previousSlotDuration;

  bool isPriceChanged = false;
  bool isCapacityChanged = false;
  bool isBookingTypeChanged = false;
  bool isSlotDurationChanged = false;
  bool isSlotsChanged = false;

  Future<void> setFacilityData(
      GetFacilityByIdModel? getFacilityByIdModel) async {
    if (getFacilityByIdModel == null) return;
    setLoaderState(state: LoaderState.showLoader);
    notifyListeners();
    await getAllActivity(showLoader: false);
    selectedActivity = activityList
        .where(
            (element) => element.ActivityId == getFacilityByIdModel.activityId)
        .firstOrNull;
    subActivityList = selectedActivity?.SubActivities ?? [];
    subActivityHint = "";
    selectedSubActivity = subActivityList
        .where((element) =>
            element.SubActivityId == getFacilityByIdModel.subActivityId)
        .firstOrNull;
    isEdit = true;
    titleController.text = getFacilityByIdModel.title ?? "";
    subTitleController.text = getFacilityByIdModel.subTitle ?? "";
    descriptionController.text = getFacilityByIdModel.description ?? "";
    selectedBookingType = bookingTypes
        .where((element) =>
            element.id == ((getFacilityByIdModel.bookingType == "I") ? 1 : 2))
        .first;
    previousBookingTypeId = selectedBookingType?.id;
    isSameRates = getFacilityByIdModel.isSameSlotRate ?? false;
    if (isSameRates) {
      hourlyRateController.text =
          getFacilityByIdModel.ratePerHour?.toStringAsFixed(2) ?? "";
      previousPrice = hourlyRateController.text.trim();
    }else {
      previousPrice =  "";
    }
    final durationMinutes = int.tryParse(getFacilityByIdModel.slotTimeMinute?.toString() ?? "") ?? 0;
    setRentalDurationFromMinutes(durationMinutes);
    previousSlotDuration = rentalDurationController.text.trim();
    capacityController.text =
      getFacilityByIdModel.bookingType == "I" ? getFacilityByIdModel.facilityCapacity?.toString() ?? "" : getFacilityByIdModel.maxGroupSize?.toString() ?? "";
    previousCapacity = capacityController.text.trim();
    selectedCoverImage = SelectedImageModel(
      serverId: getFacilityByIdModel.listingPageImageId ?? 0,
      editTimeImageUrl: getFacilityByIdModel.listingPageImage ?? "",
    );
    galleryImages.clear();
    getFacilityByIdModel.facilitySetupImages?.forEach((element) {
      galleryImages.add(SelectedImageModel(
        serverId: element.fileStorageId ?? 0,
        editTimeImageUrl: element.filePath ?? "",
      ));
    });
    addedTimeSlotList.clear();
    getFacilityByIdModel.slots?.forEach((element) async {
      addedTimeSlotList.add(
        AddTimeSlotModel(
          selectedDays: await _getSelectedDaysOfSlot(element.dayNos),
          startTime: TextEditingController(text: element.startTimeFormatted),
          formKey: GlobalKey<FormState>(),
          numberOfSlots:
              TextEditingController(text: element.noOfSlot?.toString() ?? ""),
          perSlotDuration:
              (((int.tryParse(element.slotTimeMinute?.toString() ?? "") ?? 0) /
                      60)
                  .round()),
          startTimeControllerKey: GlobalKey<TimeInputFieldState>(),
          ratePerHour: element.ratePerHour,
        ),
      );
    });
    if (getFacilityByIdModel.slots?.isNotEmpty ?? false) {
      isSlotTimeChangeRequestAccepted = false;
    }
    setLoaderState(state: LoaderState.hideLoader);
    await Future.delayed(const Duration(milliseconds: 250));
    notifyListeners();
  }

  Future<List<GridViewItemModel>> _getSelectedDaysOfSlot(
      List<int>? addedDaysList) async {
    if (addedDaysList?.isEmpty ?? true) return [];
    return days.where((day) => addedDaysList!.contains(day.id)).toList();
  }

  Future<void> checkForChanges() async {
    if (previousPrice != hourlyRateController.text.trim()) {
      isPriceChanged = true;
    }
    if (previousCapacity != capacityController.text.trim()) {
      isCapacityChanged = true;
    }
    if (previousBookingTypeId != selectedBookingType?.id) {
      isBookingTypeChanged = true;
    }
    if (previousSlotDuration != rentalDurationController.text.trim()) {
      isSlotDurationChanged = true;
    }
  }

  void updateBasicInfo() async {
    setLoaderState(state: LoaderState.showLoader);
    notifyListeners();
    Map request = {};
    request['FacilitySetupId'] = getFacilityByIdModel?.facilitySetupId;
    request['Title'] = titleController.text.toString().trim();
    request['SubTitle'] = subTitleController.text.toString().trim();
    request['Description'] = descriptionController.text.toString().trim();
    request['ListingPageImageId'] = selectedCoverImage?.serverId;
    List<Map> facilityImagesList = [];
    for (int i = 0; i < galleryImages.length; i++) {
      Map map = {};
      map['FileStorageId'] = galleryImages[i].serverId;
      map['FileName'] = '';
      map['FilePath'] = '';
      map['FileExtension'] = '';
      map['FileBase64'] = '';
      facilityImagesList.add(map);
    }
    request['FacilityImages'] = facilityImagesList;

    final bookingType = (selectedBookingType?.id == 1) ? "I" : "G";
    facilityPreview = FacilityPreviewModel(
      title: titleController.text.trim(),
      subTitle: subTitleController.text.trim(),
      activity: selectedActivity?.Name ?? "",
      subActivity: selectedSubActivity?.Name ?? "",
      description: descriptionController.text.trim(),
      slotDuration: getFormattedDurationForDisplay(),
      rentalDurationInMinutes: getRentalDurationInMinutes(),
      slotRate: tempSlotRates,
      maxCapacityOrGroupSize: capacityController.text.trim(),
      isPrivateRental: bookingType == "I",
      slotsList: addedTimeSlotList,
    );

    try {
      String response =
          await _facilitySetupRepo.updateFacilityBasicInfo(request);
      debugPrint('callEditFacilitySetup -> $response');
      if (response.isNotEmpty) {
        setInfo(info: 'Facility updated successfully');
        // After successful update, fetch latest data and show preview
        await _fetchFacilityDataAndShowPreview(getFacilityByIdModel?.facilitySetupId.toString() ?? "");
      } else {
        setError(
            error:
                'We\'re unable to connect to server. Please contact administrator or try after some time');
        setLoaderState(state: LoaderState.hideLoader);
        notifyListeners();
      }
    } on CommonException catch (error) {
      if (error.code == 400) {
        Map<String, dynamic> errorModel = jsonDecode(error.message);
        if (errorModel.containsKey('ModelState')) {
          Map<String, dynamic> modelState = errorModel['ModelState'];
          if (modelState.containsKey('ErrorMessage')) {
            setError(error: modelState['ErrorMessage'][0] ?? "");
          } else {
            setError(
                error:
                    'We\'re unable to connect to server. Please contact administrator or try after some time');
          }
        } else {
          setError(
              error:
                  'We\'re unable to connect to server. Please contact administrator or try after some time');
        }
      } else {
        setError(
            error:
                'We\'re unable to connect to server. Please contact administrator or try after some time');
      }
      setLoaderState(state: LoaderState.hideLoader);
      notifyListeners();
    } on NoConnectivityException catch (_) {
      setError(error: Constants.internetConnectionErrorMsg);
      setLoaderState(state: LoaderState.hideLoader);
      notifyListeners();
    } catch (error) {
      setError(
          error:
              'We\'re unable to connect to server. Please contact administrator or try after some time');
      setLoaderState(state: LoaderState.hideLoader);
      notifyListeners();
    }
  }

  /// Fetch facility data by setup ID and show preview
  Future<void> _fetchFacilityDataAndShowPreview(String apiResponse) async {
    try {
      int? setupId;
      
      // Determine the setup ID based on edit mode or parse from response
      if (isEdit && apiResponse.isNotEmpty) {
        setupId = int.tryParse(apiResponse);
      } else {
        // For create mode, try to parse the setup ID from the response
        setupId = int.tryParse(apiResponse);
      }
      
      if (setupId != null) {
        // Call getFacilityById API to get latest data
        GetFacilityByIdModel updatedFacilityData = await _facilitySetupRepo.getFacilityById(setupId);
        
        // Convert to FacilityPreviewModel
        facilityPreview = _convertToFacilityPreviewModel(updatedFacilityData);
        
        setupState = FacilitySetupState.success;
        setLoaderState(state: LoaderState.hideLoader);
        notifyListeners();
      } else {
        setError(error: 'Unable to fetch facility data. Please try again.');
        setLoaderState(state: LoaderState.hideLoader);
        notifyListeners();
      }
    } on CommonException catch (error) {
      debugPrint('Error fetching facility data: ${error.toString()}');
      setError(error: 'We\'re unable to fetch the latest data. Please contact administrator or try after some time');
      setLoaderState(state: LoaderState.hideLoader);
      notifyListeners();
    } on NoConnectivityException catch (_) {
      setError(error: Constants.internetConnectionErrorMsg);
      setLoaderState(state: LoaderState.hideLoader);
      notifyListeners();
    } catch (error) {
      debugPrint('Error fetching facility data: ${error.toString()}');
      setError(error: 'We\'re unable to fetch the latest data. Please contact administrator or try after some time');
      setLoaderState(state: LoaderState.hideLoader);
      notifyListeners();
    }
  }

  /// Convert GetFacilityByIdModel to FacilityPreviewModel
  FacilityPreviewModel _convertToFacilityPreviewModel(GetFacilityByIdModel model) {
    // Calculate slot rate - use minimum rate from slots or ratePerHour
    double slotRate = 0.0;
    if (model.slots?.isNotEmpty == true) {
      slotRate = model.slots!.map((slot) => slot.ratePerHour ?? 0.0).reduce((a, b) => a < b ? a : b);
    } else if (model.ratePerHour != null) {
      slotRate = model.ratePerHour!;
    }

    // Convert slots to AddTimeSlotModel list
    List<AddTimeSlotModel> slotsList = [];
    if (model.slots?.isNotEmpty == true) {
      for (final slot in model.slots!) {
        if (slot.dayNos?.isNotEmpty == true) {
          final selectedDaysList = slot.dayNos!
              .map((dayNo) => days.firstWhere((day) => day.id == dayNo, orElse: () => GridViewItemModel(id: dayNo, imagePath: "", title: "")))
              .where((day) => day.title.isNotEmpty)
              .toList();

          final startTimeController = TextEditingController();
          if (slot.startTimeFormatted != null) {
            startTimeController.text = slot.startTimeFormatted!;
          } else if (slot.startTimeInMinute != null) {
            final hours = slot.startTimeInMinute! ~/ 60;
            final minutes = slot.startTimeInMinute! % 60;
            startTimeController.text = '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}';
          }

          final numberOfSlotsController = TextEditingController();
          if (slot.noOfSlot != null) {
            numberOfSlotsController.text = slot.noOfSlot.toString();
          }

          final timeSlot = AddTimeSlotModel(
            selectedDays: selectedDaysList,
            formKey: GlobalKey<FormState>(),
            startTime: startTimeController,
            numberOfSlots: numberOfSlotsController,
            perSlotDuration: (model.slotTimeMinute ?? 60) ~/ 60, // Convert minutes to hours
            startTimeControllerKey: GlobalKey<TimeInputFieldState>(),
            ratePerHour: slot.ratePerHour,
            startTimeFormatted: slot.startTimeFormatted,
            endTimeFormatted: slot.endTimeFormatted,
          );

          slotsList.add(timeSlot);
        }
      }
    }

    // Format duration for display
    String formattedDuration = '';
    if (model.slotTimeMinute != null) {
      final hours = model.slotTimeMinute! ~/ 60;
      final minutes = model.slotTimeMinute! % 60;
      if (minutes == 0) {
        formattedDuration = '${hours}h';
      } else {
        formattedDuration = '${hours}h ${minutes}m';
      }
    }

    return FacilityPreviewModel(
      title: model.title ?? '',
      subTitle: model.subTitle ?? '',
      activity: model.activityName ?? '',
      subActivity: model.subActivityName ?? '',
      description: model.description ?? '',
      slotDuration: formattedDuration,
      rentalDurationInMinutes: model.slotTimeMinute ?? 60,
      slotRate: slotRate,
      maxCapacityOrGroupSize: model.bookingType == 'I' 
          ? (model.facilityCapacity?.toString() ?? '1')
          : (model.maxGroupSize?.toString() ?? '1'),
      isPrivateRental: model.bookingType == 'I',
      slotsList: slotsList,
    );
  }
}
