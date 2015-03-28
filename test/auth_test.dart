library auth_test;

import 'dart:convert';
import 'package:unittest/unittest.dart';
import 'package:redstone/server.dart' as app;
import 'package:redstone/mocks.dart';

main() {

  //load handlers in 'authServer' library
  setUp(() => app.setUp([#authServer]));

  //remove all loaded handlers
  tearDown(() => app.tearDown());

  test("POST verifyEmail error", () {
    //create a mock request
    var req = new MockRequest("/auth/verifyEmail",
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
    var req = new MockRequest("/auth/logout",
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

}