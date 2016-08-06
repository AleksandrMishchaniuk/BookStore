require 'rails_helper'

RSpec.describe ApplicationController, type: :controller do
  include OdrderInProgressHelpers

  describe "#define_order_in_progress" do
    it "should set object of Order to @order" do
      subject.send(:define_order_in_progress)
      expect(assigns(:order)).to be_kind_of(Order)
    end

    context "when session has saved :cart_items hash" do
      it do
        order = order_from_session_by_cart_items
        subject.send(:define_order_in_progress)
        expect(assigns(:order)).to eq(order)
      end
    end

    context "when session has saved :cart_items and :order_in_progress_id hashes" do
      it do
        order_not_persisted = order_from_session_by_cart_items
        order_persisted_with_session = order_by_id_from_session
        subject.send(:define_order_in_progress)
        expect(assigns(:order)).to eq(order_persisted_with_session)
        expect(assigns(:order)).to_not eq(order_not_persisted)
      end
    end

    context "when current user has order in progress and session has saved :cart_items hash" do
      it do
        order_persisted_with_user = order_by_current_user
        order_not_persisted = order_from_session_by_cart_items
        subject.send(:define_order_in_progress)
        expect(assigns(:order)).to eq(order_persisted_with_user)
        expect(assigns(:order)).to_not eq(order_not_persisted)
      end
    end

    context "when current user has order in progress and session has saved :cart_items and :order_in_progress_id hashes" do
      it do
        order_not_persisted = order_from_session_by_cart_items
        order_persisted_with_session = order_by_id_from_session
        order_persisted_with_user = order_by_current_user
        subject.send(:define_order_in_progress)
        expect(assigns(:order)).to eq(order_persisted_with_session)
        expect(assigns(:order)).to_not eq(order_not_persisted)
        expect(assigns(:order)).to_not eq(order_persisted_with_user)
      end
    end
  end

end
