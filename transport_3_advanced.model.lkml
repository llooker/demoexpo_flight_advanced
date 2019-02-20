connection: "lookerdata"

include: "*.view.lkml"         # include all views in this project
# include: "*.dashboard.lookml"  # include all dashboards in this project

explore: flights {

  label: "Flights - Advanced"

  from: flights_advanced

  sql_always_where: ${flight_length} > 0 and ${flight_length} < 2000 ;;

  ## Note: default value is "American" (AA)
  access_filter: {
    field: carriers.nickname
    user_attribute: carrier_name
  }

  join: origin {
    relationship: many_to_one
    sql_on: ${flights.origin} = ${origin.code} ;;
  }

  join: destination {
    relationship: many_to_one
    sql_on: ${flights.destination} = ${destination.code} ;;
  }

  join: carriers  {
    relationship: many_to_one
    sql_on: ${flights.carrier} = ${carriers.code} ;;
  }

  join: values_by_carrier_by_origin {
    relationship: many_to_one
    sql_on:   ${flights.carrier} = ${values_by_carrier_by_origin.carrier}
      AND ${flights.origin} = ${values_by_carrier_by_origin.origin};;
  }
}
