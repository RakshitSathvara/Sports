class ChatListRequestModel {
  final bool isBuyer;
  final int pageStart;
  final int resultPerPage;
  final String? searchQuery;

  ChatListRequestModel({
    required this.isBuyer,
    required this.pageStart,
    required this.resultPerPage,
    this.searchQuery,
  });

  Map<String, dynamic> toJson() {
    return {
      'IsBuyer': isBuyer,
      'pageStart': pageStart,
      'resultPerPage': resultPerPage,
      'seachquery': searchQuery,
    };
  }
}