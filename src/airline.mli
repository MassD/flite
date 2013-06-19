type t = 
    {
      name : string;
      code : string;
      http : string
    }

val to_bson : t -> Bson.t
val of_bson : Bson.t -> t

val get_http_from_name : string -> string
