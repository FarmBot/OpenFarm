RailsAdmin.config do |config|
  # We need this because Karminari doesn't seem to work
  # too well alongside RailsAdmin. Maybe it's a conflict
  # of which gets defined first?
  Kaminari::Hooks.init

  ### Popular gems integration

  ## == Devise ==
  # config.authenticate_with do
  #   warden.authenticate! scope: :admin
  # end

  config.current_user_method do
    if current_user && current_user.admin?
      current_user
    else
      flash[:notice] = 'I told you kids to get out of here!'
      redirect_to '/'
      nil
    end
  end

  ## == Cancan ==
  # config.authorize_with :cancan

  ## == PaperTrail ==
  # config.audit_with :paper_trail, 'User', 'PaperTrail::Version'
  # PaperTrail >= 3.0.0

  ### More at https://github.com/sferik/rails_admin/wiki/Base-configuration

  config.actions do
    dashboard                     # mandatory
    index                         # mandatory
    new
    export
    bulk_delete
    show
    edit
    delete
    show_in_app

    ## With an audit adapter, you can add:
    # history_index
    # history_show
  end

  config.model 'Announcement' do
    edit do
      include_fields :starts_at, :ends_at, :is_permanent
      field :message, :text
    end
  end
end
