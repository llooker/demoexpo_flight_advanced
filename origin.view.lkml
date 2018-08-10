view: origin {
  sql_table_name: faa.airports ;;

  dimension: id {
    primary_key: yes
    type: number
    sql: ${TABLE}.id ;;
  }

  dimension: code {
    type: string
    sql: ${TABLE}.code ;;
  }

  dimension: cntl_twr {
    type: string
    sql: ${TABLE}.cntl_twr ;;
  }

  dimension: full_name {
    type: string
    sql: ${TABLE}.full_name ;;
  }

  dimension: elevation {
    type: number
    sql: ${TABLE}.elevation ;;
  }

  dimension: latitude {
    type: number
    sql: ${TABLE}.latitude ;;
  }

  dimension: longitude {
    type: number
    sql: ${TABLE}.longitude ;;
  }

  dimension: city {
    hidden: yes
    type: string
    sql: ${TABLE}.city ;;
  }

  dimension: state {
    type: string
    sql: ${TABLE}.state ;;
    drill_fields: [city, full_name, code]
    map_layer_name: us_states
  }

  dimension: region {
    type: string
    case: {
      when: {
        sql: ${state} in ('WA','OR','CA','NV','UT','WY','ID','MT','CO','AK','HI') ;;
        label: "West"
      }
      when: {
        sql: ${state} in ('AZ','NM','TX','OK') ;;
        label: "Southwest"
      }
      when: {
        sql: ${state} in ('ND','SD','MN','IA','WI','MN','OH','IN','MO','NE','KS','MI','IL') ;;
        label: "Midwest"
      }
      when: {
        sql: ${state} in ('MD','DE','NJ','CT','RI','MA','NH','PA','NY','VT','ME','DC') ;;
        label: "Northeast"
      }
      when: {
        sql: ${state} in ('AR','LA','MS','AL','GA','FL','SC','NC','VA','TN','KY','WV') ;;
        label: "Southeast"
      }
      else: "Unknown"
    }
    drill_fields: [state, code]
  }

  dimension: city_full {
    label: "City"
    type: string
    sql: concat(${city}, ', ', ${state}) ;;
    drill_fields: [state, full_name, code]
  }

  measure: count_airports {
    type: count
    drill_fields: [id, full_name]
  }
}
