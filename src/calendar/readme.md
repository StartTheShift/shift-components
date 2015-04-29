<a name="shift.components.module_calendar"></a>
## calendar
Calendar directive displays the date and changes it on click.


| Param | Type | Description |
| --- | --- | --- |
| date | <code>moment</code> | A moment object, default to now |
| dateChange | <code>function</code> | Called when date is changed |

**Example**  
```jade
shift-calendar(
  date = "date"
  date-change = "onDateChange(date)"
)
```
