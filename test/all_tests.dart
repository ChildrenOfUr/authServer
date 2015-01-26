//import all the test files
import 'authserver_test.dart' as authserver_test;
import 'auth_test.dart' as auth_test;
import 'data_test.dart' as data_test;

//Run all the tests from each test file
void main()
{
	authserver_test.main();
	auth_test.main();
	data_test.main();
}