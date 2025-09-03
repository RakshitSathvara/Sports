import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:oqdo_mobile_app/components/custom_app_bar.dart';
import 'package:oqdo_mobile_app/oqdo_application.dart';
import 'package:oqdo_mobile_app/screens/buddies/features/buddies/data/get_all_buddies_repository.dart';
import 'package:oqdo_mobile_app/screens/buddies/features/buddies/data/model/get_all_buddies_response_model.dart';
import 'package:oqdo_mobile_app/screens/buddies/features/buddies/data/model/group_list_response.dart';
import 'package:oqdo_mobile_app/theme/oqdo_theme_data.dart';
import 'package:oqdo_mobile_app/utils/constants.dart';
import 'package:oqdo_mobile_app/utils/custom_text_view.dart';
import 'package:oqdo_mobile_app/utils/network_interceptor.dart';
import 'package:provider/provider.dart';

class AddParticipantsScreen extends StatefulWidget {
  final List<GroupFriends>? list;

  const AddParticipantsScreen({Key? key, this.list}) : super(key: key);

  @override
  _AddParticipantsScreenState createState() => _AddParticipantsScreenState();
}

class _AddParticipantsScreenState extends State<AddParticipantsScreen> {
  final TextEditingController _searchActivityController = TextEditingController();
  int pageCount = 0;
  int resultPerPage = 1000;
  int totalCount = 0;
  List<AllBuddiesModel> allBuddiesList = [];
  List<AllBuddiesModel> searchList = [];
  List<AllBuddiesModel> selectedList = [];
  bool mainLoader = true;

