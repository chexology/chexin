class CheckInsController < ApplicationController
  def mark_ready
    check_in = CheckIn.find(params[:id])
    check_in.mark_ready!

    redirect_to property_activity_path(check_in.property.slug),
                notice: "#{check_in.guest.name} will be notified that their #{check_in.item_description} is ready."
  end
end
