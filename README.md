#Children of Ur Auth Server#

##What is this?##
This repository contains the source code for Children of Ur's Dart-based
 login and authentication server.
The project is currently hosted at <a href="http://childrenofur.com" target="_blank">childrenofur.com</a>.

Children of Ur is based on Tiny Speck's browser-based game, Glitch™. The original game's elements have been released into the public domain.
For more information on the original game and its licensing information, visit <a href="http://www.glitchthegame.com" target="_blank">glitchthegame.com</a>.

This was split off from the main CoU server for reasons of stability and separation of tasks.

##Getting Started##
1. Download the <a href="https://www.dartlang.org/">Dart Editor</a>
2. In the Dart Editor, go to File -> "Open Existing Folder" and open this project folder
3. Make sure you have the required dependencies specified in pubspec.yaml. If you're missing
any of these, try selecting a file in the project, and then running Tools > Pub Get.

##Running##
1. To run the server, you will have to create an 'API_KEYS.dart' file in the top-level
folder. Directions can be found in the developer docs 
<a href="https://github.com/ChildrenOfUr/coUclient/blob/master/doc/api.md" target="_blank">here.</a>
You will need to change the line at the top of the file from `part of couServer;` to `part of authServer;`.
2. After that, right-click on the `bin/authserver.dart` file and select Run to start the server on your
local machine. 
3. If you do not have a signed cert and cert password, you will have to supply the option
`--no-load-cert` on the command line or in the Dart Editor run configuration.
4. Go to `http://localhost:8383/serverStatus` to test that your server is returning data. See `server.dart`
for other routes.

##Testing##
1. To run the tests, you can either type `dart test/all_tests.dart` from the command line,
or right-click on `test/all_tests.dart` and select 'Run.'

[ ![Codeship Status for ChildrenOfUr/authServer](https://codeship.com/projects/92b72790-459b-0132-ec31-26eabbfbacd1/status?branch=master)](https://codeship.com/projects/45064)
