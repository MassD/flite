open Lwt
open Lwt_log

let mongo_section = 
  let s = Section.make "mongo" in
  Section.set_level s Warning;
  s

let flite_section =
  let s = Section.make "flite" in
  Section.set_level s Warning;
  s

let lastminute_section = 
let s = Section.make "lastminute" in
  Section.set_level s Warning;
  s

let schedule_section = 
  let s = Section.make "schedule" in
  Section.set_level s Warning;
  s

let logger = 
  Lwt_main.run 
    (
      let exist = Sys.file_exists "/var/log/flite" in
      if not exist then Unix.mkdir "/var/log/flite" 0o640;
      file 
	~template:"[$(section).$(level).$(date).($(loc-file),$(loc-line),$(loc-column))]: $(message)"
	~file_name:"/var/log/flite/flite.log" 
	()
    )

let mongo_notice_f ?exn ?location fmt = 
  ign_notice_f ?exn ~section:mongo_section ?location ~logger:logger fmt

let mongo_warning ?exn ?location fmt = 
  ign_warning_f ?exn ~section:mongo_section ?location ~logger:logger fmt

let mongo_error ?exn ?location fmt = 
  ign_error_f ?exn ~section:mongo_section ?location ~logger:logger fmt

let mongo_fatal ?exn ?location fmt = 
  ign_fatal_f ?exn ~section:mongo_section ?location ~logger:logger fmt


let flite_notice ?exn ?location fmt = 
  ign_notice_f ?exn ~section:flite_section ?location ~logger:logger fmt

let flite_warning ?exn ?location fmt = 
  ign_warning_f ?exn ~section:flite_section ?location ~logger:logger fmt

let flite_error ?exn ?location fmt = 
  ign_error_f ?exn ~section:flite_section ?location ~logger:logger fmt

let flite_fatal ?exn ?location fmt = 
  ign_fatal_f ?exn ~section:flite_section ?location ~logger:logger fmt


let lastminute_notice ?exn ?location fmt = 
  ign_notice_f ?exn ~section:lastminute_section ?location ~logger:logger fmt

let lastminute_warning ?exn ?location fmt = 
  ign_warning_f ?exn ~section:lastminute_section ?location ~logger:logger fmt

let lastminute_error ?exn ?location fmt = 
  ign_error_f ?exn ~section:lastminute_section ?location ~logger:logger fmt

let lastminute_fatal ?exn ?location fmt = 
  ign_fatal_f ?exn ~section:lastminute_section ?location ~logger:logger fmt


let schedule_notice ?exn ?location fmt = 
  ign_notice_f ?exn ~section:schedule_section ?location ~logger:logger fmt

let schedule_warning ?exn ?location fmt = 
  ign_warning_f ?exn ~section:schedule_section ?location ~logger:logger fmt

let schedule_error ?exn ?location fmt = 
  ign_error_f ?exn ~section:schedule_section ?location ~logger:logger fmt

let schedule_fatal ?exn ?location fmt = 
  ign_fatal_f ?exn ~section:schedule_section ?location ~logger:logger fmt
