<a name="shift.components.module_typeahead"></a>
## typeahead
Typeahead directive displaying a set of option to choose from as input changes.


| Param | Type | Description |
| --- | --- | --- |
| sources | <code>array</code> | Source of options to be filtered by the input |
| filterAttribute | <code>string</code> | Name of the attribute for the filter |
| selected | <code>object</code> | Object selected within the source |

**Example**  
```jade
shift-typeahead(
  sources = "list_of_object"
  filterAttribute = "city"
  selected = "selected_option"
)
```
