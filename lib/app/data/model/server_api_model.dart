class ServerApi {
  String? id;
  String? serverName;
  String? baseUrl;
  String? path;
  String? status;

  ServerApi({this.id, this.serverName, this.baseUrl, this.path, this.status});

  ServerApi.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    serverName = json['server_name'];
    baseUrl = json['base_url'];
    path = json['path'];
    status = json['status'];
  }

 Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['server_name'] = serverName;
    data['base_url'] = baseUrl;
    data['path'] = path;
    data['status'] = status;
    return data;
  }
}
