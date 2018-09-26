module RedminePulls
  module Helpers
    def link_to_pull(pull, options={})
      project = pull.project

      text = options.delete(:text) || pull.summary

      link_to(h(text), {:controller => 'pulls', :action => 'show', :id => pull}, :title => text)
    end

    def column_value(column, item, value)
      case column.name
        when :id, :subject
          link_to_pull item, :text => value
        when :description
          item.description? ? content_tag('div', textilizable(item, :description), :class => "wiki") : ''
        when :last_notes
          item.last_notes.present? ? content_tag('div', textilizable(item, :last_notes), :class => "wiki") : ''
        else
          format_object(value)
      end
    end
  end
end
