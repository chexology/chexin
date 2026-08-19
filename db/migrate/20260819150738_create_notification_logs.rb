class CreateNotificationLogs < ActiveRecord::Migration[7.0]
  def change
    create_table :notification_logs do |t|
      t.references :check_in, null: false, foreign_key: true
      t.string :channel, null: false, default: "sms"
      t.string :status, null: false
      t.string :detail

      t.timestamps
    end
  end
end
