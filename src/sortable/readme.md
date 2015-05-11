<a name="shift.components.module_sortable"></a>
## sortable
Sortable directive to allow drag n' drop sorting of an array.


| Param | Type | Description |
| --- | --- | --- |
| shiftSortable | <code>array</code> | Array of sortable object |
| shiftSortableChange | <code>function</code> | Called when order is changed |
| shiftSortableHandle | <code>string</code> | CSS selector to grab the element (optional) |
| shiftSortableNamespace | <code>string</code> | Namespace for to define multiple possible source and destinations. |

**Example**  
```jade
ul(
  shift-sortable = "list_of_object"
  shift-sortable-change = "onListOrderChange(list_of_object)"
  shift-sortable-handle = ".grab-icon"
  shift-sortable-namespace = "bucket_list"
)
  li(ng-repeat = "element in list_of_object") {{ element.name }}

ul(
  shift-sortable = "list_of_object_excluded"
  shift-sortable-change = "onListOrderChange(list_of_object_excluded)"
  shift-sortable-handle = ".grab-icon"
  shift-sortable-namespace = "bucket_list"
)
  li(ng-repeat = "element in list_of_object_excluded") {{ element.name }}
```
