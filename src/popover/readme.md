<a name="shift.components.module_popover"></a>
## popover
Popover directive displays transcluded content on custom action
executed on the parent element.


| Param | Type | Description |
| --- | --- | --- |
| date | <code>moment</code> | A moment object, default to now |
| dateChange | <code>function</code> | Called when date is changed |
| dateValidator | <code>function</code> | Method returning a Boolean indicating if the selected date is valid or not |
| dateHightlight | <code>function</code> | Method returning a Boolean to highlight a days on the calendar. |
| dateAllowNull | <code>Boolean</code> | Indicate if the date can be set to null |

**Example**  
```jade
shift-calendar(
  date = "date"
  date-change = "onDateChange(date)"
  date-validator = "isValidDate"
  date-highlight = "isSpecialDay"
  date-allow-null = "true"
)
```
