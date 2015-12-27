part of authServer;

class Metabolics {
    @Field() int mood = 50, max_mood = 100, energy = 50, max_energy = 100, currants = 0;
    @Field() int img = 0, lifetime_img = 0, user_id = -1;
    @Field() String current_street = 'LIF12PMQ5121D68';
    @Field() num current_street_x = 1.0, current_street_y = 0.0;
}