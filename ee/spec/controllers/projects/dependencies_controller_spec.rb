# frozen_string_literal: true

require 'spec_helper'

describe Projects::DependenciesController do
  set(:project) { create(:project, :repository, :private) }
  set(:user) { create(:user) }

  subject { get :show, params: { namespace_id: project.namespace, project_id: project } }

  describe 'GET show' do
    context 'with authorized user' do
      before do
        project.add_developer(user)
        sign_in(user)
      end

      context 'when feature is available' do
        before do
          stub_licensed_features(dependency_list: true)
        end

        it 'renders the show template' do
          subject

          expect(response).to have_gitlab_http_status(200)
          expect(response).to render_template(:show)
        end
      end

      context 'when feature is not available' do
        it 'returns 404' do
          subject

          expect(response).to have_gitlab_http_status(404)
        end
      end
    end

    context 'with unauthorized user' do
      before do
        sign_in(user)
      end

      context 'when feature is available' do
        before do
          stub_licensed_features(dependency_list: true)
        end

        it 'returns 404' do
          subject

          expect(response).to have_gitlab_http_status(404)
        end
      end
    end

    context 'with anonymous user' do
      it 'returns 302' do
        subject

        expect(response).to have_gitlab_http_status(302)
      end
    end
  end
end
