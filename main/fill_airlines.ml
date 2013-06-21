open Flite_type.Airline

let query_code a_code = Bson.add_element "code" (Bson.create_string a_code) (Bson.empty)

let airline_to_mongo a m =
  let rf = Mongo.find_q_one m (query_code a.code) in
  if MongoReply.get_num_returned rf = 0l then 
    Mongo.insert m [(to_bson a)]


let airlines_to_mongo csv_file () =
  try
    let csv = Csv.load ~separator:',' csv_file in
    let mongo = Mongo.create_local_default "flite" "airlines" in
    let process_row row = 
      let a = {
	name =  String.lowercase (List.nth row 1);
	code =  String.lowercase (List.nth row 0);
	http =  String.lowercase (List.nth row 2)
      } in
      airline_to_mongo a mongo
    in 
    List.iter process_row csv
  with Csv.Failure(nrow, nfield, err) ->
    Printf.printf "The file %S line %i, field %i, does not conform to the CSV \
      specifications: %s\n" csv_file nrow nfield err;
    failwith "failed"


let command =
  (* [Command.basic] is used for creating a command.  Every command takes a text
     summary and a command line spec *)
  Core.Std.Command.basic
    ~summary:"Write airlines from a csv to mongodb"
    (* Command line specs are built up component by component, using a small
       combinator library whose operators are contained in [Command.Spec] *)
    Core.Std.Command.Spec.(
      empty
      +> flag "-csv" (required string) 
        ~doc:"The file path of the csv"
    )
    (* The command-line spec determines the argument to this function, which
       show up in an order that matches the spec. *)
    airlines_to_mongo

let () = Core.Std.Command.run command
