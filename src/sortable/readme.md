<a name="shift.components.module_sortable"></a>
## sortable
Sortable directive to allow drag n' drop sorting of an array.


| Param | Type | Description |
| --- | --- | --- |
| shiftSortable | <code>array</code> | Array of sortable object |
| shiftSortableChange | <code>function</code> | Called when order is changed |
| shiftSortableAdd | <code>function</code> | Called when an item gets added with the added item as argument (`item` keyword is mandatory) |
| shiftSortableRemove | <code>function</code> | Called when an item gets removed with the removed item as argument (`item` keyword is mandatory) |
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
  shift-sortable-add = "onListAdd(item)"
  shift-sortable-remove = "onListRemove(item)"
  shift-sortable-handle = ".grab-icon"
  shift-sortable-namespace = "bucket_list"
)
  li(ng-repeat = "element in list_of_object_excluded") {{ element.name }}
```
