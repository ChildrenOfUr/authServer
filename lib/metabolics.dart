part of authServer;

class Metabolics {
    @Field(model: "user_id") int userId = -1;
    @Field() int energy = 50;
    @Field(model: "max_energy") int maxEnergy = 100;
    @Field() int mood = 50;
    @Field(model: "max_mood") int maxMood = 100;
    @Field() int currants = 0;
    @Field() int img = 0;
    @Field(model: "lifetime_img") int lifetimeImg = 0;
    @Field(model: "current_street") String currentStreet = 'LIF12PMQ5121D68';
    @Field(model: "current_street_x") num currentStreetX = 1.0;
    @Field(model: "current_street_y") num currentStreetY = 0.0;
}
