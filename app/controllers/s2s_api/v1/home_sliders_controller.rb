module S2sApi
  module V1
    class HomeSlidersController < BaseController
      inherit_resources
      load_and_authorize_resource

      PER_PAGE = 20

      has_scope :sorted, using: [:column, :direction], type: :hash, default: {
                         column: 'home_sliders.created_at',
                         direction: 'desc'
                       }
      has_scope :with_name, as: :home_slider_name
      has_scope :with_application_id, as: :application_id
      has_scope :with_customer_id, as: :customer_id

      self.responder = S2sApiResponder

      actions :index

      private

      def collection
        params[:page] ||= 1
        params[:per_page] ||= PER_PAGE
        apply_scopes(super).active.page(params[:page]).per(params[:per_page])
      end
    end
  end
end
