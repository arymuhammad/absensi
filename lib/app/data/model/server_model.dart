class Srv {
  String? id;
  String? server;

  Srv({this.id, server});

  Srv.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    server = json['server'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['server'] = server;
    return data;
  }
}