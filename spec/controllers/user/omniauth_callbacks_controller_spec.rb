require 'rails_helper'

RSpec.describe User::OmniauthCallbacksController, type: :controller do

  describe '#facebook' do
    let(:query) { get :facebook }
    let(:session) { {} }
    let(:referer_url) { root_locale_path(locale: 'en') }
    let(:auth_data) {{
            provider: auth.provider,
            uid: auth.uid,
            info: {
              email: user.email
            },
            extra: {
              raw_info: {
                first_name: auth.data[:first_name],
                last_name:  auth.data[:last_name]
              }
            }
    }}
    let(:auth) { build :soc_auth }
    before do
      @request.env["devise.mapping"] = Devise.mappings[:user]
      session[:locale] = 'en'
      allow(controller).to receive(:session).and_return(session)
      allow(controller).to receive(:data).and_return(auth_data)
      allow_any_instance_of(ApplicationController).to receive(:after_sign_in_path_for)
                                        .and_return(referer_url)
    end

    shared_examples 'redirects to referer' do
      it 'redirects to referer' do
        query
        expect(response).to redirect_to(referer_url)
      end
    end

    shared_examples 'redirects to login page' do
      it 'redirects to login page' do
        query
        expect(response).to redirect_to new_user_session_path(locale: session[:locale])
        expect(flash[:alert]).to_not be_nil
      end
    end


    shared_examples 'when oauth params do not have :provider data' do
      context 'when oauth params do not have :provider data' do
        let(:auth_data) {{
          provider: nil,
          uid: auth.uid,
          info: {
            email: user.email
          }
          }}
          include_examples 'redirects to login page'
        end # when oauth params do not have :provider data
    end

    shared_examples 'when oauth params do not have :uid data' do
      context 'when oauth params do not have :uid data' do
        let(:auth_data) {{
          provider: auth.provider,
          uid: nil,
          info: {
            email: user.email
          }
          }}
          include_examples 'redirects to login page'
        end # when oauth params do not have :uid data
    end

    shared_examples 'when oauth params do not have :email data' do
      context 'when oauth params do not have :email data' do
        let(:auth_data) {{
          provider: auth.provider,
          uid: auth.uid,
          info: {
            email: nil
          }
          }}
          include_examples 'redirects to login page'
        end # when oauth params do not have :email data
    end

    shared_examples 'when oauth params do not have extra data' do
      context 'when oauth params do not have extra data' do
        let(:auth_data) {{
          provider: auth.provider,
          uid: auth.uid,
          info: {
            email: user.email
          }
          }}
          it "creates soc_auth with data params via nil" do
            query
            expect(controller.current_user.soc_auths[0].data[:first_name]).to be_nil
            expect(controller.current_user.soc_auths[0].data[:last_name]).to be_nil
          end
        end # when oauth params do not have extra data
    end

    context 'when user exists and has soc_auth' do
      let(:user) { create(:user).reload }
      let(:auth) { create(:soc_auth, user: user).reload }
      let(:auth_data) {{
              provider: auth.provider,
              uid: auth.uid,
      }}
      include_examples 'redirects to referer'
      it 'has current_user' do
        query
        expect(controller.current_user).to be_eql(user)
      end
      include_examples 'when oauth params do not have :provider data'
      include_examples 'when oauth params do not have :uid data'
    end # when user exists and has soc_auth

    context 'when user exists and does not have soc_auth' do
      let(:user) { create(:user).reload }
      include_examples 'redirects to referer'
      it 'has current_user with soc_auth' do
        query
        expect(controller.current_user).to be_eql(user)
        ids = controller.current_user.soc_auths.map &:uid
        expect(ids).to include(auth_data[:uid])
      end
      include_examples 'when oauth params do not have :provider data'
      include_examples 'when oauth params do not have :uid data'
      include_examples 'when oauth params do not have :email data'
      include_examples 'when oauth params do not have extra data'
    end # when user exists and does not have soc_auth

    context 'when user does not exist' do
      let(:user) { build :user }
      include_examples 'redirects to referer'
      it 'has current_user with soc_auth' do
        query
        expect(controller.current_user.email).to be_eql(auth_data[:info][:email])
        ids = controller.current_user.soc_auths.map &:uid
        expect(ids).to include(auth_data[:uid])
      end
      include_examples 'when oauth params do not have :provider data'
      include_examples 'when oauth params do not have :uid data'
      include_examples 'when oauth params do not have :email data'
      include_examples 'when oauth params do not have extra data'
    end # when user does not exist

  end # #facebook

end
