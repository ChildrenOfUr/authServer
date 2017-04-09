part of authServer;

class Metabolics {
    @Field() int userId = -1;
    @Field() int energy = 50, maxEnergy = 100;
    @Field() int mood = 50, maxMood = 100;
    @Field() int currants = 0;
    @Field() int img = 0, lifetimeImg = 0;
    @Field() String currentStreet = 'LIF12PMQ5121D68';
    @Field() num currentStreetX = 1.0, currentStreetY = 0.0;
}