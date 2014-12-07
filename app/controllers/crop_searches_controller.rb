class CropSearchesController < ApplicationController
  skip_before_action :verify_authenticity_token, only: :search

  def search
    query = params[:q].to_s
    @crops = Crop.search(query,
                         limit:  25,
                         fields: ['name^20',
                                  'common_names^10',
                                  'binomial_name^10',
                                  'description'])
    @crops = Crop.search('*', limit: 25) if @crops.empty?

    # Use the crop results to look-up guides
    crop_ids = @crops.collect(&:id)
    @guides = Guide.search('*', where: { crop_id: crop_ids })

    render :show
  end
end
