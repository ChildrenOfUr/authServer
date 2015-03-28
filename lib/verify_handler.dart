part of authServer;

class VerifyHandler
{
	static init() async
	{
		HttpServer server = await HttpServer.bind('0.0.0.0', 8484);

		server.listen((HttpRequest request)
		{
			WebSocketTransformer.upgrade(request).then((WebSocket websocket)
			{
				if(request.uri.path == "/awaitVerify")
					handle(websocket);
			})
			.catchError((error)
			{
				logMessage("error: $error");
			},
			test: (Exception e) => e is! WebSocketException)
			.catchError((error){},test: (Exception e) => e is WebSocketException);
		});
	}

	static handle(WebSocket ws)
	{
		ws.listen((message)
		{
			Map m = JSON.decode(message);
			String email = m['email'];
			AuthService.pendingVerifications[email] = ws;
		},
		onError: (err)
		{
			print("couldn't get email from message: $err");
		});
	}
}