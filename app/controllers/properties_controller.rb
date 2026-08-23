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

  def edit
    @property = Property.find_by!(slug: params[:slug])
  end

  def update
    @property = Property.find_by!(slug: params[:slug])

    if @property.update(property_params)
      redirect_to property_activity_path(@property.slug), notice: "Settings saved."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def property_params
    params.require(:property).permit(:name, :time_zone, :active, :quiet_hours_start, :quiet_hours_end)
  end
end
