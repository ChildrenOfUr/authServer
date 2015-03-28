library authServer;

import "dart:io";
import 'dart:async';
import 'dart:convert';
import 'dart:math';

import "package:args/args.dart";
import "package:http/http.dart" as http;
import "package:redstone/server.dart" as app;
import 'package:redstone_mapper/plugin.dart';
import 'package:redstone_mapper/mapper.dart';
import 'package:redstone_mapper_pg/manager.dart';
import 'package:shelf/shelf.dart' as shelf;
import 'package:uuid/uuid.dart';
import "package:authServer/session.dart";
import 'package:mailer/mailer.dart';

import '../API_KEYS.dart';
export '../API_KEYS.dart'; //for the test suite

part '../lib/auth.dart';
part '../lib/data.dart';
part '../lib/user.dart';
part '../lib/metabolics.dart';
part '../lib/verify_handler.dart';

Map<String,Session> SESSIONS = {};
Uuid uuid = new Uuid();
ArgResults argResults;
bool loadCert = true;
PostgreSqlManager dbManager;

void main(List<String> arguments)
{
  //setup command line argument parsing
  final parser = new ArgParser()
  //use --no-load-cert to ignore certification loading
    ..addFlag("load-cert", defaultsTo: true, help: "Enables certificate loading for certificate")
    ..addOption("port", defaultsTo:"8383", help: "Port to run the server on");

  argResults = parser.parse(arguments);
  loadCert = argResults['load-cert'];

	int port;
	try	{port = int.parse(argResults['port']);}
	catch(error){port = 8383;}

	//try to parse ENV var
	if (Platform.environment['AUTH_PORT'] != null &&
	    Platform.environment['AUTH_PORT'].isNotEmpty)
	{
	  try {port = int.parse(Platform.environment['AUTH_PORT']);}
	  catch (error){port = 8383;}
	}

	dbManager = new PostgreSqlManager(databaseUri, min: 1, max: 9);
	app.addPlugin(getMapperPlugin(dbManager));

	if (loadCert)
	{
	  try
	  {
		SecureSocket.initialize(database: "sql:./certdb", password: certdbPassword);
	    app.setupConsoleLog();
	    app.start(port:port, autoCompress:true, secureOptions: {#certificateName: certName});
	  } catch (error) {print("Unable to start server with signed certificate: $error");}
	}
	else
	{
	  //start up server in non-cert-certified developer mode
	  app.setupConsoleLog();
	  app.start(port:port);
	}

	VerifyHandler.init();
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

@app.Route('/serverStatus')
Map getServerStatus()
{
  Map statusMap = {};
  try
  {
    statusMap['status'] = "OK";
    statusMap['loadCert'] = loadCert;
  }
  catch(e){logMessage("Error getting server status: $e");}
  return statusMap;
}


@app.Route('/restartGameServer', methods: const[app.POST])
Future<String> restartServer(@app.Body(app.JSON) Map params) async
{
	String secret = params['secret'];
	if(secret == restartSecret)
	{
		try
		{
			ProcessResult result = await Process.run("/bin/sh",["restart_server.sh"]);
			if(result.exitCode == 0)
				return "OK";
			else
				return "ERROR RESTARTING SERVER";
		}
		catch(e){logMessage("Error restarting server: $e"); return "ERROR";}
	}
	else
		return "NOT AUTHORIZED";
}

void logMessage(String message)
{
  print("(${new DateTime.now().toString()}) $message");
}
_createCorsHeader() => {"Access-Control-Allow-Origin": "*","Access-Control-Allow-Headers": "Origin, X-Requested-With, Content-Type, Accept"};
