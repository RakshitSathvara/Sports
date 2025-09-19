import 'package:flutter/material.dart';
import 'package:oqdo_mobile_app/screens/setup/coach_setup/viewmodel/create_coach_view_model.dart';
import 'package:oqdo_mobile_app/screens/setup/facility_setup/view/widgets/base_container.dart';
import 'package:oqdo_mobile_app/screens/setup/facility_setup/view/widgets/setup_grid_view_item.dart';
import 'package:oqdo_mobile_app/utils/colorsUtils.dart';
import 'package:oqdo_mobile_app/utils/constants.dart';
import 'package:oqdo_mobile_app/utils/custom_text_field.dart';
import 'package:provider/provider.dart';

class CoachStepOne extends StatelessWidget {
  const CoachStepOne({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildMessageListener(),
          _buildTitleAndSessionTitleView(context),
          _buildChooseYourActivityView(context),
          _buildChooseTrainingTypeView(context),
        ],
      ),
    );
  }

  Widget _buildMessageListener() {
    return Consumer<CreateCoachViewModel>(
      builder: (context, viewModel, _) {
        if (viewModel.getError.isNotEmpty) {
          final message = viewModel.getError;
          viewModel.setError();
          WidgetsBinding.instance.addPostFrameCallback((_) {
            showSnackBar(message, context);
          });
        }
        if (viewModel.getInfo.isNotEmpty) {
          final message = viewModel.getInfo;
          viewModel.setInfo();
          WidgetsBinding.instance.addPostFrameCallback((_) {
            showSnackBar(message, context);
          });
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildTitleAndSessionTitleView(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 5.0),
        Text(
          "Activity & Type Setup",
          style: TextStyle(
            fontFamily: 'SFPro',
            color: ColorsUtils.primary,
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 15.0),
        BaseContainer(
          child: Form(
            key: context.read<CreateCoachViewModel>().firstStepFormKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Session Title",
                  style: TextStyle(
                    fontFamily: 'Montserrat',
                    color: ColorsUtils.chipText,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 15.0),
                CommonTextField(
                  controller: context.read<CreateCoachViewModel>().titleController,
                  maxLength: 50,
                  fillColor: ColorsUtils.white,
                  borderRadius: 6,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  hint: "Enter session title",
                  labelText: "Session Title",
                  textStyle: TextStyle(
                    fontSize: 16,
                    fontFamily: "Inter",
                    color: ColorsUtils.black,
                    fontWeight: FontWeight.w500,
                  ),
                  validator: (value) {
                    if (value?.isEmpty ?? true) {
                      return "Please enter Session Title";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 10.0),
                Text(
                  "Give your training session a memorable title",
                  style: TextStyle(
                    fontFamily: 'Inter',
                    color: ColorsUtils.hintTextColor,
                    fontWeight: FontWeight.w400,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        )
      ],
    );
  }

  Widget _buildChooseYourActivityView(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 20),
        BaseContainer(
          bgColor: ColorsUtils.white,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 5),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    "Choose Your Activity",
                    style: TextStyle(
                      fontFamily: 'Montserrat',
                      color: ColorsUtils.chipText,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
                    decoration: BoxDecoration(borderRadius: BorderRadius.circular(20.0), color: ColorsUtils.green.withValues(alpha: 0.15)),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.check,
                          color: ColorsUtils.green,
                          size: 16,
                        ),
                        const SizedBox(width: 5),
                        Text(
                          context.watch<CreateCoachViewModel>().selectedActivityName,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: ColorsUtils.green,
                            fontFamily: 'Montserrat',
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 15),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: context.watch<CreateCoachViewModel>().subActivityList.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(mainAxisSpacing: 15.0, crossAxisSpacing: 15.0, crossAxisCount: 2, childAspectRatio: 2),
                itemBuilder: (context, index) {
                  final item = context.read<CreateCoachViewModel>().subActivityList[index];
                  final isSelected = context.watch<CreateCoachViewModel>().selectedSubActivity?.SubActivityId == item.SubActivityId;
                  return SetupGridViewItem(
                    title: item.Name ?? "",
                    imagePath: item.imageUrl ?? "",
                    useLocalImage: false,
                    isSelected: isSelected,
                    isEnabled: !context.read<CreateCoachViewModel>().isEdit,
                    onTap: () => context.read<CreateCoachViewModel>().onSelectActivity(item),
                  );
                },
              ),
              const SizedBox(height: 10.0),
              Text(
                "Give your training session a memorable title",
                style: TextStyle(
                  fontFamily: 'Inter',
                  color: ColorsUtils.hintTextColor,
                  fontWeight: FontWeight.w400,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildChooseTrainingTypeView(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 20),
        BaseContainer(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 5),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    "Training Type",
                    style: TextStyle(
                      fontFamily: 'Montserrat',
                      color: ColorsUtils.chipText,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 15),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: context.read<CreateCoachViewModel>().trainingTypes.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(mainAxisSpacing: 15.0, crossAxisSpacing: 15.0, crossAxisCount: 2, childAspectRatio: 2),
                itemBuilder: (context, index) {
                  final item = context.watch<CreateCoachViewModel>().trainingTypes[index];
                  final isSelected = context.watch<CreateCoachViewModel>().selectedTrainingType?.id == item.id;
                  return SetupGridViewItem(
                    title: item.title,
                    unSelectedColor: ColorsUtils.white,
                    imagePath: item.imagePath,
                    isSelected: isSelected,
                    isEnabled: true,
                    onTap: () => context.read<CreateCoachViewModel>().onSelectTrainingType(item),
                  );
                },
              ),
              const SizedBox(height: 10.0),
              Text(
                (context.watch<CreateCoachViewModel>().selectedTrainingType?.id == 2)
                    ? "Booking by a single person for them or a group of people up to max group size stored in setup."
                    : "Multiple individuals can book separately up to set capacity.",
                style: TextStyle(
                  fontFamily: 'Inter',
                  color: ColorsUtils.hintTextColor,
                  fontWeight: FontWeight.w400,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
