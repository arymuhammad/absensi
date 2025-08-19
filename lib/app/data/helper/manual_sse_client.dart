import 'dart:async';
import 'dart:convert';
import 'dart:io';

/// SSE client manual yang hanya mengeluarkan data string
/// dari event 'data:' yang diterima.
/// SSE URL harus server yang sudah support SSE.
class ManualSseClient {
  final Uri uri;
  HttpClient? _httpClient;
  HttpClientRequest? _request;
  HttpClientResponse? _response;

  StreamController<String>? _controller;

  ManualSseClient(this.uri);

  /// Mulai koneksi SSE dan kembalikan stream data event sebagai string
  Stream<String> connect() {
    _controller = StreamController<String>(
      onCancel: () => _closeConnection(),
    );

    _httpClient = HttpClient();
    _httpClient!.getUrl(uri).then((request) {
      _request = request;
      // Set header SSE wajib
      request.headers.set(HttpHeaders.acceptHeader, 'text/event-stream');
      return request.close();
    }).then((response) {
      _response = response;
      // Mendengarkan stream isi respons secara baris
      // lalu parse SSE sederhana
      _listenToResponseStream(response);
    }).catchError((error) {
      _controller?.addError(error);
      _closeConnection();
    });

    return _controller!.stream;
  }

  void _listenToResponseStream(HttpClientResponse response) {
  final linesStream = response.transform(utf8.decoder).transform(const LineSplitter());

  linesStream.listen((line) {
    if (line.startsWith('data: ')) {
      final data = line.substring(6).trim();
      if (data.isNotEmpty) {
        _controller?.add(data);  // langsung emit data
      }
    }
    // abaikan baris kosong atau baris lain (id, retry)
  }, onError: (error) {
    _controller?.addError(error);
    _closeConnection();
  }, onDone: () {
    _controller?.close();
    _closeConnection();
  });
}


  /// Parse isi event SSE sederhana: ambil isi baris yang diawali 'data: '
  String? _parseEvent(String rawEvent) {
    // Contoh event:
    // id: 1
    // data: {"hadir":6,"tepat_waktu":5,"telat":1}
    // (bisa ada banyak baris data, tapi ambil semua data: concat)
    final dataLines = rawEvent
        .split('\n')
        .where((line) => line.startsWith('data: '))
        .map((line) => line.substring(6).trim())
        .toList();

    if (dataLines.isEmpty) return null;
    return dataLines.join('\n');
  }

  void _closeConnection() {
    _response?.detachSocket().then((socket) {
      socket.destroy();
    }).catchError((_) {});
    _httpClient?.close(force: true);
    _controller?.close();
  }
}
