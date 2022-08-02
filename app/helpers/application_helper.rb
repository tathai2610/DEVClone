module ApplicationHelper
  include Pagy::Frontend
  
  def flash_class(level)
    case level
    when 'notice' then "success"
    when 'alert' then "warning"
    when 'warning' then "warning"
    when 'error' then "danger"
    end
  end

end
