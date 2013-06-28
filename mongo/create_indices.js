db.getCollection("journeys").ensureIndex( { id:1, dep_utime:1, ret_utime:1, airline:1, last_fsed:1, dep_ap:1, arr_ap:1 } );

db.getCollection("alerts").ensureIndex( { journey_id:1, user:1, email:1, frequency:1 } )

db.getCollection("prices").ensureIndex( { journey_id:1, airline:1, last_checked:1 } )

db.getCollection("airlines").ensureIndex( { name:1, code:1 } )
