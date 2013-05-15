type airport = 
    {
      country : string;
      name : string;
      code : string;
    };;

module AirportSet: (Set.S with type elt = airport);;

val get_between: char -> char -> AirportSet.t;;
val get_all: unit -> AirportSet.t;;

val to_bson: airport -> Bson.t;;
val of_bson: Bson.t -> airport;;
