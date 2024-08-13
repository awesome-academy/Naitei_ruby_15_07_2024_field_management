class ChangeOpenAndEndTimeInFields < ActiveRecord::Migration[7.0]
  def up
    change_column :fields, :open_time, :time, default: "08:00"
    change_column :fields, :close_time, :time, default: "12:00"
    
    Field.update_all(open_time: "08:00", close_time: "12:00")
  end
end
