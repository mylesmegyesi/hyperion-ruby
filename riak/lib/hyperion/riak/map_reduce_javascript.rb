module Hyperion
  module Riak
    VALUE_MAP = <<-REDUCE
      function(value, key, arg) {
        var data = Riak.mapValuesJson(value)[0];
        data.riak_key = value.key;
        return [data];
      }
    REDUCE

    FILTER_REDUCTION = <<-REDUCE
      function(values, arg) {
        var field = arg.field;
        var value = arg.value;
        return values.reduce(function(acc, record) {
          var fieldValue = record[field];
          switch(arg.operator) {
            case "<":
              if (fieldValue < value) {
                acc.push(record);
              }
              break;
            case "<=":
              if (fieldValue <= value) {
                acc.push(record);
              }
              break;
            case ">":
              if (fieldValue > value) {
                acc.push(record);
              }
              break;
            case ">=":
              if (fieldValue >= value) {
                acc.push(record);
              }
              break;
            case "=":
              if (fieldValue == value) {
                acc.push(record);
              }
              break;
            case "!=":
              if (fieldValue !== value) {
                acc.push(record);
              }
              break;
            case "contains?":
              for (i in value) {
                if (fieldValue == value[i]) {
                  acc.push(record);
                  break;
                }
              }
              break;
          }
          return acc;
        }, []);
      }
    REDUCE

    SORT_REDUCTION = <<-REDUCE
      function(values, sorts) {
        return values.sort(function(record1, record2) {
          for (i in sorts) {
            var sort = sorts[i];
            var field = sort.field;
            var order = sort.order;
            var field1 = record1[field];
            var field2 = record2[field];
            if (field1 !== field2) {
              if ((field1 < field2) && (order == "asc")) {
                return -1;
              } else if ((field1 > field2) && (order == "desc")) {
                return -1;
              } else {
                return 1;
              }
            }
          }
          return 0;
        });
      }
    REDUCE

    OFFSET_REDUCTION = <<-REDUCE
      function(values, offset) {
        return values.slice(offset, values.length);
      }
    REDUCE

    LIMIT_REDUCTION = <<-REDUCE
      function(values, limit) {
        return values.slice(0, limit);
      }
    REDUCE

    COUNT_REDUCTION = <<-REDUCE
      function(values) {
        return [values.length];
      }
    REDUCE

    PASS_THRU_REDUCTION = <<-REDUCE
      function(values) {
        return values;
      }
    REDUCE
  end
end
