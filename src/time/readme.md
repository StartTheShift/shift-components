<a name="shift.components.module_time"></a>
## time
Time directive displays a text input guessing the time entered. Accepts
a moment_object object as model and only inpacts its time.


| Param | Type | Description |
| --- | --- | --- |
| time | <code>moment</code> | A moment object, default to now |
| timeChange | <code>function</code> | Called when date is changed |
| timeValidator | <code>function</code> | Method returning a Boolean indicating if the selected date is valid or not |
| timeAllowNull | <code>Boolean</code> | Indicate if the date can be set to null |

**Example**  
```jade
shift-time(
  time = "date"
  time-change = "onDateChange(date)"
  time-validator = "isValidDate"
)
```
