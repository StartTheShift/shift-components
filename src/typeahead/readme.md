<a name="shift.components.module_typeahead"></a>
## typeahead
Typeahead directive displaying a set of option to choose from as input changes.

The transcluded object attributes are prepend with `option.`. In the case of the
example, the sources are

```coffee
$scope.sources = [
  {state: 'ca', city: 'Los Angeles', population: 3884307}
  ...
]
```

in the transcluded template section, you would then access the population information
through `{{ option.population }}`


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
  selected = "selected_city"
)
  strong {{option.city}}
  span &nbsp; {{option.state}}
  div
    i pop. {{option.population}}
```
