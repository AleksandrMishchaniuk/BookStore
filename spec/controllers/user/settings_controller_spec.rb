require 'rails_helper'

RSpec.describe User::SettingsController, type: :controller do
  let(:current_password) { FFaker::Internet.password }
  let(:user) { create(:user, password: current_password) }
  before(:each) { sign_in user }
  before { allow(controller).to receive(:current_user).and_return user }

  shared_examples 'when user is not loged in' do
    context 'when user is not loged in' do
      it 'redirects to login page' do
        sign_out user
        query
        expect(response).to redirect_to new_user_session_path
      end
    end
  end
  shared_examples 'to :edit template' do
    it 'renders :edit template' do
      query
      expect(response).to render_template :edit
    end
    it 'calls method #define_variables' do
      expect(controller).to receive(:define_variables)
      query
    end
  end

  shared_examples 'redirects to :edit page' do
    it 'redirects to :edit page' do
      query
      expect(response).to redirect_to edit_user_settings_path
    end
  end

  describe 'GET #edit' do
    let(:query) { get :edit }

    include_examples 'when user is not loged in'
    context 'when user is loged in' do
      include_examples 'to :edit template'
    end
  end

  describe 'POST #billing_address' do
    let(:address_params) { attributes_for(:address) }
    let(:query) { post :billing_address, user: {billing: {address: address_params}} }

    context 'with invalid arrtibutes' do
      before(:each) { address_params.each_key { |k| address_params[k] = '' } }
      context 'when user already has billing address' do
        before { user.billing_address = create(:address) }
        include_examples 'to :edit template'
      end
      context 'when user does not have billing address yet' do
        before { user.billing_address = nil }
        include_examples 'to :edit template'
      end
    end

    context 'with valid attributes' do
      include_examples 'redirects to :edit page'
      context 'when user already has billing address' do
        before { user.billing_address = create(:address) }
        it 'calles :update method' do
          expect(user.billing_address).to receive(:update).with(address_params)
          query
        end
      end
      context 'when user does not have billing address yet' do
        before { user.billing_address = nil }
        it 'creates billing address' do
          query
          expect(user.billing_address).to be_kind_of(Address)
        end
      end
    end
  end

  describe 'POST #email' do
    context 'with invalid email' do
      let(:email) { user.email }
      let(:query) { post :email, user: { email: '' } }
      it 'reloads current user' do
        expect(user).to receive(:reload)
        query
      end
      include_examples 'to :edit template'
      it 'does not assign new email for current user' do
        query
        expect(user.email).to eq(email)
      end
    end
    context 'with valid attributes' do
      let(:email) { FFaker::Internet.email }
      let(:query) { post :email, user: { email: email } }
      include_examples 'redirects to :edit page'
      it 'assigns new email for current user' do
        query
        expect(user.email).to eq(email)
      end
    end
  end

  shared_examples 'wrong password update' do
    it 'reloads current user' do
      expect(user).to receive(:reload)
      query
    end
    include_examples 'to :edit template'
    it 'does not assign new email for current user' do
      encrypted_current_password = user.encrypted_password
      query
      expect(user.encrypted_password).to eq(encrypted_current_password)
    end
  end

  describe 'POST #password' do
    let(:new_password) { FFaker::Internet.password }

    context 'with invalid password' do
      let(:wrong_password) { FFaker::Internet.password }
      context 'when user types wrong current password' do
        let(:query) do
          post :password, user: {
                                  current_password:       wrong_password,
                                  password:               new_password,
                                  password_confirmation:  new_password
                                }
        end
        include_examples 'wrong password update'
      end
      context 'when user types different new password and password confirmation' do
        let(:query) do
          post :password, user: {
                                  current_password:       current_password,
                                  password:               new_password,
                                  password_confirmation:  wrong_password
                                }
        end
        include_examples 'wrong password update'
      end
    end

    context 'with valid attributes' do
      let(:query) do
        post :password, user: {
                                current_password:       current_password,
                                password:               new_password,
                                password_confirmation:  new_password
                              }
      end
      include_examples 'redirects to :edit page'
      it 'assigns new password for current user' do
        encrypted_current_password = user.encrypted_password
        query
        expect(user.encrypted_password).to_not eq(encrypted_current_password)
      end
    end
  end

  describe 'POST #remove_user' do
    context 'when params do not have :confirm' do
      let(:query) { post :remove_user }
      include_examples 'redirects to :edit page'
      it 'does not destroy user' do
        query
        expect(user).to be_persisted
      end
    end
    context 'when params have :confirm' do
      before(:each) { post :remove_user, confirm: 1 }
      it 'redirect to login page' do
        expect(response).to redirect_to new_user_session_path
      end
      it 'destroys user' do
        expect(user).to_not be_persisted
      end
    end
  end

  describe '#define_variables' do
    before do
      user.billing_address = create(:address)
      user.shipping_address = create(:address)
    end
    it 'defines @user, @billing_address, @shipping_address and @email' do
      controller.send(:define_variables)
      expect(assigns(:user)).to eq(user)
      expect(assigns(:billing_address)).to eq(user.billing_address)
      expect(assigns(:shipping_address)).to eq(user.shipping_address)
      expect(assigns(:email)).to eq(user.email)
    end
  end

end
