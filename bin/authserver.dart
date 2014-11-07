library authServer;

import "dart:io";
import 'dart:async';
import 'dart:convert';
import 'dart:math';

import "package:http/http.dart" as http;
import "package:redstone/server.dart" as app;
import 'package:shelf/shelf.dart' as shelf;
import 'package:uuid/uuid.dart';

part "../API_KEYS.dart";
part "auth.dart";
part "data.dart";
part 'session.dart';

Map<String,Session> SESSIONS = {};
Uuid uuid = new Uuid();

void main()
{
	int port = 8383;
	try	{port = int.parse(Platform.environment['AUTH_PORT']);}
	catch (error){port = 8383;}

	SecureSocket.initialize(database: "sql:./certdb", password: certdbPassword);
	app.setupConsoleLog();
	app.start(port:8383, autoCompress:true, secureOptions: {#certificateName: "robertmcdermot.com"});
}

//add a CORS header to every request
@app.Interceptor(r'/.*')
crossOriginInterceptor()
{
	if (app.request.method == "OPTIONS")
	{
		//overwrite the current response and interrupt the chain.
		app.response = new shelf.Response.ok(null, headers: _createCorsHeader());
		app.chain.interrupt();
	}
	else
	{
  	//process the chain and wrap the response
		app.chain.next(() => app.response.change(headers: _createCorsHeader()));
	}
}

_createCorsHeader() => {"Access-Control-Allow-Origin": "*","Access-Control-Allow-Headers": "Origin, X-Requested-With, Content-Type, Accept"};