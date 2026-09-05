class RewardCoinsHistoryModel {
  bool? status;
  String? message;
  List<Data>? data;

  RewardCoinsHistoryModel({this.status, this.message, this.data});

  RewardCoinsHistoryModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    if (json['data'] != null) {
      data = <Data>[];
      json['data'].forEach((v) {
        data!.add(new Data.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['status'] = this.status;
    data['message'] = this.message;
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Data {
  String? sId;
  String? userId;
  String? videoId;
  String? movieSeries;
  int? type;
  int? coin;
  int? rewardCoinUsed;
  int? purchasedCoinUsed;
  int? adCoinUsed;
  int? dailyCoinUsed;
  int? loginCoinUsed;
  int? price;
  int? offerPrice;
  String? paymentGateway;
  String? uniqueId;
  String? date;
  String? createdAt;
  String? updatedAt;

  Data(
      {this.sId,
      this.userId,
      this.videoId,
      this.movieSeries,
      this.type,
      this.coin,
      this.rewardCoinUsed,
      this.purchasedCoinUsed,
      this.adCoinUsed,
      this.dailyCoinUsed,
      this.loginCoinUsed,
      this.price,
      this.offerPrice,
      this.paymentGateway,
      this.uniqueId,
      this.date,
      this.createdAt,
      this.updatedAt});

  Data.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    userId = json['userId'];
    videoId = json['videoId'];
    movieSeries = json['movieSeries'];
    type = json['type'];
    coin = json['coin'];
    rewardCoinUsed = json['rewardCoinUsed'];
    purchasedCoinUsed = json['purchasedCoinUsed'];
    adCoinUsed = json['adCoinUsed'];
    dailyCoinUsed = json['dailyCoinUsed'];
    loginCoinUsed = json['loginCoinUsed'];
    price = json['price'];
    offerPrice = json['offerPrice'];
    paymentGateway = json['paymentGateway'];
    uniqueId = json['uniqueId'];
    date = json['date'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['_id'] = this.sId;
    data['userId'] = this.userId;
    data['videoId'] = this.videoId;
    data['movieSeries'] = this.movieSeries;
    data['type'] = this.type;
    data['coin'] = this.coin;
    data['rewardCoinUsed'] = this.rewardCoinUsed;
    data['purchasedCoinUsed'] = this.purchasedCoinUsed;
    data['adCoinUsed'] = this.adCoinUsed;
    data['dailyCoinUsed'] = this.dailyCoinUsed;
    data['loginCoinUsed'] = this.loginCoinUsed;
    data['price'] = this.price;
    data['offerPrice'] = this.offerPrice;
    data['paymentGateway'] = this.paymentGateway;
    data['uniqueId'] = this.uniqueId;
    data['date'] = this.date;
    data['createdAt'] = this.createdAt;
    data['updatedAt'] = this.updatedAt;
    return data;
  }
}
