part of authServer;

class User
{
	@Field()
	int id;

	@Field()
	String username;

	@Field()
	String email;

	@Field()
	String bio;

	@Field()
	DateTime registration_date;
}