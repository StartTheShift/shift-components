<a name="shift.components.module_select"></a>
## select
A directive to mimic HTML select and its augment customization.


| Param | Type | Description |
| --- | --- | --- |
| options | <code>array</code> | Options to be displayed and to choose from |
| option | <code>object</code> | Option selected from the options |
| onSelect | <code>function</code> | Callback triggered when an option has been selected |
| onDiscard | <code>function</code> | Callback triggered when an option has de-selected |

**Example**  
```jade
  shift-select(
    options = "options"
    option = "selected_option"
    on-select = "onSelect(selected)"
    on-discard = "onDiscard(discarded)"
  )
    strong {{option.city}}, {{ option.state }}
    div
      i pop. {{option.population}}
```
