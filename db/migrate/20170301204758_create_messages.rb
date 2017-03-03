class CreateMessages < ActiveRecord::Migration[5.0]
  def change
    create_table :messages do |t|
      t.string :location
      t.string :sender_id, index: true
      t.string :recipient_id, index: true
      t.text :body
      t.datetime :sended_at

      t.timestamps
    end
  end
end
