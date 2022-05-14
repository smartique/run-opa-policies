#######################
# COMMON UTIL FUNCTIONS
#######################
package utils

# Check if key exists in an object
has_key(obj, key) { 
    _ = obj[key] 
}

# Check if an element exist in an array
array_contains(arr, elem) {
  arr[_] = elem
}

# Check if a string contains a pattern
str_contains(string, pattern) {
    regex.match(pattern, string)
}

# Evaluate Expressions
eval_expression(expr, pattern) = constant_value {
    constant_value := expr.constant_value
} else = reference {
    reference := [ ref | ref = expr.references[_] ; endswith(ref, pattern)]
}

# Determine the last element in a list
last_element(list) = value {
    value := list[count(list)-1]
}

# Check if a sublist in a list has only one element
is_single (list) {
    some key
    val := list[key]
    count(val) == 1
}