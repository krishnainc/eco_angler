class Food {
  late String img;
  late String name;

  Food(
      {required this.img,
        required this.name});

  Food.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    img = json['img'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['img'] = img;
    data['name'] = name;
    return data;
  }
}