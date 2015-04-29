<a name="shift.components.module_calendar"></a>
## calendar
Calendar directive displays the date and changes it on click.


| Param | Type | Description |
| --- | --- | --- |
| date | <code>moment</code> | A moment object, default to now |
| dateChange | <code>function</code> | Called when date is changed |
| dateValidator | <code>function</code> | Method returning a Boolean indicating if the selected date is valid or not |
| dateHightlight | <code>function</code> | Method returning a Boolean to highlight a days on the calendar. |

**Example**  
```jade
shift-calendar(
  date = "date"
  date-change = "onDateChange(date)"
  date-validator = "isValidDate"
  date-highlight = "isSpecialDay"
)
```
