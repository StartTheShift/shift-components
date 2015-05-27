<a name="shift.components.module_select"></a>
## select
A directive to mimic HTML select but awesome.


| Param | Type | Description |
| --- | --- | --- |
| options | <code>array</code> | Options to be displayed and to choose from |
| option | <code>object</code> | Option selected |
| onSelect | <code>function</code> | Callback triggered when an option has been selected |
| onDiscard | <code>function</code> | Callback triggered when an option has been de-selected |

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
