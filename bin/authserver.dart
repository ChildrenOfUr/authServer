library authServer;

import "dart:io";
import 'dart:async';
import 'dart:convert';
import 'dart:math';

import "package:http/http.dart" as http;
import "package:redstone/server.dart" as app;

part "../KEYS.dart";
part "auth.dart";

void main()
{
	int port = 8383;
	try	{port = int.parse(Platform.environment['AUTH_PORT']);}
	catch (error){port = 8383;}

	SecureSocket.initialize(database: "sql:./certdb", password: certdbPassword);
	app.setupConsoleLog();
	app.start(port:8383, autoCompress:true, secureOptions: {#certificateName: "robertmcdermot.com"});
}