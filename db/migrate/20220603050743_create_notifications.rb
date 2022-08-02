class CreateNotifications < ActiveRecord::Migration[6.1]
  def change
    create_table :notifications do |t|
      t.references :recipient, null: false, foreign_key: { to_table: 'users' }
      t.references :sender, null: false, foreign_key: { to_table: 'users' }
      t.string :action
      t.references :notifiable, polymorphic: true

      t.timestamps
    end
  end
end
