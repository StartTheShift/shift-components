<a name="shift.components.module_sortable"></a>
## sortable
Sortable directive to allow drag n' drop sorting of an array of object


| Param | Type | Description |
| --- | --- | --- |
| shiftSortable | <code>array</code> | Array of sortable object |
| shiftSortableChange | <code>function</code> | Called when order is changed |
| shiftSortableFixed | <code>Boolean</code> | Set to true if the container is CSS position fixed. |

**Example**  
```jade
ul
  li(
    ng-repeat = "element in list"
    shiftSortable = "list"
  )	{{ element.name }}
```
