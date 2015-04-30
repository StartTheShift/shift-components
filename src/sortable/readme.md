<a name="shift.components.module_sortable"></a>
## sortable
Sortable directive to allow drag n' drop sorting of an array.


| Param | Type | Description |
| --- | --- | --- |
| shiftSortable | <code>array</code> | Array of sortable object |
| shiftSortableChange | <code>function</code> | Called when order is changed |

**Example**  
```jade
ul(
  shift-sortable = "list_of_object"
  shift-sortable-change = "onListOrderChange(list_of_object)"
)
  li(ng-repeat = "element in list_of_object") {{ element.name }}
```
