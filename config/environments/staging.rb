OpenFarm::Application.configure do
  Delayed::Worker.delay_jobs = true
  Delayed::Worker.destroy_failed_jobs = false
  # This would be fixed in rails 5 or maybe even 4.2?
  # http://stackoverflow.com/a/25428800/154392
  config.action_dispatch.perform_deep_munge = false
  config.consider_all_requests_local = true
  config.cache_classes = true
  config.eager_load = true
  config.consider_all_requests_local       = false
  config.action_controller.perform_caching = true
  config.serve_static_files = false
  config.assets.js_compressor = Uglifier.new(harmony: true)
  config.assets.compile = true
  config.assets.digest = true
  config.assets.version = '1.0'
  config.log_level = :info
  config.action_mailer.smtp_settings = { address:   ENV['SMTP_HOST'],
                                         port:      ENV['SMTP_PORT'],
                                         user_name: ENV['SMTP_USERNAME'],
                                         password:  ENV['SMTP_PASSWORD'] }

  config.middleware.use ExceptionNotification::Rack,
    email: {
      email_prefix: '[OpenFarm Errors] ',
      sender_address: %{"notifier" <notifier@openfarm.cc>},
      exception_recipients: ENV['ALERTS'].to_s.split('|')
    },
    ignore_exceptions: ['Mongoid::Errors::DocumentNotFound',
                        'AbstractController::ActionNotFound',
                        'ActionController::RoutingError',
                        'ActionController::InvalidAuthenticityToken',
                        'ActionView::MissingTemplate']
  config.action_mailer.default_url_options = { host: 'staging.openfarm.cc' }
  config.action_mailer.delivery_method = :smtp
  config.action_mailer.perform_deliveries = true
  config.action_mailer.raise_delivery_errors = false
  config.i18n.fallbacks = true
  config.active_support.deprecation = :notify
  config.log_formatter = ::Logger::Formatter.new
  options = { storage: :s3,
              path: '/:rails_env/media/:class/:attachment/:id.:extension',
              s3_protocol: :https,
              s3_credentials: { bucket: ENV['S3_BUCKET_NAME'],
                                access_key_id: ENV['SERVER_S3_ACCESS_KEY'],
                                secret_access_key: ENV['SERVER_S3_SECRET_KEY'] } }

  Paperclip::Attachment.default_options.merge!(options)

end
