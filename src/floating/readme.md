<a name="shift.components.module_popover"></a>
## popover
Floating element directive displays template content on custom action
executed on the parent element.


| Param | Type | Description |
| --- | --- | --- |
| trigger | <code>string</code> | The event trigger type click, hover or focus |
| position | <code>string</code> | The positioning of the element relative to its parent |
| fixed | <code>string</code> | if provided, the floating element will be fixed positioned |
| templateUrl | <code>string</code> | Template url to be loaded |

**Example**  
```jade
shift-floating(
  trigger = "click|hover|focus"
  position = "top|bottom|left|right"
  template-url = ""
  fixed
)
```
