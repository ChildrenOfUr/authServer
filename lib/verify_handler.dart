part of authServer;

class VerifyHandler {
	static init() async {
		HttpServer server = await HttpServer.bind('0.0.0.0', 8484);

		server.listen((HttpRequest request) async {
			try {
				WebSocket websocket = await WebSocketTransformer.upgrade(request);
				if(request.uri.path == "/awaitVerify") {
					handle(websocket);
				}
			} catch(e) {
				if(e is! WebSocketException) {
					logMessage("error: $error");
				}
			}
		});
	}

	static handle(WebSocket ws) {
		ws.listen((message) {
			Map m = JSON.decode(message);
			String email = m['email'];
			AuthService.pendingVerifications[email] = ws;
		},
		          onError: (err) {
			          print("couldn't get email from message: $err");
		          });
	}
}