<a name="shift.components.module_time"></a>
## time
Time directive displays a text input guessing the time entered.


| Param | Type | Description |
| --- | --- | --- |
| time | <code>moment</code> | A moment object, default to now the selected date is valid or not |

**Example**  
```jade
input(
  ng-model = "date"
  type = "text"
  shift-time
)
```
