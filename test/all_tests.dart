//import all the test files
import 'package:test/test.dart';
import 'package:redstone/redstone.dart' as app;
import 'dart:convert';
import "package:authServer/session.dart";
import "../bin/authserver.dart" as server;

//Run all the tests from each test file
void main() {
	group('authserver_test', () {
		//load handlers in 'authServer' library
		setUp(() => app.redstoneSetUp([#authServer]));

		//remove all loaded handlers
		tearDown(() => app.redstoneTearDown());

		test("GET server status", () {
			//create a mock request
			var req = new app.MockRequest("/serverStatus");
			//dispatch the request
			return app.dispatch(req).then((resp) {
				//verify the response
				expect(resp.statusCode, equals(200));
				var content = JSON.decode(resp.mockContent);
				expect(content, containsPair("status", "OK"));
				expect(content, containsPair("loadCert", true));
			});
		});
	});
	group('auth_test', () {
		//load handlers in 'authServer' library
		setUp(() => app.redstoneSetUp([#authServer]));

		//remove all loaded handlers
		tearDown(() => app.redstoneTearDown());

		test("POST verifyEmail error", () {
			//create a mock request
			var req = new app.MockRequest("/auth/verifyEmail",
			                              method: app.POST,
			                              bodyType: app.JSON, body: {});
			//dispatch the request
			return app.dispatch(req).then((resp) {
				//verify the response
				expect(resp.statusCode, equals(200));
				var content = JSON.decode(resp.mockContent);
				expect(content, containsPair("ok", "no"));
			});
		});

		test("POST logout session", () {
			//create a mock request
			var req = new app.MockRequest("/auth/logout",
			                              method: app.POST,
			                              bodyType: app.JSON, body: {
				"session": "Test token"
			});
			//dispatch the request
			return app.dispatch(req).then((resp) {
				//verify the response
				expect(resp.statusCode, equals(200));
				var content = JSON.decode(resp.mockContent);
				expect(content, containsPair("ok", "yes"));
			});
		});
	});
}
