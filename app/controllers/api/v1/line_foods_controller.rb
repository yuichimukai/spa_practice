module Api
  module V1
    class LineFoodsController < ApplicationController
      before_action :set_food, only: %i[create replace]

      def index
        line_foods = LineFood.active
        #仮注文ページには仮注文をする前にもリクエストは走るためexists?でチェック
        if line_foods.exists?
          render json: {
            line_food_ids: line_foods.map{|line_food|line_food.id},
            restaurant: line_foods[0].restaurant,
            #保守性の観点からデータの計算のためコントローラ層で処理
            count: line_foods.sum{|line_food|line_food[:count]},
            #数量*単価の合計を示す
            amount: line_foods.sum{|line_food|line_food.total_amount},
          }, status: :ok
        else
          render json: {}, status: :no_content
        end
      end

      def create
        if LineFood.active.other_restaurant(@ordered_food.restaurant.id).exists?
          return render json: {
            existing_restaurant: LineFood.other_restaurant(@ordered_food.restaurant.id).first.restaurant.name,
            new_restaurant: Food.find(params[:food_id]).restaurant.name,
          }, status: :not_acceptable
        end

        set_line_food(@ordered_food)

        if @line_food.save
          render json: {
            line_food: @line_food
          }, status: :created
        else
          render json: {}, status: :internal_server_error
        end
      end

      #既にある古い仮注文を論理削除(activeをfalseの状態に変更)
      #仮注文の置き換え処理
      def replace
        LineFood.active.other_restaurant(@ordered_food.restaurant.id).each do |line_food|
          line_food.update_attribute(:active, false)
        end

        set_line_food(@ordered_food)

        if @line_food.save
          render json: {
            line_food: @line_food
          }, status: :created
        else
          render json: {}, status: :internal_server_error
        end
      end
      
      private

        def set_food
          @ordered_food = Food.find(params[:food_id])
        end

        def set_line_food(ordered_food)
          if ordered_food.line_food.present?
            @line_food = ordered_food.line_food
            @line_food.attributes = {
              count: ordered_food.line_food.count + params[:count],
              active: true
            }
          else
            @line_food = ordered_food.build_line_food(
              count: params[:count],
              restaurant: ordered_food.restaurant,
              active: true
            )
          end
        end
    end
  end
end