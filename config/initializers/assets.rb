# Be sure to restart your server when you modify this file.

# Version of your assets, change this if you want to expire all your assets.
Rails.application.config.assets.version = "1.0"

# Add additional assets to the asset load path.
# Rails.application.config.assets.paths << Emoji.images_path

# Precompile additional assets.
# application.js, application.css, and all non-JS/CSS in the app/assets
# folder are already added.
# Rails.application.config.assets.precompile += %w( admin.js admin.css )
Rails.application.config.assets.precompile += %w[*.mp4 *.webm]
Rails.application.config.assets.configure do |env|
  env.register_mime_type 'video/mp4',  extensions: ['.mp4']
  env.register_mime_type 'video/webm', extensions: ['.webm']
end
