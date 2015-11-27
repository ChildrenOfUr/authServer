library data_test;

import 'dart:convert';
import 'package:unittest/unittest.dart';
import 'package:redstone/redstone.dart' as app;
import "package:authServer/session.dart";

import "../bin/authserver.dart" as server;


main() {

  //load handlers in 'authServer' library
  setUp(() => app.redstoneSetUp([#authServer]));

  //remove all loaded handlers
  tearDown(() => app.redstoneTearDown());

  test("POST street, not logged in", () {
    //create a mock request
    var req = new app.MockRequest("/data/street",
        method: app.POST,
        bodyType: app.JSON, body: {
      "sessionToken": "value1",
      "street": "LA58KK7B9O522PC"
    });
    //dispatch the request
    return app.dispatch(req).then((resp) {
      //verify the response
      expect(resp.statusCode, equals(200));
      var content = JSON.decode(resp.mockContent);
      expect(content, containsPair("ok", "no"));
      expect(content, containsPair("error", "not logged in"));
    });
  });

  test("POST street, logged in", () {
    String sessionKey = server.uuid.v1();
    Session session = new Session(sessionKey, "testuser", "testemail@whatever.com");
    server.SESSIONS[sessionKey] = session;

    //create a mock request
    var req = new app.MockRequest("/data/street",
        method: app.POST,
        bodyType: app.JSON, body: {
      "sessionToken": "$sessionKey",
      "street": "LA58KK7B9O522PC"
    });
    //dispatch the request
    return app.dispatch(req).then((resp) {
      //verify the response
      expect(resp.statusCode, equals(200));
      var content = JSON.decode(resp.mockContent);
      expect(content, containsPair("ok", "yes"));
      expect(content, containsPair("streetJSON", containsValue("Mira Mesh")));
    });
  });

}
