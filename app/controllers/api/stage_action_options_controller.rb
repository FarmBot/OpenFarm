module Api
  class StageActionOptionsController < Api::Controller
    skip_before_action :authenticate_from_token!, only: [:index]

    def index
      render json: StageActionOption.all
    end
  end
end
