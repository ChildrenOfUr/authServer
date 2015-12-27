library authServer;

import "dart:io";
import 'dart:async';
import 'dart:convert';

import "package:args/args.dart";
import "package:http/http.dart" as http;
import "package:redstone/redstone.dart" as app;
import 'package:redstone_mapper/plugin.dart';
import 'package:redstone_mapper/mapper.dart';
import 'package:redstone_mapper_pg/manager.dart';
import 'package:uuid/uuid.dart';
import "package:authServer/session.dart";
import 'package:mailer/mailer.dart';
import 'package:path/path.dart' as path;

import '../API_KEYS.dart';
export '../API_KEYS.dart';
//for the test suite

part '../lib/auth.dart';

part '../lib/data.dart';

part '../lib/user.dart';

part '../lib/metabolics.dart';

part '../lib/verify_handler.dart';

Map<String, Session> SESSIONS = {};
Uuid uuid = new Uuid();
ArgResults argResults;
bool loadCert = true;
PostgreSqlManager dbManager;

File verifiedOutputFile, errorOutputFile;
String verifiedOutput, errorOutput;

Future main(List<String> arguments) async {
    //setup command line argument parsing
    final parser = new ArgParser()
    //use --no-load-cert to ignore certification loading
        ..addFlag("load-cert", defaultsTo: true, help: "Enables certificate loading for certificate")
        ..addOption("port", defaultsTo: "8383", help: "Port to run the server on");

    argResults = parser.parse(arguments);
    loadCert = argResults['load-cert'];

    int port;
    try {
        port = int.parse(argResults['port']);
    }
    catch (error) {
        port = 8383;
    }

    //try to parse ENV var
    if (Platform.environment['AUTH_PORT'] != null &&
        Platform.environment['AUTH_PORT'].isNotEmpty) {
        try {
            port = int.parse(Platform.environment['AUTH_PORT']);
        }
        catch (error) {
            port = 8383;
        }
    }

    dbManager = new PostgreSqlManager(databaseUri, min: 1, max: 9);
    app.addPlugin(getMapperPlugin(dbManager));

    if (loadCert) {
        try {
            SecurityContext context = new SecurityContext()
                ..useCertificateChain('$certPath/fullchain.pem')
                ..usePrivateKey('$certPath/privkey.pem');
            app.setupConsoleLog();
            app.start(port: port, autoCompress: true, secureOptions: {#context: context});
        } catch (error) {
            print("Unable to start server with signed certificate: $error");
        }
    }
    else {
        //start up server in non-cert-certified developer mode
        app.setupConsoleLog();
        app.start(port: port);
    }

    VerifyHandler.init();

    String currentDir = path.dirname(Platform.script.path);
    verifiedOutputFile = new File("$currentDir/output_verified.html");
    errorOutputFile = new File("$currentDir/output_error.html");

    verifiedOutput = await (verifiedOutputFile.readAsString());
    errorOutput = await (errorOutputFile.readAsString());
}

//add a CORS header to every request
@app.Interceptor(r'/.*')
handleCORS() async {
    if (app.request.method != "OPTIONS") {
        await app.chain.next();
    }
    return app.response.change(headers: {
        "Access-Control-Allow-Origin": "*",
        "Access-Control-Allow-Headers": "Origin, X-Requested-With, Content-Type, Accept"
    });
}

PostgreSql get dbConn => app.request.attributes.dbConn;

@app.Route('/serverStatus')
Map getServerStatus() {
    Map statusMap = {};
    try {
        statusMap['status'] = "OK";
        statusMap['loadCert'] = loadCert;
    }
    catch (e) {
        logMessage("Error getting server status: $e");
    }
    return statusMap;
}

void logMessage(String message) {
    print("(${new DateTime.now().toString()}) $message");
}