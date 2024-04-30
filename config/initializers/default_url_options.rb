Rails.application.routes.default_url_options = {
  host: 'example.com',
  protocol: 'https'
}

# Rails.application.routes.default_url_options = if Rails.env.production?
#   { host: 'example.com', protocol: 'https' }  # Use heroku domain and protocol
# else
#   { host: 'localhost', port: 3000, protocol: 'http' }  # Use typical development settings
# end
