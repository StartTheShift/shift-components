<a name="shift.components.module_popover"></a>
## popover
Popover directive displays transcluded content on custom action
executed on the parent element.


| Param | Type | Description |
| --- | --- | --- |
| shiftPopover | <code>string</code> | the text of the popover |
| shiftPopoverTitle | <code>string</code> | (optional) The title of the popover |
| shiftPopoverTrigger | <code>string</code> | What triggers the popover ? click, hover or focus. |
| shiftPopoverPosition | <code>string</code> | Default to 'bottom', can also be set to left, right and top. |
| shiftPopoverTemplateUrl | <code>string</code> | the template URL for rendering. When provided, the text and title attribute are ignored. |
| fixed | <code>attribute</code> | Use fixed positioning for the the tooltip. To be set when the trigger object is also fixed positioned. |
| shiftPopoverAttachTo | <code>string</code> | a CSS selector where to put the popover element. Useful when the popover is appearing in a scrollable area. |

**Example**  
```jade
input(
  type = "text"
  ng-model = "foo"
  shift-popover = "lorem ipsum"
  shift-popover-title = "date"
  shift-popover-trigger = "click|hover|focus"
  shift-popover-position = "top|bottom|left|right"
  shift-popover-template-url = "xyz.html"
  shift-popover-attach-to = ".scrollable.classname"
  fixed
)
```
