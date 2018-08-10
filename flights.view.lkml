view: flights {
  sql_table_name: faa.flights ;;

  #####################
  ## Original Columns
  #####################

  dimension: id {
    hidden: yes
    primary_key: yes
    type: number
    sql: ${TABLE}.id2 ;;
  }

  dimension: flight_num {
    hidden: yes
    type: string
    sql: ${TABLE}.flight_num ;;
  }

  dimension: tail_num {
    hidden: yes
    type: string
    sql: ${TABLE}.tail_num ;;
  }

  dimension: carrier {
    type: string
    sql: ${TABLE}.carrier ;;
    drill_fields: [origin, destination]
  }

  dimension_group: dep {
    type: time
    timeframes: [
      raw,
      time,
      hour_of_day,
      date,
      month,
      year
    ]
    sql: ${TABLE}.dep_time ;;
  }

  dimension: dep_delay {
    type: number
    sql: ${TABLE}.dep_delay ;;
  }

  dimension_group: arr {
    type: time
    timeframes: [
      raw,
      time,
      date,
      month,
      year
    ]
    sql: ${TABLE}.arr_time ;;
  }

  dimension: origin {
    type: string
    sql: ${TABLE}.origin ;;
    drill_fields: [carrier, destination]
  }

  dimension: destination {
    type: string
    sql: ${TABLE}.destination ;;
    drill_fields: [carrier, origin]
  }

  dimension: route {
    type: string
    sql: concat(${origin}, '-', ${destination} )  ;;
    drill_fields: [carrier, origin, destination]
  }

  #####################
  ## % Delays
  #####################

  parameter: minutes_delayed {
    type: number
    default_value: "15"
  }

  dimension: is_flight_delayed {
    type: yesno
    sql: ${dep_delay} >= {% parameter minutes_delayed %} ;;
    drill_fields: [route, distance_tiers]
  }

  measure: count_delayed_flights {
    type: count
    filters: {
      field: is_flight_delayed
      value: "Yes"
    }
    drill_fields: [drill*]
  }

  measure: percent_flights_delayed {
    type: number
    description: "Count of Delayed Flights out of Total Flights"
    sql: 1.0 * ${count_delayed_flights} / nullif(${flight_count},0) ;;
    html: {{ rendered_value }} = {{ count_delayed_flights._rendered_value }} Delays / {{ flight_count._rendered_value }} Total ;;
    value_format_name: percent_2
    link: {
      label: "More information here"
      url: "https://drive.google.com/file/d/1Z-vnLla82zHQT0h1lrltTxJBx8dQduHU/view"
      icon_url: "http://www.looker.com/favicon.ico"
    }
    drill_fields: [drill*]
  }

  #####################
  ## Distance
  #####################

  dimension: destination_location {
    view_label: "Destination"
    type: location
    sql_latitude:${destination.latitude} ;;
    sql_longitude:${destination.longitude} ;;
    drill_fields: [destination.full_name]
  }

  dimension: origin_location {
    view_label: "Origin"
    type: location
    sql_latitude:${origin.latitude} ;;
    sql_longitude:${origin.longitude} ;;
    drill_fields: [origin.full_name]
  }

  dimension: route_distance {
    label: "Route Distance (Miles)"
    type: distance
    start_location_field: origin_location
    end_location_field: destination_location
    units: miles
    drill_fields: [distance_tiers]
  }

  dimension: distance_tiers {
    label: "Distance Tiers (Miles)"
    type: tier
    tiers: [250, 500, 1000, 1500]
    style: integer
    sql: ${route_distance} ;;
    drill_fields: [route_distance]
  }

  measure: average_distance {
    label: "Average Distance (Miles)"
    type: average
    sql: ${route_distance} ;;
    drill_fields: [drill*]
    value_format_name: decimal_1
  }

  #####################
  ## Flight Length
  #####################

  dimension: flight_length {
    type: number
    sql: datetime_diff(cast(${arr_raw} as datetime), cast(${dep_raw} as datetime), minute) ;;
    description: "Minutes between arrival and departure time (excludes taxi-time)"
  }

  dimension: flight_length_tier {
    label: "Flight Length Tier (Minutes)"
    type: tier
    sql: ${flight_length} ;;
    tiers: [60,120,180]
    style: integer
    drill_fields: [flight_length]
  }

  measure: average_flight_length {
    label: "Average Flight Length (Minutes)"
    type: average
    sql: ${flight_length} ;;
    drill_fields: [drill*]
    value_format_name: decimal_1
  }

  measure: flight_count {
    type: count
    drill_fields: [drill*]
  }

  set: drill {
    fields: [
      carriers.nickname,
      origin,
      count_delayed_flights,
      flight_count
    ]
  }

  ## Mergers

  dimension: updated_carrier {
    description: "Accounts for 2013 American-US Air, 2008 Delta-NW, 2005 US Air - AM West Mergers"
    type: string
    sql:
        CASE
          WHEN ${carrier} = 'US' and ${dep_date} > '2013-06-01' then 'AA' --2013 Ameirican - US Air Merger
          WHEN ${carrier} = 'NW' and ${dep_date} > '2008-09-01' then 'DL' --2008 Delta - Northwest Merger
          WHEN ${carrier} = 'HP' and ${dep_date} > '2005-10-01' then 'US' --2013 US Air - Am West Merger
          else ${carrier}
        END ;;
    drill_fields: [origin, destination]
  }
}
