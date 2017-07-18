require 'rails_helper'

RSpec.describe 'Submitting a new link', js: true do
  context 'with valid inputs' do
    scenario 'user adds a new link to their bookmarks' do
      user = create(:user)
      title = 'new title'
      url = 'http://www.google.com'
      allow_any_instance_of(ApplicationController)
        .to receive(:current_user)
        .and_return(user)

      visit root_path

      fill_in('link[title]', with: title)
      fill_in('link[url]', with: url)
      click_on 'Add Link'

      within('.link') do
        expect(page).to have_css('p.link-title', text: "Title: #{title}")
        expect(page).to have_css('p.link-url', text: "URL: #{url}")
        expect(page).to have_css('p.read-status', text: 'Read?: false')
        expect(page).to have_button('Mark as Read')
        expect(page).to have_button('Edit')
      end

      expect(current_path).to eq(root_path)

      expect(user.links.count).to eq(1)
      expect(user.links.last.title).to eq(title)
      expect(user.links.last.url).to eq(url)
      expect(user.links.last.read).to eq(false)
    end
  end

  context 'with invalid inputs' do
    scenario 'missing title' do
      user = create(:user)
      url = 'http://www.google.com'
      allow_any_instance_of(ApplicationController)
        .to receive(:current_user)
        .and_return(user)

      visit root_path

      fill_in('link[url]', with: url)
      click_on 'Add Link'

      expect(current_path).to eq(root_path)

      within('.errors') do
        expect(page).to have_css('p.error', text: "Title can't be blank.")
      end

      expect(user.links.count).to eq(0)
    end
  end
end
