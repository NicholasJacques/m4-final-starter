require 'rails_helper'

RSpec.describe 'Links API' do
  describe 'POST#create' do
    context 'with valid params' do
      it 'creates a new link associated with the current user' do
        user = create(:user)
        allow_any_instance_of(ApplicationController)
          .to receive(:current_user)
          .and_return(user)

        new_url = 'https://www.google.com'
        new_title = 'Google'

        post '/api/v1/links', params: { link: { url: new_url, title: new_title } }
        returned_link = JSON.parse(response.body)

        expect(response).to be_success
        expect(returned_link).to be_a(Hash)
        expect(returned_link['url']).to eq(new_url)
        expect(returned_link['title']).to eq(new_title)
        expect(returned_link['user_id']).to eq(user.id)
        expect(returned_link['read']).to eq(false)
        expect(returned_link).to have_key('id')
        expect(user.links.count).to eq(1)
      end
    end

    context 'with invalid params' do
      scenario 'missing title' do
        user = create(:user)
        allow_any_instance_of(ApplicationController)
          .to receive(:current_user)
          .and_return(user)

        new_url = 'https://www.google.com'

        post '/api/v1/links', params: { link: { url: new_url, title: nil } }
        parsed_response = JSON.parse(response.body)

        expect(parsed_response).to be_a(Hash)
        expect(parsed_response['errors']).to be_an(Array)
        expect(parsed_response['errors'].length).to be(1)
        expect(parsed_response['errors'].first).to eq("Title can't be blank")
      end

      scenario 'missing url' do
        user = create(:user)
        allow_any_instance_of(ApplicationController)
          .to receive(:current_user)
          .and_return(user)

        new_title = 'Good Title'

        post '/api/v1/links', params: { link: { url: nil, title: new_title } }
        parsed_response = JSON.parse(response.body)

        expect(parsed_response).to be_a(Hash)
        expect(parsed_response['errors']).to be_an(Array)
        expect(parsed_response['errors'].length).to be(1)
        expect(parsed_response['errors'].first).to eq("Url can't be blank")
      end

      scenario 'missing title & url' do
        user = create(:user)
        allow_any_instance_of(ApplicationController)
          .to receive(:current_user)
          .and_return(user)

        post '/api/v1/links', params: { link: { url: nil, title: nil } }
        parsed_response = JSON.parse(response.body)

        expect(parsed_response).to be_a(Hash)
        expect(parsed_response['errors']).to be_an(Array)
        expect(parsed_response['errors'].length).to be(2)
        expect(parsed_response['errors']).to include("Title can't be blank")
        expect(parsed_response['errors']).to include("Url can't be blank")
      end

      scenario 'no authenticated user' do
        user = create(:user)

        new_url = 'https://www.google.com'
        new_title = 'Good Title'

        post '/api/v1/links', params: { link: { url: new_url, title: new_title } }
        parsed_response = JSON.parse(response.body)

        expect(parsed_response).to be_a(Hash)
        expect(parsed_response['errors']).to be_an(Array)
        expect(parsed_response['errors'].length).to be(1)
        expect(parsed_response['errors'].first).to eq("Must be logged in to create a link")
      end
    end
  end
end
