<a name="shift.components.module_sortable"></a>
## sortable
Sortable directive to allow drag n' drop sorting of an array of object


| Param | Type | Description |
| --- | --- | --- |
| shiftSortable | <code>array</code> | Array of sortable object |
| shiftSortableChange | <code>function</code> | Called when order is changed |

**Example**  
```jade
ul
  li(
    ng-repeat = "element in list"
    shift-sortable = "list"
    shift-sortable-change = "onListOrderChange"
  ) {{ element.name }}
```
