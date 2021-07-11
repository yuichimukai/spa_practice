class Order < ApplicationRecord
  has_many :line_foods
  has_one :restaurant, through: :line_food

  validates :total_price, numericality: { greater_than: 0 }

  #メソッドに!をつけることで例外処理を出し、使う側が内部処理を把握しやすいようにする
  def save_with_update_line_foods!(line_foods)
    #破壊的メソッドであるupdate_attributes!とsave!の２つの処理に対してトランザクションを張る
    ActiveRecord::Base.transaction do
      line_foods.each do |line_food|
        line_food.update_attributes!(active: false, order: self)
      end
      self.save!
    end
  end
end