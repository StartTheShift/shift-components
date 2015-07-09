<a name="shift.components.module_calendar"></a>
## calendar
Calendar directive displays the date and changes it on click.

Note that moment(moment_object) is heavily used to clone a date instead of
just passing the reference (since date is a moment object). It allows simpler
date handeling without the the risk of impacting associated dates.


| Param | Type | Description |
| --- | --- | --- |
| date | <code>moment</code> | A moment object, default to now |
| change | <code>function</code> | Called when date is changed |
| validator | <code>function</code> | Method returning a Boolean indicating if the selected date is valid or not |
| highlight | <code>function</code> | Method returning a Boolean to highlight a days on the calendar. |
| allowNull | <code>Boolean</code> | Indicate if the date can be set to null |

**Example**  
```jade
shift-calendar(
  ng-model = "date"
  change = "onDateChange(date)"
  validator = "isValidDate"
  highlight = "isSpecialDay"
  allow-null = "true"
)
```
