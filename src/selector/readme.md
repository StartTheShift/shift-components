<a name="shift.components.module_selector"></a>
## selector
A directive that displays a list of option, navigation using arrow
keys + enter or mouse click.

The options are not displayed anymore if selected has a value or if
options is emtpy.


| Param | Type | Description |
| --- | --- | --- |
| options | <code>array</code> | Options to be displayed and to choose from |
| selected | <code>object</code> | Object selected from the options |
| onSelect | <code>function</code> | Callback triggered when an option has been selected |
| onDiscard | <code>function</code> | Callback triggered when an option has de-selected |
| multiple | <code>boolean</code> | Indicates if the selection allows selection of more than one option |

**Example**  
```jade
  shift-selector(
    options = "options"
    selected = "selected"
    on-select = "onSelect(selected)"
    on-discard = "onDiscard(discarded)"
    multiple
  )
    strong {{option.city}}
    span &nbsp; {{option.state}}
    div
      i pop. {{option.population}}
```
