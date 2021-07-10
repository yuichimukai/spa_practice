class LineFood < ApplicationRecord
  belongs_to :food
  belongs_to :restaurant
  #関連付けは任意を示すoptional: true
  belongs_to :order, optional: true

  validates :count, numericality: { greater_than: 0 }
  
  #sucopeメソッドはActiveRecord_Relationオブジェクトが返ってくる
  #scopeを呼び出したときに実装してほしいクエリを渡している
  scope :active, -> { where(active: true) }
  #scopeには引数を与えることができる
  scope :other_restaurant, -> (picked_restaurnat_id) { where.not(restaurant_id: picked_restaurnat_id) }

  #コントローラーではなくモデルに記述することで様々な箇所から呼び出せる
  #apiコントローラで呼び出すためここでline_foodインスタンスの合計金額を算出している
  def total_amount
    food.price * count
  end
end