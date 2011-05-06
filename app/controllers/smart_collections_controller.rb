# encoding: utf-8
class SmartCollectionsController < ApplicationController
  prepend_before_filter :authenticate_user!
  layout 'admin'

  expose(:smart_collection)
  expose(:products) { smart_collection.products }

  expose(:rule_columns) { KeyValues::Collection::Column.all }
  expose(:rule_relations) { KeyValues::Collection::Relation.all }
  expose(:rule_orders) { KeyValues::Collection::Order.options }
  expose(:publish_states) { KeyValues::PublishState.options }

  def new
    #保证至少有一个条件
    smart_collection.rules << SmartCollectionRule.new if smart_collection.rules.empty?
  end

  def create
    smart_collection.save
    redirect_to smart_collection_path(smart_collection)
  end

  def update
    smart_collection.save
    flash[:notice] = I18n.t("flash.actions.#{action_name}.notice")
    redirect_to smart_collection_path(smart_collection)
  end

  def destroy
    smart_collection.destroy
    redirect_to smart_collections_path
  end

  #更新可见性
  def update_published
    flash.now[:notice] = I18n.t("flash.actions.update.notice")
    smart_collection.save
    render :template => "shared/msg"
  end

  #更新排序
  def update_order
    smart_collection.save
    flash.now[:notice] = '重新排序成功!'
  end

  #手动调整排序
  def sort
    smart_collection.update_attribute :products_order, :manual
    params[:product].each_with_index do |id, index|
      current_user.shop.smart_collections.find(params[:id]).products.find(id).update_attribute :position, index
    end
    render :nothing => true
  end

end