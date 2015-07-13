<a name="shift.components.module_tooltip"></a>
## tooltip
Tooltip directive displays help text on custom action
executed on the element it is attached to.


| Param | Type | Description |
| --- | --- | --- |
| shiftTooltip | <code>string</code> | the text of the tooltip |
| shiftTooltipTrigger | <code>string</code> | What triggers the tooltip ? click, hover or focus. Default to hover. |
| shiftTooltipPosition | <code>string</code> | Default to 'top', can also be set to left, right and top. |
| fixed | <code>attribute</code> | Use fixed positioning for the the tooltip. To be set when the trigger object is also fixed positioned. |
| shiftTooltipAttachTo | <code>string</code> | a CSS selector where to put the tooltip element. Useful when the tooltip is appearing in a scrollable area. |

**Example**  
```jade
span(
  shift-tooltip = "lorem ipsum"
  shift-tooltip-trigger = "click|hover|focus"
  shift-tooltip-position = "top|bottom|left|right"
  shift-tooltip-attach-to = ".scrollable.classname"
  fixed
) blah blah blah...
```
