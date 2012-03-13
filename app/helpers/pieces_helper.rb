module PiecesHelper
  def get_field_view_pref(event_type_id, field_type_id,pref_set)
    name = "perm[#{event_type_id}-#{field_type_id}]"
    perm = pref_set[event_type_id] ? pref_set[event_type_id][field_type_id]: 'on'
    color = "#f66"
    if perm == 'on'
      color = "#9f9"
      checked = "checked='checked'"
    end
    return "<span style='background:#{color};'><input name='#{name}'type='checkbox'#{checked}></span>"
  end
end
