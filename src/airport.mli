type t = 
    {
      country : string;
      name : string;
      code : string;
    };;

module AirportSet: (Set.S with type elt = t);;

val get_all: unit -> AirportSet.t;;

val to_bson: t -> Bson.t;;
val of_bson: Bson.t -> t;;
