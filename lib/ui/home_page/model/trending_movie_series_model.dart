import 'dart:convert';

// TrendingMovieSeriesModel trendingMovieSeriesModelFromJson(String str) => TrendingMovieSeriesModel.fromJson(json.decode(str));
// String trendingMovieSeriesModelToJson(TrendingMovieSeriesModel data) => json.encode(data.toJson());
//
// class TrendingMovieSeriesModel {
//   TrendingMovieSeriesModel({
//     bool? status,
//     String? message,
//     List<TrendingMoviesSeriesData>? data,
//   }) {
//     _status = status;
//     _message = message;
//     _data = data;
//   }
//
//   TrendingMovieSeriesModel.fromJson(dynamic json) {
//     _status = json['status'];
//     _message = json['message'];
//     if (json['data'] != null) {
//       _data = [];
//       json['data'].forEach((v) {
//         _data?.add(TrendingMoviesSeriesData.fromJson(v));
//       });
//     }
//   }
//   bool? _status;
//   String? _message;
//   List<TrendingMoviesSeriesData>? _data;
//   TrendingMovieSeriesModel copyWith({
//     bool? status,
//     String? message,
//     List<TrendingMoviesSeriesData>? data,
//   }) =>
//       TrendingMovieSeriesModel(
//         status: status ?? _status,
//         message: message ?? _message,
//         data: data ?? _data,
//       );
//   bool? get status => _status;
//   String? get message => _message;
//   List<TrendingMoviesSeriesData>? get data => _data;
//
//   Map<String, dynamic> toJson() {
//     final map = <String, dynamic>{};
//     map['status'] = _status;
//     map['message'] = _message;
//     if (_data != null) {
//       map['data'] = _data?.map((v) => v.toJson()).toList();
//     }
//     return map;
//   }
// }
//
// TrendingMoviesSeriesData dataFromJson(String str) => TrendingMoviesSeriesData.fromJson(json.decode(str));
// String dataToJson(TrendingMoviesSeriesData data) => json.encode(data.toJson());
//
// class TrendingMoviesSeriesData {
//   TrendingMoviesSeriesData({
//     String? id,
//     String? name,
//     String? thumbnail,
//     Category? category,
//     String? description,
//   }) {
//     _id = id;
//     _name = name;
//     _thumbnail = thumbnail;
//     _category = category;
//     _description = description;
//   }
//
//   TrendingMoviesSeriesData.fromJson(dynamic json) {
//     _id = json['_id'];
//     _name = json['name'];
//     _thumbnail = json['thumbnail'];
//     _category = json['category'] != null ? Category.fromJson(json['category']) : null;
//     _description = json['description'];
//   }
//   String? _id;
//   String? _name;
//   String? _thumbnail;
//   Category? _category;
//   String? _description;
//   TrendingMoviesSeriesData copyWith({
//     String? id,
//     String? name,
//     String? thumbnail,
//     Category? category,
//     String? description,
//   }) =>
//       TrendingMoviesSeriesData(
//         id: id ?? _id,
//         name: name ?? _name,
//         thumbnail: thumbnail ?? _thumbnail,
//         category: category ?? _category,
//         description: description ?? _description,
//       );
//   String? get id => _id;
//   String? get name => _name;
//   String? get thumbnail => _thumbnail;
//   Category? get category => _category;
//   String? get description => _description;
//
//   Map<String, dynamic> toJson() {
//     final map = <String, dynamic>{};
//     map['_id'] = _id;
//     map['name'] = _name;
//     map['thumbnail'] = _thumbnail;
//     if (_category != null) {
//       map['category'] = _category?.toJson();
//     }
//     map['description'] = _description;
//     return map;
//   }
// }
//
// Category categoryFromJson(String str) => Category.fromJson(json.decode(str));
// String categoryToJson(Category data) => json.encode(data.toJson());
//
// class Category {
//   Category({
//     String? id,
//     String? name,
//   }) {
//     _id = id;
//     _name = name;
//   }
//
//   Category.fromJson(dynamic json) {
//     _id = json['_id'];
//     _name = json['name'];
//   }
//   String? _id;
//   String? _name;
//   Category copyWith({
//     String? id,
//     String? name,
//   }) =>
//       Category(
//         id: id ?? _id,
//         name: name ?? _name,
//       );
//   String? get id => _id;
//   String? get name => _name;
//
//   Map<String, dynamic> toJson() {
//     final map = <String, dynamic>{};
//     map['_id'] = _id;
//     map['name'] = _name;
//     return map;
//   }
// }

import 'dart:convert';

TrendingMovieSeriesModel trendingMovieSeriesModelFromJson(String str) => TrendingMovieSeriesModel.fromJson(json.decode(str));

String trendingMovieSeriesModelToJson(TrendingMovieSeriesModel data) => json.encode(data.toJson());

class TrendingMovieSeriesModel {
  bool? status;
  String? message;
  List<TrendingMoviesSeriesData>? data;

  TrendingMovieSeriesModel({
    this.status,
    this.message,
    this.data,
  });

  factory TrendingMovieSeriesModel.fromJson(Map<String, dynamic> json) => TrendingMovieSeriesModel(
        status: json["status"],
        message: json["message"],
        data: json["data"] == null ? [] : List<TrendingMoviesSeriesData>.from(json["data"].map((x) => TrendingMoviesSeriesData.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "message": message,
        "data": data == null ? [] : List<dynamic>.from(data!.map((x) => x.toJson())),
      };
}

class TrendingMoviesSeriesData {
  String? id;
  String? name;
  String? thumbnail;
  Category? category;
  String? description;

  TrendingMoviesSeriesData({
    this.id,
    this.name,
    this.thumbnail,
    this.category,
    this.description,
  });

  factory TrendingMoviesSeriesData.fromJson(Map<String, dynamic> json) => TrendingMoviesSeriesData(
        id: json["_id"],
        name: json["name"],
        thumbnail: json["thumbnail"],
        category: json["category"] == null ? null : Category.fromJson(json["category"]),
        description: json["description"],
      );

  Map<String, dynamic> toJson() => {
        "_id": id,
        "name": name,
        "thumbnail": thumbnail,
        "category": category?.toJson(),
        "description": description,
      };
}

class Category {
  String? id;
  String? name;

  Category({
    this.id,
    this.name,
  });

  factory Category.fromJson(Map<String, dynamic> json) => Category(
        id: json["_id"],
        name: json["name"],
      );

  Map<String, dynamic> toJson() => {
        "_id": id,
        "name": name,
      };
}
