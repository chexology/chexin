class AddQuietHoursToProperties < ActiveRecord::Migration[7.0]
  def change
    add_column :properties, :quiet_hours_start, :time
    add_column :properties, :quiet_hours_end, :time
  end
end