  @override
  void initState() {
    super.initState();

    // print(widget.list!.length);
    for (int i = 0; i < widget.list!.length; i++) {
      AllBuddiesModel tempList = AllBuddiesModel();
      tempList.friendId = widget.list![i].friendId;
      tempList.firstName = widget.list![i].displayFirstName;
      tempList.lastName = widget.list![i].displayLastName;
      tempList.profileImage = widget.list![i].profileImage;
      tempList.groupFriendId = widget.list![i].groupFriendId;
      tempList.isRemove = widget.list![i].isRemove;
      tempList.fromEndUserId = widget.list![i].fromEndUserId;
      tempList.againsEndUserId = widget.list![i].againsEndUserId;
      tempList.isAdmin = widget.list![i].isAdmin;
      tempList.isSelected = widget.list![i].isAdmin! ? false : true;
      selectedList.add(tempList);
    }

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      getAllBuddies('');

      searchList.clear();
      if (_searchActivityController.text.isEmpty) {
        setState(() {
          searchList.clear();
          searchList.addAll(allBuddiesList);
        });
        return;
      }

      for (var buddies in allBuddiesList) {
        if (buddies.firstName!.toLowerCase().contains(_searchActivityController.text.toLowerCase())) {
          searchList.add(buddies);
        }
      }

      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
          elevation: 0.0,
          backgroundColor: OQDOThemeData.dividerColor,
          onPressed: () {
            // print(selectedList.length);
            if (selectedList.isEmpty) {
              showSnackBar('Please select at least one friend', context);
            } else {
              Navigator.pop(context, selectedList);
            }
          },
          child: const Icon(
            Icons.done_rounded,
            color: Colors.white,
          )),
      appBar: CustomAppBar(
          title: 'Add Participant',
          onBack: () {
            Navigator.of(context).pop();
          }),
      body: SafeArea(
        child: Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          color: Colors.white,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(
                  height: 8,
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 10, left: 10, right: 10, bottom: 4),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    width: MediaQuery.of(context).size.width,
                    decoration: BoxDecoration(
                        color: const Color(0xFFF5F5F5),
                        border: Border.all(
                          color: const Color(0xFFF5F5F5),
                        ),
                        borderRadius: const BorderRadius.all(Radius.circular(10))),
                    child: SizedBox(
                      height: 38,
                      child: TextFormField(
                        autocorrect: false,
                        autofocus: false,
                        cursorColor: OQDOThemeData.greyColor,
                        minLines: 1,
                        controller: _searchActivityController,
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          icon: Image.asset(
                            'assets/images/ic_search_home.png',
                            height: 20,
                            width: 20,
                            fit: BoxFit.fill,
                          ),
                          hintText: 'Search your friends...',
                        ),
                        maxLines: 1,
                      ),
                    ),
                  ),
                ),
                // ListView.builder(
                //    physics: const AlwaysScrollableScrollPhysics(),
                //   itemCount: allBuddiesList.length,
                //   shrinkWrap: true,
                //   // controller: mScrollController,
                //   padding: const EdgeInsets.symmetric(horizontal: 10),
                //   scrollDirection: Axis.horizontal,
                //   itemBuilder: (context, index) {
                //     AllBuddiesModel allBuddiesModel = searchList[index];
                //     return chipsWidget(allBuddiesModel);
                //   },
                // ),
                // ListView(
                //   primary: true,
                //   shrinkWrap: true,
                //   scrollDirection: Axis.horizontal,
                //   children: <Widget>[
                //     Wrap(
                //       spacing: 4.0,
                //       runSpacing: 0.0,
                //       children: List<Widget>.generate(
                //           allBuddiesList.length, // place the length of the array here
                //               (int index) {
                //             return chipsWidget(allBuddiesList[index]);
                //           }
                //       ).toList(),
                //     ),
                //   ],
                // ),
                SingleChildScrollView(
                  padding: const EdgeInsets.only(left: 10),
                  scrollDirection: Axis.horizontal,
                  child: Wrap(
                    spacing: 5.0,
                    runSpacing: 8.0,
                    children: List<Widget>.generate(selectedList.length,
                        // place the length of the array here
                        (int index) {
                      return chipsWidget(selectedList[index], index);
                    }).toList(),
                  ),
                ),
                const Divider(
                  endIndent: 10,
                  indent: 10,
                  thickness: 1,
                  color: OQDOThemeData.dividerColor,
                ),
                // isSearch
                //     ? Expanded(
                //         child: ListView.separated(
                //           physics: const AlwaysScrollableScrollPhysics(),
                //           itemCount: allSearchBuddiesList.length,
                //           controller: mScrollController,
                //           padding: const EdgeInsets.symmetric(horizontal: 10),
                //           scrollDirection: Axis.vertical,
                //           itemBuilder: (context, index) {
                //             AllBuddiesModel allBuddiesModel =
                //                 allSearchBuddiesList[index];
                //             return singleBuddyView(allBuddiesModel);
                //           },
                //           separatorBuilder: (context, index) {
                //             return const Divider(
                //               height: 0.9,
                //               color: OQDOThemeData.filterDividerColor,
                //             );
                //           },
                //         ),
                //       )
                //     :
                mainLoader
                    ? const Expanded(
                        child: Center(
                          child: CircularProgressIndicator(),
                        ),
                      )
                    : Expanded(
                        child: searchList.isNotEmpty
                            ? ListView.separated(
                                physics: const AlwaysScrollableScrollPhysics(),
                                itemCount: searchList.length,
                                // controller: mScrollController,
                                padding: const EdgeInsets.symmetric(horizontal: 10),
                                scrollDirection: Axis.vertical,
                                itemBuilder: (context, index) {
                                  AllBuddiesModel allBuddiesModel = searchList[index];
                                  return singleBuddyView(allBuddiesModel);
                                },
                                separatorBuilder: (context, index) {
                                  return const Divider(
                                    height: 0.8,
                                    color: OQDOThemeData.filterDividerColor,
                                  );
                                },
                              )
                            : allBuddiesList.isEmpty
                                ? Column(
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
                                        label: 'Friends not available',
                                        textStyle: Theme.of(context)
                                            .textTheme
                                            .titleMedium!
                                            .copyWith(fontSize: 16, color: OQDOThemeData.greyColor, fontWeight: FontWeight.w500),
                                      ),
                                    ],
                                  )
                                : const SizedBox(),
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // void showLoader() {
  //   setState(() {
  //     insideListLoader = true;
  //   });
  // }
  //
  // void hideLoader() {
  //   setState(() {
  //     insideListLoader = false;
  //   });
  // }

  chipsWidget(AllBuddiesModel allBuddiesModel, int index) {
    return Chip(
        label: Text(allBuddiesModel.firstName!,
            style: Theme.of(context).textTheme.bodyMedium!.copyWith(fontSize: 14, color: OQDOThemeData.dividerColor, fontWeight: FontWeight.w500)),
        shape: const StadiumBorder(side: BorderSide(color: OQDOThemeData.dividerColor)),
        deleteIcon: allBuddiesModel.isAdmin == false
            ? Image.asset(
                "assets/images/ic_cancel_blue.png",
                fit: BoxFit.scaleDown,
                height: 12,
              )
            : const SizedBox(),
        onDeleted: () {
          allBuddiesModel.isSelected = false;
          setState(() {
            selectedList.removeAt(index);
            for (var item in allBuddiesList) {
              if (item.friendId == allBuddiesModel.friendId) {
                item.isSelected = false;
              }
            }
          });
        },
        backgroundColor: Colors.white);
  }

  Widget singleBuddyView(AllBuddiesModel allBuddiesModel) {
    // print(allBuddiesModel.isSelected);
    return GestureDetector(
      onTap: () async {
        if (allBuddiesModel.isSelected == true) {
          allBuddiesModel.isSelected = false;
          setState(() {
            selectedList.removeWhere((item) => item.friendId == allBuddiesModel.friendId);
          });
        } else {
          allBuddiesModel.isSelected = true;
          setState(() {
            selectedList.add(allBuddiesModel);
          });
        }
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Flexible(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  padding: const EdgeInsets.only(top: 10, bottom: 10, left: 4, right: 4),
                  decoration: BoxDecoration(color: allBuddiesModel.isSelected ? OQDOThemeData.buttonColor : Colors.white),
                  child: CustomTextView(
                    label: '${allBuddiesModel.firstName} ${allBuddiesModel.lastName}',
                    maxLine: 3,
                    textOverFlow: TextOverflow.ellipsis,
                    type: styleSubTitle,
                    textStyle: Theme.of(context).textTheme.titleSmall!.copyWith(
                        color: allBuddiesModel.isSelected ? Colors.white : Colors.black,
                        fontSize: 15.0,
                        fontWeight: FontWeight.w500,
                        overflow: TextOverflow.ellipsis),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> getAllBuddies(String text) async {
    setState(() {
      mainLoader = true;
    });
    try {
      String requestStr = '';

      requestStr =
          'FilterParamsDto.PageStart=$pageCount&FilterParamsDto.ResultPerPage=$resultPerPage&FilterParamsDto.EndUserId=${OQDOApplication.instance.endUserID}';
      GetAllBuddiesResponseModel getAllBuddiesResponseModel = await Provider.of<GetAllBuddiesReposotory>(context, listen: false).getAllFriendsList(requestStr);
      if (!mounted) return;
      if (getAllBuddiesResponseModel.data!.isNotEmpty) {
        showLog('Response -> ${getAllBuddiesResponseModel.data!.length}');
        // hideLoader();
        setState(() {
          allBuddiesList.addAll(getAllBuddiesResponseModel.data!);
          searchList.addAll(getAllBuddiesResponseModel.data!);

          for (int i = 0; i < selectedList.length; i++) {
            var selected = selectedList[i];
            for (int j = 0; j < searchList.length; j++) {
              if (selected.friendId == searchList[j].friendId) {
                if (selected.isAdmin == false) {
                  searchList[j].isSelected = true;
                  allBuddiesList[j].isSelected = true;
                }
              }
            }
          }

          // totalCount = getAllBuddiesResponseModel.totalCount!;
          // pageCount = pageCount + 1;
          mainLoader = false;
        });
      }
      // }
    } on CommonException catch (error) {
      showLog('common $error');
      setState(() {
        mainLoader = false;
      });
      // hideLoader();
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
      } else if (error.code == 500) {
        showSnackBarColor('We\'re unable to connect to server. Please contact administrator or try after some time', context, true);
      } else if (error.code == 404) {
        showSnackBarColor('We\'re unable to connect to server. Please contact administrator or try after some time', context, true);
      }
    } on NoConnectivityException catch (_) {
      setState(() {
        mainLoader = false;
      });
      if (!mounted) return;
      showSnackBarColor(Constants.internetConnectionErrorMsg, context, true);
    } catch (e) {
      setState(() {
        mainLoader = false;
      });
      if (!mounted) return;
      //  hideLoader();
      showLog(e.toString());
      showSnackBarErrorColor('We\'re unable to connect to server. Please contact administrator or try after some time', context, true);
    }
  }
}
