<a name="shift.components.module_floating"></a>
## floating
Floating element directive displays template content on custom action
executed on the parent element.


| Param | Type | Description |
| --- | --- | --- |
| trigger | <code>string</code> | The event trigger type click, hover or focus |
| position | <code>string</code> | The positioning of the element relative to its parent |
| fixed | <code>string</code> | if provided, the floating element will be fixed positioned |
| offset | <code>number</code> | margin from the parent element |
| parent | <code>element</code> | Parent object relative to |
| attachTo | <code>string</code> | Optional css selector of the scrollable element containing the element. default to "body", the selector will be matched against the parent of the container. |

**Example**  
```jade
shift-floating(
  trigger = "click|hover|focus"
  position = "top|bottom|left|right"
  parent = ""
  offset = "5"
  attach-to = ".css-seletor"
  fixed
)
```
