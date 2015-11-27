library auth_test;

import 'dart:convert';
import 'package:unittest/unittest.dart';
import 'package:redstone/redstone.dart' as app;

main() {

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

}