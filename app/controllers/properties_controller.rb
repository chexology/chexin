class PropertiesController < ApplicationController
  def index
    @properties = Property.active.order(:name)
  end

  def activity
    @property = Property.find_by!(slug: params[:slug])
    @check_ins = @property.check_ins
                          .includes(:guest, :notification_logs)
                          .order(created_at: :desc)
                          .limit(50)
  end
end
